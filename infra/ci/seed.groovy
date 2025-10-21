// Job DSL seed to create the main pipeline job
// How to use:
// - In Jenkins, create a Freestyle job named 'seed-job'
// - Add build step: Process Job DSLs > Use provided DSL script > paste this file content or point to this path in SCM
// - Optionally set environment variables on the seed job:
//   REPO_URL: Git URL of this repo (default: https://github.com/tu-org/ecommerce-microservice-backend-app.git)
//   CREDENTIALS_ID: Jenkins credentials ID for the Git repo (optional)
//   BRANCH: branch to build (default: main)
//
// Notes:
// - Pipeline parameters are defined in Jenkinsfile itself.
// - You can re-run the seed job to update the pipeline configuration.

def repoUrl = System.getenv('REPO_URL') ?: 'https://github.com/JohanDanielAguirre/ecommerce-microservice-backend-app.git'
def credentialsId = System.getenv('CREDENTIALS_ID') ?: ''
def branch = System.getenv('BRANCH') ?: 'main'

def jobName = 'ecommerce-ms-pipeline'

def gitScm = {
  git {
    remote {
      url(repoUrl)
      if (credentialsId?.trim()) {
        credentials(credentialsId)
      }
    }
    branch("*/${branch}")
  }
}

pipelineJob(jobName) {
  description('Pipeline para build/test + release notes (major), auto-tag y publish release opcional. Lee el Jenkinsfile del repo.')
  logRotator {
    daysToKeep(30)
    numToKeep(50)
  }
  properties {
    disableConcurrentBuilds()
  }
  definition {
    cpsScm {
      scm {
        ${gitScm}
      }
      scriptPath('Jenkinsfile')
      lightweight(true)
    }
  }
  // Optional triggers: uncomment one of these
  // triggers {
  //   scm('H/5 * * * *') // poll SCM every 5 minutes
  // }
}
