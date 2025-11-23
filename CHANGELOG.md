## 1.0.0-notes.1 (2025-11-23)

### Features

* Add initial Terraform Azure infrastructure ([c05e7e9](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/c05e7e96e4fa43564f9e0a8a70465bb5caabd1bd))
* Add kubeconfig and update cloud-config with probes ([5365c7b](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/5365c7b474411ab1defa92cc47309c25f53ef80d))
* Add Kubernetes manifests for ecommerce microservices ([2b89df1](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/2b89df1fb8da689985d0d6624b60398d8cc6841d))
* Add release automation and change management docs ([ec7f271](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/ec7f27130d002c3f13a06763b3d5e37773aabe48))
* Add semantic release, notifications, and gated deploy workflows ([4178879](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/4178879af6e2e7351daa94e93293762218134ff2))
* Add SonarQube and Trivy code quality integration ([0143da9](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/0143da9b53f65e99e7f1637850809a47935d53b7))
* Add stage environment Docker and script files ([d6c0b36](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/d6c0b363a811fd5240c45052db8c9961b0e893fc))
* Expose API Gateway via NodePort and enhance config overrides ([525199a](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/525199a668fe799280317b466ba384578e792484))
* Improve service startup order and readiness checks ([fb4fa5b](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/fb4fa5b10684860dc0b4a806927726cb83d40ab5))
* johanaguirre's taller 2 & alejoamu's taller 2 integration ([cd0c474](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/cd0c474342ac783627579d24bd76563bc9ea3188))
* Refactor Docker Compose for core/app separation and network ([b8eccd9](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/b8eccd900ca7a544eca327f80d45cf1622d59427))
* Refactor Terraform infra to modular multi-env structure ([20033dd](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/20033ddf6e75e4976be1ac0f3826d9c20b54b9a5))
* **release-notes:** probar fix de preset conventionalcommits ([9054d04](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/9054d04d6fb24f5c3f26bde5c8ddc9c177f0c0f5))
* **release-notes:** probar generacion de notas en rama feat ([acbb869](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/acbb869e9bcb2a5d0446565ce622a1914909d2dc))
* Remove GitHub Actions CI/CD workflows and add Ansible setup ([a08962f](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/a08962f2ee77af9e4069d4cb31948c077f06fdc9))
* Remove Jenkins, add Locust and Trivy to CI stack ([0e268be](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/0e268befc5f7e10787734310c7e4dd03ccc18a43))

### Bug Fixes

* Add explicit bash shell and improve directory creation in CI ([ab0d7e9](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/ab0d7e93ec40b261b3c8ce3c543198ffa47d583b))
* Add index.html generation for unit-integration and locust reports ([0919844](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/0919844dd698abc395c84cad2151259dac0c03a3))
* Add Java 11 setup and Maven build to CI workflow ([40e5ae8](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/40e5ae87bcb1c307960ba50b7b7239639acb2d6e))
* Add k8s manifests for ecommerce microservices ([9b06362](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/9b063620692e8d2b9bc67ef70cf4ebae914917ce))
* Add product-service startup and readiness check ([7be3ecb](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/7be3ecb0d47ec296b5e404d92628f32bd6e63fcb))
* Ensure directory exists before creating index.html ([43f3fdd](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/43f3fdd2b4700c2a0f5ca23dce3527f735056dd4))
* Improve CI workflows with better readiness checks ([3b44271](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/3b44271b6e2382abc0ed70d40258c5751ef77f4f))
* Improve e2e workflow port-forwarding and diagnostics ([872c9d7](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/872c9d7a1dc2bcd3ee874f0baefed48967703c83))
* Make Locust endpoints configurable via environment variables ([952ae8f](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/952ae8faf246ad9243a842cade42b65ba33a8dff))
* Remove indentation from here-doc HTML in CI workflow ([5e89730](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/5e897308faa547c466b2a549e36576a848df8b28))
* Replace heredoc with printf for HTML file generation ([81360e7](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/81360e7e946d268bb0fd0a023f2a35a5a5ed999d))
* Set explicit host for Locust tests ([749444b](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/749444bec28b967d578892dfd493ffdbb7bc0850))
* solve issues with acces points ([8db7c78](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/8db7c78d694af0b93defa4ccf92ad65b3658c0b1))
* Update Eureka and config env vars in compose files ([5ef3d63](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/5ef3d63703dd92050614b552436338b0be62964e))
* Update kubectl version command in workflow ([fd6bd0f](https://github.com/alejoamu/Proyecto-final-Ingesoft-V/commit/fd6bd0f0f91fb9c285ebfa2af68b637852aab490))

# Changelog

Todas las notas de versión se generan automáticamente mediante semantic-release.

## [Unreleased]
- Inicialización de versionado semántico.
