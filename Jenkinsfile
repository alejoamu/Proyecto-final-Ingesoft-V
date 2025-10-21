pipeline {
  agent any
  options {
    timestamps()
    disableConcurrentBuilds()
  }
  parameters {
    booleanParam(name: 'RUN_SONAR', defaultValue: false, description: 'Ejecutar analisis SonarQube (requiere SONAR_HOST_URL y SONAR_TOKEN)')
    string(name: 'SONAR_HOST_URL', defaultValue: '', description: 'URL de SonarQube (ej: http://<vm_ci_public_ip>:32000)')
    password(name: 'SONAR_TOKEN', defaultValue: '', description: 'Token de SonarQube (mejor usar credenciales seguras en Jenkins)')

    booleanParam(name: 'RUN_TRIVY', defaultValue: false, description: 'Ejecutar escaneo Trivy en el workspace (requiere trivy instalado en el agente)')

    booleanParam(name: 'AUTO_TAG', defaultValue: false, description: 'Crear y push de tag mayor automáticamente cuando se detecte cambio mayor')
    string(name: 'TAG_PREFIX', defaultValue: 'v', description: 'Prefijo de tag semántico (ej: v)')
    booleanParam(name: 'PUBLISH_RELEASE', defaultValue: false, description: 'Publicar release en GitHub con los release notes (requiere GH_TOKEN)')
    password(name: 'GH_TOKEN', defaultValue: '', description: 'Token GitHub con permiso repo para crear releases (si dejas vacío, se intentará usar GITHUB_CREDENTIALS_ID)')
    string(name: 'GITHUB_CREDENTIALS_ID', defaultValue: 'github-token', description: 'ID de credencial (Secret text) en Jenkins que contiene el GH_TOKEN')
  }
  environment {
    MAVEN_OPTS = "-Dmaven.test.failure.ignore=false"
  }
  stages {
    stage('Prepare') {
      steps {
        sh 'chmod +x mvnw || true'
        sh './mvnw -v || mvn -v || true'
        sh 'java -version || true'
        // Manejar repos shallow
        sh 'git fetch --unshallow 2>/dev/null || true'
        // Asegurar tags disponibles (evita shallow fetch problema)
        sh 'git fetch --tags --force --prune || true'
      }
    }
    stage('Build & Test') {
      steps {
        sh './mvnw -B -U clean verify'
      }
    }
    stage('Report tests') {
      steps {
        junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml, **/target/failsafe-reports/*.xml'
      }
    }
    stage('SonarQube (optional)') {
      when {
        expression { return params.RUN_SONAR && params.SONAR_HOST_URL?.trim() && params.SONAR_TOKEN?.trim() }
      }
      steps {
        sh "./mvnw -B sonar:sonar -Dsonar.host.url=${params.SONAR_HOST_URL} -Dsonar.login=${params.SONAR_TOKEN}"
      }
    }
    stage('Trivy scan (optional)') {
      when { expression { return params.RUN_TRIVY } }
      steps {
        sh 'trivy --version || echo "Trivy no instalado en el agente; omitiendo"'
        sh 'trivy fs --no-progress --severity HIGH,CRITICAL --exit-code 0 --format sarif --output trivy-results.sarif . || true'
        archiveArtifacts artifacts: 'trivy-results.sarif', allowEmptyArchive: true
      }
    }

    // --- Releases ---
    stage('Detect major changes') {
      steps {
        script {
          def lastTag = sh(script: 'git describe --tags --abbrev=0 2>/dev/null || echo NONE', returnStdout: true).trim()
          def range = (lastTag == 'NONE') ? '' : "${lastTag}..HEAD"
          def logCmd = (range ? "git log --pretty=format:'%s%n%b' ${range}" : "git log --pretty=format:'%s%n%b'")
          def subjLogCmd = (range ? "git log --pretty=format:'%s' ${range}" : "git log --pretty=format:'%s'")

          // Criterios mayor: BREAKING CHANGE, '!:' en título, o títulos que empiecen con 'Feat:' o 'Test:' (primera mayúscula)
          def breaking = sh(script: "${logCmd} | grep -E 'BREAKING CHANGE|!:' -m1 || true", returnStdout: true).trim()
          def majorByCase = sh(script: "${subjLogCmd} | grep -E '^(Feat|Test)(\\(.*\\))?:' -m1 || true", returnStdout: true).trim()

          env.LAST_TAG = lastTag
          env.COMMIT_RANGE = range
          env.HAS_BREAKING = (breaking || majorByCase) ? 'true' : 'false'

          echo "Last tag: ${env.LAST_TAG}"
          echo "Commit range: ${env.COMMIT_RANGE ?: 'ALL'}"
          echo "Has breaking changes? ${env.HAS_BREAKING}"
        }
      }
    }

    stage('Generate Release Notes (major only)') {
      when { expression { return env.HAS_BREAKING == 'true' } }
      steps {
        script {
          def version = sh(script: "./mvnw -q -DforceStdout help:evaluate -Dexpression=project.version 2>/dev/null | tail -n 1", returnStdout: true).trim()
          if (!version) { version = '0.0.0-unknown' }
          def dateStr = sh(script: 'date +%Y-%m-%d', returnStdout: true).trim()
          def notesFile = "release-notes-${version}-${dateStr}.md"

          def subjectFmt = "--pretty=format:%h %s"
          def allRange = env.COMMIT_RANGE ?: ''

          def baseLog = allRange ? "git log ${subjectFmt} ${allRange}" : "git log ${subjectFmt}"
          // Incluir Feat/Test en breaking para destacarlos también
          def breakingLog = allRange ? "git log --pretty=format:'%h %s%n%b' ${allRange} | grep -E 'BREAKING CHANGE|!:| Feat(\\(.*\\))?:| Test(\\(.*\\))?:' || true" : "git log --pretty=format:'%h %s%n%b' | grep -E 'BREAKING CHANGE|!:| Feat(\\(.*\\))?:| Test(\\(.*\\))?:' || true"
          def featLog = "${baseLog} | grep -Ei '^.* feat(\\(.*\\))?:|^.* Feat(\\(.*\\))?:' || true"
          def fixLog  = "${baseLog} | grep -Ei '^.* fix(\\(.*\\))?:|^.* Fix(\\(.*\\))?:' || true"
          def testLog = "${baseLog} | grep -Ei '^.* test(\\(.*\\))?:|^.* Test(\\(.*\\))?:' || true"

          sh """
            echo '# Release Notes (major)' > ${notesFile}
            echo '' >> ${notesFile}
            echo "Version: ${version}" >> ${notesFile}
            echo "Date: ${dateStr}" >> ${notesFile}
            echo "Since: ${env.LAST_TAG}" >> ${notesFile}
            echo '' >> ${notesFile}

            echo '## Breaking Changes' >> ${notesFile}
            ${breakingLog} | sed 's/^/- /' >> ${notesFile}
            echo '' >> ${notesFile}

            echo '## Features' >> ${notesFile}
            ${featLog} | sed 's/^/- /' >> ${notesFile}
            echo '' >> ${notesFile}

            echo '## Fixes' >> ${notesFile}
            ${fixLog} | sed 's/^/- /' >> ${notesFile}
            echo '' >> ${notesFile}

            echo '## Tests' >> ${notesFile}
            ${testLog} | sed 's/^/- /' >> ${notesFile}
            echo '' >> ${notesFile}

            echo '## Full log' >> ${notesFile}
            ${baseLog} | sed 's/^/- /' >> ${notesFile}
          """

          archiveArtifacts artifacts: notesFile, allowEmptyArchive: false
          env.NOTES_FILE = notesFile
          echo "Release notes generados: ${notesFile}"
        }
      }
    }

    stage('Auto Tag (optional)') {
      when { expression { return env.HAS_BREAKING == 'true' && params.AUTO_TAG } }
      steps {
        script {
          def baseTag = (env.LAST_TAG == 'NONE') ? "${params.TAG_PREFIX}0.0.0" : env.LAST_TAG
          def sem = baseTag.replaceAll('^[^0-9]*','')
          def parts = sem.tokenize('.')
          def major = (parts && parts[0].isInteger()) ? parts[0].toInteger() : 0
          def newTag = "${params.TAG_PREFIX}${major + 1}.0.0"

          sh "git tag -a '${newTag}' -m 'Major release: ${newTag}'"
          // Intento de push del tag; si la credencial ya esta configurada en el checkout, funcionara
          sh "git push origin '${newTag}' || git push --tags || true"
          env.NEW_TAG = newTag
          echo "Tag creado y enviado: ${newTag}"
        }
      }
    }

    stage('Publish Release (optional)') {
      when { expression { return env.HAS_BREAKING == 'true' && params.PUBLISH_RELEASE && (params.GH_TOKEN?.trim() || params.GITHUB_CREDENTIALS_ID?.trim()) && env.NEW_TAG && env.NOTES_FILE } }
      steps {
        script {
          if (params.GH_TOKEN?.trim()) {
            withEnv(["GITHUB_TOKEN=${params.GH_TOKEN}"]) {
              sh '''
                set -e
                repoUrl=$(git config --get remote.origin.url)
                if echo "$repoUrl" | grep -qi 'github.com'; then
                  if echo "$repoUrl" | grep -q '^git@'; then
                    slug=$(echo "$repoUrl" | sed -E 's#^git@github.com:##; s#\\.git$##')
                  else
                    slug=$(echo "$repoUrl" | sed -E 's#^https?://(www\\.)?github.com/##; s#\\.git$##')
                  fi
                else
                  echo "Repositorio no es GitHub; saltando publish release."
                  exit 0
                fi
                body=$(sed 's/\"/\\\"/g' "${NOTES_FILE}" | awk 'BEGIN{ORS="\\n"}{print}' | sed ':a;N;$!ba;s/\n/\\n/g')
                curl -s -H "Authorization: token ${GITHUB_TOKEN}" -H "Content-Type: application/json" -X POST \
                  -d "{\"tag_name\":\"${NEW_TAG}\",\"name\":\"${NEW_TAG}\",\"body\":\"${body}\"}" \
                  "https://api.github.com/repos/${slug}/releases" | tee release_response.json
              '''
            }
          } else {
            withCredentials([string(credentialsId: params.GITHUB_CREDENTIALS_ID, variable: 'GITHUB_TOKEN')]) {
              sh '''
                set -e
                repoUrl=$(git config --get remote.origin.url)
                if echo "$repoUrl" | grep -qi 'github.com'; then
                  if echo "$repoUrl" | grep -q '^git@'; then
                    slug=$(echo "$repoUrl" | sed -E 's#^git@github.com:##; s#\\.git$##')
                  else
                    slug=$(echo "$repoUrl" | sed -E 's#^https?://(www\\.)?github.com/##; s#\\.git$##')
                  fi
                else
                  echo "Repositorio no es GitHub; saltando publish release."
                  exit 0
                fi
                body=$(sed 's/\"/\\\"/g' "${NOTES_FILE}" | awk 'BEGIN{ORS="\\n"}{print}' | sed ':a;N;$!ba;s/\n/\\n/g')
                curl -s -H "Authorization: token ${GITHUB_TOKEN}" -H "Content-Type: application/json" -X POST \
                  -d "{\"tag_name\":\"${NEW_TAG}\",\"name\":\"${NEW_TAG}\",\"body\":\"${body}\"}" \
                  "https://api.github.com/repos/${slug}/releases" | tee release_response.json
              '''
            }
          }
        }
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
    }
  }
}
