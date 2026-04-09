# Changelog

## [1.19.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.18.0...1.19.0) (2026-04-09)


### Features

* add --overwrite flag to blob upload commands ([886e526](https://github.com/vergissberlin/azure-cloud-shell-development/commit/886e526c43bf4621ba7285997d2f089efa120b5d))

## [1.18.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.17.0...1.18.0) (2026-04-09)


### Features

* **config-cmd.sh:** add support for APIGEE_TLS_SELF_SIGNED and APIGEE_TLS_SKIP_SELF_SIGNED ([39c53f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/39c53f26e23b662c7d5b6fb2697c085d47dc0122))
* **cshell:** enhance TLS certificate management for non-prod environments ([39c53f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/39c53f26e23b662c7d5b6fb2697c085d47dc0122))
* **hybrid-overrides-nonprod.sh:** add function to sanitize keystore slugs ([39c53f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/39c53f26e23b662c7d5b6fb2697c085d47dc0122))


### Documentation

* **Hybrid-Setup.md:** update TLS setup instructions for clarity and non-prod defaults ([39c53f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/39c53f26e23b662c7d5b6fb2697c085d47dc0122))
* update command and configuration documentation for TLS changes ([39c53f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/39c53f26e23b662c7d5b6fb2697c085d47dc0122))


### Code Refactoring

* **env-file.sh:** introduce cshell_env_upsert_key for key-value management ([39c53f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/39c53f26e23b662c7d5b6fb2697c085d47dc0122))


### Tests

* **cshell_cli.bats:** add tests for hybrid --step 7 TLS generation and skipping ([39c53f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/39c53f26e23b662c7d5b6fb2697c085d47dc0122))
* **hybrid_overrides_nonprod.bats:** add tests for keystore slug sanitization ([39c53f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/39c53f26e23b662c7d5b6fb2697c085d47dc0122))

## [1.17.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.16.0...1.17.0) (2026-04-09)


### Features

* **cshell:** add --step flag to hybrid command for more granular control over execution steps ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))
* **cshell:** add cmd_hybrid_pull_apigee_charts function for pulling Apigee Hybrid OCI charts ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))
* **cshell:** add option to emit specific checklist step ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))
* **cshell:** implement cmd_hybrid_run_step_actions for automated hybrid setup steps ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))
* **cshell:** introduce cmd_hybrid_step for executing specific hybrid setup steps ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))
* **docs:** add detailed explanation for `hybrid --step` command ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))


### Bug Fixes

* **cshell:** validate step number in cmd_hybrid to ensure it is within the valid range ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))


### Code Refactoring

* **cshell:** remove direct helm chart download logic and replace with cmd_hybrid_pull_apigee_charts function call for better modularity ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))


### Tests

* **cshell_cli.bats:** simplify output check by removing redundant condition ([92661d4](https://github.com/vergissberlin/azure-cloud-shell-development/commit/92661d49d99dfefdb17076daee7b99b08f482121))
* **cshell_cli:** add comprehensive tests for hybrid steps ([0ba9fda](https://github.com/vergissberlin/azure-cloud-shell-development/commit/0ba9fda7661e936dbbddb9e760d305a20aeaed46))
* **cshell_cli:** add tests for `hybrid --step` command ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))


### Chores

* **build.status:** remove obsolete build status file ([92661d4](https://github.com/vergissberlin/azure-cloud-shell-development/commit/92661d49d99dfefdb17076daee7b99b08f482121))
* **build:** add build.status file to track build status ([3c8268e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c8268e7760d50adf181d0547cde2db771390fa2))

## [1.16.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.15.3...1.16.0) (2026-04-09)


### Features

* **cshell:** integrate non-prod overrides.yaml settings for Apigee Hybrid ([be84dd6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/be84dd6782fb95717af5567636628bd6c142ade2))
* **lib, install.sh, justfile:** add support for new Apigee configuration options including instance ID, ingress settings, and runtime tuning ([be84dd6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/be84dd6782fb95717af5567636628bd6c142ade2))
* **lib:** add hybrid-overrides-nonprod.sh for non-prod Apigee Hybrid ([be84dd6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/be84dd6782fb95717af5567636628bd6c142ade2))
* **workflow:** add hybrid-overrides-nonprod.sh to standalone build check ([be84dd6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/be84dd6782fb95717af5567636628bd6c142ade2))


### Bug Fixes

* **hybrid-overrides-nonprod.sh:** update comment for clarity on setting CONTROL_PLANE_LOCATION for data residency ([78b79c1](https://github.com/vergissberlin/azure-cloud-shell-development/commit/78b79c1e5766f765eec2702849a56100a76fd8cc))


### Documentation

* **Command-Reference:** update to include non-prod overrides.yaml settings ([be84dd6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/be84dd6782fb95717af5567636628bd6c142ade2))
* **Configuration.md, Hybrid-Setup.md, Release-and-CI.md:** update documentation to include new Apigee configuration options and clarify existing ones ([be84dd6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/be84dd6782fb95717af5567636628bd6c142ade2))
* **README.md:** clarify CONTROL_PLANE_LOCATION description and add note on optional Helm variables ([78b79c1](https://github.com/vergissberlin/azure-cloud-shell-development/commit/78b79c1e5766f765eec2702849a56100a76fd8cc))


### Tests

* **hybrid_overrides_nonprod:** add bats tests for hybrid overrides ([be84dd6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/be84dd6782fb95717af5567636628bd6c142ade2))


### Build System

* **scripts:** include hybrid-overrides-nonprod.sh in build process ([be84dd6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/be84dd6782fb95717af5567636628bd6c142ade2))


### Chores

* **lib/config-cmd.sh, lib/env-file.sh:** update allowed keys and configuration commands to support new Apigee options ([be84dd6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/be84dd6782fb95717af5567636628bd6c142ade2))

## [1.15.3](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.15.2...1.15.3) (2026-04-09)


### Documentation

* **Command-Reference.md, Hybrid-Setup.md:** update documentation to reflect new checklist formatting ([7fb8859](https://github.com/vergissberlin/azure-cloud-shell-development/commit/7fb88598d91ab3d313926c82800648f2f42e1041))


### Styles

* **cshell:** improve alignment and formatting of checklist output ([7fb8859](https://github.com/vergissberlin/azure-cloud-shell-development/commit/7fb88598d91ab3d313926c82800648f2f42e1041))

## [1.15.2](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.15.1...1.15.2) (2026-04-09)


### Documentation

* **Hybrid-Setup.md:** update checklist symbols for clarity ([8578912](https://github.com/vergissberlin/azure-cloud-shell-development/commit/8578912df88c8fcf4c4c45acfae74b6dc2f5854d))
* update checklist symbols in README and Command-Reference ([8578912](https://github.com/vergissberlin/azure-cloud-shell-development/commit/8578912df88c8fcf4c4c45acfae74b6dc2f5854d))


### Tests

* **cshell_cli.bats:** adjust test expectations for new checklist symbols ([8578912](https://github.com/vergissberlin/azure-cloud-shell-development/commit/8578912df88c8fcf4c4c45acfae74b6dc2f5854d))
* **cshell_cli.bats:** fix string matching for checklist output ([5539a9b](https://github.com/vergissberlin/azure-cloud-shell-development/commit/5539a9b786d5a0c11f706f37857d63fb60e99af2))

## [1.15.1](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.15.0...1.15.1) (2026-04-09)


### Documentation

* **env-file.sh:** add usage comment for loading shell export snippet ([f63b246](https://github.com/vergissberlin/azure-cloud-shell-development/commit/f63b246d78ce92a65d8c3728cfb55116b87170c2))
* update README and documentation for shell hooks ([f63b246](https://github.com/vergissberlin/azure-cloud-shell-development/commit/f63b246d78ce92a65d8c3728cfb55116b87170c2))


### Tests

* **cshell_config.bats:** add test for env export hooks in bashrc/profile ([f63b246](https://github.com/vergissberlin/azure-cloud-shell-development/commit/f63b246d78ce92a65d8c3728cfb55116b87170c2))

## [1.15.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.14.0...1.15.0) (2026-04-09)


### Features

* **cshell:** add support for AKS kubeconfig merge ([ee0154c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ee0154cf549e40dab84a98307b0fef698111f16f))
* **lib:** add script to merge AKS credentials into kubeconfig ([ee0154c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ee0154cf549e40dab84a98307b0fef698111f16f))


### Documentation

* update documentation for AKS integration ([ee0154c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ee0154cf549e40dab84a98307b0fef698111f16f))


### Code Refactoring

* **hybrid-aks-kubeconfig.sh:** replace command_exists with direct command check for az to simplify code ([fac90ba](https://github.com/vergissberlin/azure-cloud-shell-development/commit/fac90ba94c9966e36ac7890fe32f6b4d7cf1807e))


### Tests

* add config set test for AKS_RESOURCE_GROUP ([ee0154c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ee0154cf549e40dab84a98307b0fef698111f16f))
* add tests for hybrid AKS kubeconfig script ([ee0154c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ee0154cf549e40dab84a98307b0fef698111f16f))


### Build System

* include hybrid-aks-kubeconfig in standalone scripts ([ee0154c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ee0154cf549e40dab84a98307b0fef698111f16f))
* include hybrid-aks-kubeconfig.sh in shell scripts ([ee0154c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ee0154cf549e40dab84a98307b0fef698111f16f))


### Chores

* **tests:** remove unused portable.sh source from test scripts to clean up dependencies ([fac90ba](https://github.com/vergissberlin/azure-cloud-shell-development/commit/fac90ba94c9966e36ac7890fe32f6b4d7cf1807e))

## [1.14.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.13.0...1.14.0) (2026-04-09)


### Features

* **cshell:** add cshell_cli_colors_active function to check if colors are active ([6a6d432](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6a6d432e321c4f0a94fe6eb1aa6e4148b8109cd2))
* **cshell:** add JSON escape function for safe string handling ([404dd6d](https://github.com/vergissberlin/azure-cloud-shell-development/commit/404dd6d5a6b4131b25bc0b92a36eb3fc0ec2c48e))
* **cshell:** add JSON output option for hybrid checklist ([404dd6d](https://github.com/vergissberlin/azure-cloud-shell-development/commit/404dd6d5a6b4131b25bc0b92a36eb3fc0ec2c48e))


### Bug Fixes

* **cshell:** conditionally set dim variable based on color activity ([6a6d432](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6a6d432e321c4f0a94fe6eb1aa6e4148b8109cd2))
* **cshell:** strip ANSI colors for non-TTY and NO_COLOR ([404dd6d](https://github.com/vergissberlin/azure-cloud-shell-development/commit/404dd6d5a6b4131b25bc0b92a36eb3fc0ec2c48e))


### Documentation

* **Command-Reference.md, Hybrid-Setup.md:** update documentation to include NO_COLOR and JSON output options for hybrid --check command ([404dd6d](https://github.com/vergissberlin/azure-cloud-shell-development/commit/404dd6d5a6b4131b25bc0b92a36eb3fc0ec2c48e))
* **cshell:** update usage and exit codes for hybrid command ([404dd6d](https://github.com/vergissberlin/azure-cloud-shell-development/commit/404dd6d5a6b4131b25bc0b92a36eb3fc0ec2c48e))


### Tests

* **cshell_cli.bats:** add tests for NO_COLOR and JSON output options in hybrid --check command ([404dd6d](https://github.com/vergissberlin/azure-cloud-shell-development/commit/404dd6d5a6b4131b25bc0b92a36eb3fc0ec2c48e))
* **cshell_cli:** update tests to verify NO_COLOR handling and improve subprocess isolation ([6a6d432](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6a6d432e321c4f0a94fe6eb1aa6e4148b8109cd2))

## [1.13.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.12.0...1.13.0) (2026-04-09)


### Features

* **cshell:** add dimmed Doc URL line to checklist steps ([4052bf2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/4052bf2a55f3a28fdfd3c932dec9289983101393))
* **cshell:** ensure helm_charts_home is set to default if input is empty ([c3bd987](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c3bd98753fcb8746caa8930369a5b262ad1d5573))


### Bug Fixes

* **cshell:** trim whitespace from helm_charts_home input to prevent errors ([c3bd987](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c3bd98753fcb8746caa8930369a5b262ad1d5573))


### Code Refactoring

* **cshell:** move mkdir command to ensure directory creation after validation ([c3bd987](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c3bd98753fcb8746caa8930369a5b262ad1d5573))

## [1.12.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.11.1...1.12.0) (2026-04-09)


### Features

* **setup:** set default Helm charts directory to ~/apigee-hybrid/helm-charts ([93b9a64](https://github.com/vergissberlin/azure-cloud-shell-development/commit/93b9a6418f41aa1b4bd5c77a9472300c1d3a0cb8))


### Documentation

* update documentation to reflect new default Helm charts directory ([93b9a64](https://github.com/vergissberlin/azure-cloud-shell-development/commit/93b9a6418f41aa1b4bd5c77a9472300c1d3a0cb8))


### Chores

* update cshell script to use new default Helm charts directory ([93b9a64](https://github.com/vergissberlin/azure-cloud-shell-development/commit/93b9a6418f41aa1b4bd5c77a9472300c1d3a0cb8))

## [1.11.1](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.11.0...1.11.1) (2026-04-09)


### Documentation

* **Troubleshooting.md:** add section for handling missing cshell binary error ([1dc884f](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1dc884fe432458c7daf6bf08ff8b5eb3e0988ec4))

## [1.11.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.10.0...1.11.0) (2026-04-09)


### Features

* add validation steps for hybrid deployment ([ed67bb7](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ed67bb7e17ec7c8198a8148ccaf2b66754317925))
* **build-standalone-scripts.sh:** add hybrid-checklist.sh to LIB_FILES for enhanced functionality ([ed67bb7](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ed67bb7e17ec7c8198a8148ccaf2b66754317925))
* **cshell:** integrate hybrid-checklist.sh for enhanced checklist validation ([ed67bb7](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ed67bb7e17ec7c8198a8148ccaf2b66754317925))
* **lib:** add hybrid-checklist.sh for automated Apigee Hybrid install checks ([ed67bb7](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ed67bb7e17ec7c8198a8148ccaf2b66754317925))


### Bug Fixes

* **cshell:** remove existing chart directories before pulling to prevent errors during re-runs or partial pulls ([8157d26](https://github.com/vergissberlin/azure-cloud-shell-development/commit/8157d267bc65d64777d1089c7e8e18d5b98f7702))
* **hybrid-checklist.sh:** add missing braces for conditional blocks to improve code clarity and consistency ([e18d421](https://github.com/vergissberlin/azure-cloud-shell-development/commit/e18d421da4fe89903c8404b71df59c707e3093c3))
* **tests:** ensure core utilities are available in CI by appending symlinks to PATH ([906bcec](https://github.com/vergissberlin/azure-cloud-shell-development/commit/906bcece3c4f4cb5574564e496349cb422b52741))


### Documentation

* update Hybrid-Setup.md with checklist automation details ([47fb090](https://github.com/vergissberlin/azure-cloud-shell-development/commit/47fb090c2edd40cd86a517663a1fcb8ebce77175))
* update README and command reference for enhanced checklist ([47fb090](https://github.com/vergissberlin/azure-cloud-shell-development/commit/47fb090c2edd40cd86a517663a1fcb8ebce77175))
* update Release-and-CI.md for hybrid-checklist.sh inclusion ([47fb090](https://github.com/vergissberlin/azure-cloud-shell-development/commit/47fb090c2edd40cd86a517663a1fcb8ebce77175))


### Code Refactoring

* **cshell:** move strict banner info message to improve readability and reduce redundancy ([e18d421](https://github.com/vergissberlin/azure-cloud-shell-development/commit/e18d421da4fe89903c8404b71df59c707e3093c3))
* **tests:** use run_cshell_with_path to simplify PATH handling ([906bcec](https://github.com/vergissberlin/azure-cloud-shell-development/commit/906bcece3c4f4cb5574564e496349cb422b52741))


### Tests

* **cshell_cli.bats:** add tests for hybrid --check --strict command to ensure proper functionality and error handling ([ed67bb7](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ed67bb7e17ec7c8198a8148ccaf2b66754317925))
* **cshell_cli.bats:** update test to remove unnecessary checklist marker ([ed67bb7](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ed67bb7e17ec7c8198a8148ccaf2b66754317925))
* refactor path handling in cshell_cli.bats for clarity ([47fb090](https://github.com/vergissberlin/azure-cloud-shell-development/commit/47fb090c2edd40cd86a517663a1fcb8ebce77175))


### Continuous Integration

* **workflows:** add hybrid-checklist.sh to standalone build check for improved validation ([ed67bb7](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ed67bb7e17ec7c8198a8148ccaf2b66754317925))


### Chores

* **hybrid-checklist.sh:** add comments and disable shellcheck warning for ORG_NAME usage to clarify code intent and prevent false positives ([e18d421](https://github.com/vergissberlin/azure-cloud-shell-development/commit/e18d421da4fe89903c8404b71df59c707e3093c3))

## [1.10.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.9.0...1.10.0) (2026-04-09)


### Features

* **cshell:** add detailed install checklist for hybrid setup ([72a47be](https://github.com/vergissberlin/azure-cloud-shell-development/commit/72a47be68421b4f90338c1acfa31f540a1a269c5))
* **hybrid:** add --export and --export --print ([40a197f](https://github.com/vergissberlin/azure-cloud-shell-development/commit/40a197ffec7135ef944016a8202ab645b3c8bdce))


### Documentation

* update README and command reference for hybrid checklist ([72a47be](https://github.com/vergissberlin/azure-cloud-shell-development/commit/72a47be68421b4f90338c1acfa31f540a1a269c5))


### Tests

* **cshell_cli.bats:** add assertions for install checklist output ([72a47be](https://github.com/vergissberlin/azure-cloud-shell-development/commit/72a47be68421b4f90338c1acfa31f540a1a269c5))
* **cshell_cli.bats:** simplify export file existence and content check ([72a47be](https://github.com/vergissberlin/azure-cloud-shell-development/commit/72a47be68421b4f90338c1acfa31f540a1a269c5))

## [1.9.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.8.0...1.9.0) (2026-04-09)


### Features

* **cshell:** regenerate env export script for bash 4+ support ([c346f9c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c346f9cfd9f25ce20b1f38649391b10ec76f511f))


### Documentation

* add policy for requiring automated tests for behavior changes ([f0241c1](https://github.com/vergissberlin/azure-cloud-shell-development/commit/f0241c115dffb488d7311b76919fac1afdae8fd5))
* **Contributing.md:** add guidelines for tests to ensure behavioral changes include tests and maintain green status ([149a27b](https://github.com/vergissberlin/azure-cloud-shell-development/commit/149a27b1374cfd918a3d31c93bd5f1f3264b0892))


### Tests

* **cshell_cli.bats:** add test for config set to refresh env exports ([c346f9c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c346f9cfd9f25ce20b1f38649391b10ec76f511f))

## [1.8.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.7.0...1.8.0) (2026-04-09)


### Features

* **cshell:** add `hybrid --check` command for env validation ([24d9411](https://github.com/vergissberlin/azure-cloud-shell-development/commit/24d9411513459772b3afde6a3ec2e31afc423f3b))
* **cshell:** add APIGEE_HELM_CHARTS_HOME setup and export ([7827d5f](https://github.com/vergissberlin/azure-cloud-shell-development/commit/7827d5f11cefd3dfc11307dea42925d0ff2c17a0))


### Bug Fixes

* **cshell:** change default ENV_GROUP value to 'envgroup' to ensure consistency with documentation ([ea3b467](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ea3b46727cc838f45557f13cc502bb3f06acc5b4))
* **cshell:** escape dollar sign in bashrc export snippet to ensure correct variable expansion ([b47ce6e](https://github.com/vergissberlin/azure-cloud-shell-development/commit/b47ce6efa1f7b911910c0e68fe2b7e8dde6599e2))
* **README.md, cshell:** update default Helm release name for apigee-virtualhost to 'apigee-virtualhost' for consistency and clarity ([abba923](https://github.com/vergissberlin/azure-cloud-shell-development/commit/abba9237b493b0d5f3b96c5d8dd52598a9dc4b91))


### Documentation

* **README.md, Configuration.md:** update default value for CONTROL_PLANE_LOCATION to 'europe-west3' for clarity ([d1a2142](https://github.com/vergissberlin/azure-cloud-shell-development/commit/d1a2142e01c659380794c2caab1a11cdc25db652))
* **README.md:** update default Apigee environment name to 'non-prod' for consistency with non-production setups ([ea9c866](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ea9c8666d30e4fd76f7480788449b0d98e0a1eb5))
* **README.md:** update default value for ENV_GROUP to 'envgroup' for clarity ([ea3b467](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ea3b46727cc838f45557f13cc502bb3f06acc5b4))
* update markdown formatting for tables in CONTRIBUTING.md and README.md ([01b2783](https://github.com/vergissberlin/azure-cloud-shell-development/commit/01b2783be72a066029fafaad3e568cc7de9e7d65))
* update README and Command-Reference for `hybrid --check` ([24d9411](https://github.com/vergissberlin/azure-cloud-shell-development/commit/24d9411513459772b3afde6a3ec2e31afc423f3b))


### Tests

* **cshell_cli:** add tests for `hybrid --check` command ([24d9411](https://github.com/vergissberlin/azure-cloud-shell-development/commit/24d9411513459772b3afde6a3ec2e31afc423f3b))


### Chores

* **cshell:** change default Apigee environment name to 'non-prod' to align with updated documentation and typical non-production configurations ([ea9c866](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ea9c8666d30e4fd76f7480788449b0d98e0a1eb5))
* **cshell:** set default control plane location to 'europe-west3' in interactive mode to streamline configuration ([d1a2142](https://github.com/vergissberlin/azure-cloud-shell-development/commit/d1a2142e01c659380794c2caab1a11cdc25db652))
* **justfile:** add alias for test command to simplify running bats tests ([926a3be](https://github.com/vergissberlin/azure-cloud-shell-development/commit/926a3bec409ad4ae3238f00afb306e287671dd8b))

## [1.7.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.6.0...1.7.0) (2026-04-09)


### Features

* **cshell:** add function to download support libs from raw GitHub ([81811e3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/81811e39556e918442a0f3e2581a85f17dd48bd6))


### Documentation

* update documentation for raw fallback library download ([81811e3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/81811e39556e918442a0f3e2581a85f17dd48bd6))

## [1.6.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.5.0...1.6.0) (2026-04-09)


### Features

* add new Apigee Hybrid environment variables ([c1cc249](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c1cc2492e7891f7030c808e2ba6d532106954fc7))
* **cshell:** implement non-interactive setup mode and Helm version check ([9ab8619](https://github.com/vergissberlin/azure-cloud-shell-development/commit/9ab8619cef2cd45cad4dd84df910284a89cc4812))


### Documentation

* **Command-Reference.md:** update setup requirements and non-interactive mode details ([9ab8619](https://github.com/vergissberlin/azure-cloud-shell-development/commit/9ab8619cef2cd45cad4dd84df910284a89cc4812))
* **Configuration.md:** convert variable list to tables for clarity and add descriptions ([1f8a7ce](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1f8a7cee5ed80483f3e6273afba1f06dd04bfc6d))
* **Hybrid-Setup.md:** add detailed requirements and installation steps for Apigee Hybrid v1.16 ([9ab8619](https://github.com/vergissberlin/azure-cloud-shell-development/commit/9ab8619cef2cd45cad4dd84df910284a89cc4812))
* **README.md:** add prerequisites and detailed documentation links for Apigee Hybrid setup ([9ab8619](https://github.com/vergissberlin/azure-cloud-shell-development/commit/9ab8619cef2cd45cad4dd84df910284a89cc4812))

## [1.5.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.4.0...1.5.0) (2026-04-09)


### Features

* **config-cmd.sh:** add config command for managing environment ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **cshell:** add 'config' command to CSHELL_COMMANDS ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **cshell:** add config command to manage environment file settings ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **cshell:** add dry-run and verbose options to backup and restore commands for safer operations ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **cshell:** add update check caching and configurable TTL ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **cshell:** implement no-update-check global option to skip update checks ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **install.sh:** add functions for verified release installation ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **justfile:** add justfile for task automation including build, lint, and test tasks ([79b0281](https://github.com/vergissberlin/azure-cloud-shell-development/commit/79b02816256dca0e3815686e504c1c20e6780243))
* **lib:** add env-file.sh and portable.sh for environment management and portability ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))


### Bug Fixes

* **cshell:** add shellcheck directive to prevent false positive warnings ([79b0281](https://github.com/vergissberlin/azure-cloud-shell-development/commit/79b02816256dca0e3815686e504c1c20e6780243))
* **cshell:** change default analytics region to europe-west3 to align with updated documentation ([e93580d](https://github.com/vergissberlin/azure-cloud-shell-development/commit/e93580dd2da165c46ae4458bdd532f64f3a7ac29))
* **cshell:** enhance error handling and messaging for unknown options ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **cshell:** ensure environment file permissions ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **cshell:** ensure permissions on environment file after writing to prevent access issues ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **env-file.sh:** adjust shellcheck directives for dynamic variable handling ([79b0281](https://github.com/vergissberlin/azure-cloud-shell-development/commit/79b02816256dca0e3815686e504c1c20e6780243))


### Performance Improvements

* **cshell:** optimize release asset download and verification ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))


### Documentation

* **_Sidebar.md:** update sidebar to include link to wiki guidelines for easy access ([b5e0799](https://github.com/vergissberlin/azure-cloud-shell-development/commit/b5e07997cef758dc4eb1b8256da588abdcd7d70e))
* add comprehensive documentation for cshell ([6122cbc](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6122cbcb1c36fbadf4a3ec6346654fc569fff9a5))
* add comprehensive documentation for installation, release, and troubleshooting ([6122cbc](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6122cbcb1c36fbadf4a3ec6346654fc569fff9a5))
* add security and inspection guidelines for configuration ([6be8809](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6be88093a90bb603c90cfd9fdec5073497b415ec))
* **AGENTS.md:** add sections on wiki documentation, style, tooling, and commit messages to guide contributors ([b5e0799](https://github.com/vergissberlin/azure-cloud-shell-development/commit/b5e07997cef758dc4eb1b8256da588abdcd7d70e))
* **Contributing.md:** include reference to wiki guidelines for editing GitHub Wiki content ([b5e0799](https://github.com/vergissberlin/azure-cloud-shell-development/commit/b5e07997cef758dc4eb1b8256da588abdcd7d70e))
* **CONTRIBUTING.md:** update contribution guidelines for clarity and completeness ([85e4ec1](https://github.com/vergissberlin/azure-cloud-shell-development/commit/85e4ec165442fec66305a0dc054c42b6666062b3))
* **contributing:** add instructions for using 'just doctor' to check tool availability ([3972a69](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3972a692648ae5ce47752a96999e1599f3d27f5f))
* **contributing:** update testing instructions with just task runner usage ([79b0281](https://github.com/vergissberlin/azure-cloud-shell-development/commit/79b02816256dca0e3815686e504c1c20e6780243))
* enhance installation instructions with checksum verification ([6be8809](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6be88093a90bb603c90cfd9fdec5073497b415ec))
* **Home.md:** add link to wiki guidelines for better navigation ([b5e0799](https://github.com/vergissberlin/azure-cloud-shell-development/commit/b5e07997cef758dc4eb1b8256da588abdcd7d70e))
* **README.md:** enhance installation and usage instructions with more details and examples ([85e4ec1](https://github.com/vergissberlin/azure-cloud-shell-development/commit/85e4ec165442fec66305a0dc054c42b6666062b3))
* **README.md:** update default analytics region to europe-west3 for consistency ([e93580d](https://github.com/vergissberlin/azure-cloud-shell-development/commit/e93580dd2da165c46ae4458bdd532f64f3a7ac29))
* **README.md:** update default Kubernetes cluster name to 'aks-hybrid' for consistency with Azure Kubernetes Service naming conventions ([4c4dcec](https://github.com/vergissberlin/azure-cloud-shell-development/commit/4c4dcec63bd8024b29f4e5fa3458a165796952b7))
* update command reference with new options and config commands ([6be8809](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6be88093a90bb603c90cfd9fdec5073497b415ec))
* update hybrid setup instructions for safer variable handling ([6be8809](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6be88093a90bb603c90cfd9fdec5073497b415ec))
* update release and CI documentation with new workflows ([6be8809](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6be88093a90bb603c90cfd9fdec5073497b415ec))
* **Wiki-Guidelines.md:** create guidelines for managing and editing GitHub Wiki content ([b5e0799](https://github.com/vergissberlin/azure-cloud-shell-development/commit/b5e07997cef758dc4eb1b8256da588abdcd7d70e))


### Styles

* **build-standalone-scripts.sh:** convert spaces to tabs for consistency ([f9442f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/f9442f2d280a4db00db9d221e216dc9311527678))
* **config-cmd.sh:** convert spaces to tabs for consistent indentation ([c4cef3c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c4cef3cb0f69b610ce94ac95441d4a6dfd829c09))
* **cshell:** convert spaces to tabs for consistent indentation throughout the script ([f74b251](https://github.com/vergissberlin/azure-cloud-shell-development/commit/f74b25110f5e86a97040a4cfa26354ddcbd939f8))
* **cshell:** improve code readability with consistent formatting and spacing ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **env-file.sh, portable.sh:** convert indentation to tabs for consistency ([c4cef3c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c4cef3cb0f69b610ce94ac95441d4a6dfd829c09))
* **install.sh:** convert indentation from spaces to tabs for consistency ([038ae36](https://github.com/vergissberlin/azure-cloud-shell-development/commit/038ae36764275d3b1d38699ffcc1a4f75bb61fc8))
* **install.sh:** convert spaces to tabs for consistent indentation ([038ae36](https://github.com/vergissberlin/azure-cloud-shell-development/commit/038ae36764275d3b1d38699ffcc1a4f75bb61fc8))


### Code Refactoring

* **cshell:** improve update process with verified release tarball support ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **cshell:** modularize and improve code readability ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))
* **cshell:** replace echo with printf for better formatting consistency ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))


### Tests

* **cshell_cli.bats:** add basic smoke tests for cshell functionality ([f9442f2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/f9442f2d280a4db00db9d221e216dc9311527678))
* **cshell_cli.bats:** update test to check for 'vergissberlin' instead of 'README' ([3972a69](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3972a692648ae5ce47752a96999e1599f3d27f5f))
* **cshell_cli:** enhance test coverage and refactor for clarity ([3f3a509](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3f3a5095421f5558b5a19b37ed888793c39cc405))
* **cshell_config.bats:** refine output checks for 'config' command tests ([3972a69](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3972a692648ae5ce47752a96999e1599f3d27f5f))
* **cshell_restore.bats:** add new tests for restore and backup commands ([3972a69](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3972a692648ae5ce47752a96999e1599f3d27f5f))


### Build System

* **justfile:** add 'doctor' recipe to verify tool visibility in PATH ([3972a69](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3972a692648ae5ce47752a96999e1599f3d27f5f))
* **scripts:** enhance build-standalone-scripts.sh to inline libraries ([37cec84](https://github.com/vergissberlin/azure-cloud-shell-development/commit/37cec8404d64ff524b006680255dd8e6242d6b76))


### Continuous Integration

* **release-build-assets:** include checksum files for verification ([1eb13c3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1eb13c302588612fdaf536736c6d962c3987f1c7))
* **standalone-build-check:** add shell linting and Bats smoke tests ([1eb13c3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1eb13c302588612fdaf536736c6d962c3987f1c7))
* **version-sync-check:** add concurrency control and timeout limit ([1eb13c3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1eb13c302588612fdaf536736c6d962c3987f1c7))
* **wiki-sync:** add concurrency control, timeout, and permissions ([1eb13c3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1eb13c302588612fdaf536736c6d962c3987f1c7))
* **workflow:** add wiki-sync GitHub Action for docs synchronization ([6122cbc](https://github.com/vergissberlin/azure-cloud-shell-development/commit/6122cbcb1c36fbadf4a3ec6346654fc569fff9a5))
* **workflows:** add concurrency control to prevent overlapping runs ([1eb13c3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1eb13c302588612fdaf536736c6d962c3987f1c7))
* **workflows:** add timeout limits to prevent long-running jobs ([1eb13c3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1eb13c302588612fdaf536736c6d962c3987f1c7))
* **workflows:** update actions to specific commit hashes for stability ([1eb13c3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1eb13c302588612fdaf536736c6d962c3987f1c7))
* **workflow:** update bats test path to run all tests in directory ([3972a69](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3972a692648ae5ce47752a96999e1599f3d27f5f))


### Chores

* add .gitignore file to exclude build artifacts and logs ([038ae36](https://github.com/vergissberlin/azure-cloud-shell-development/commit/038ae36764275d3b1d38699ffcc1a4f75bb61fc8))
* **cshell:** change default Kubernetes cluster name to 'aks-hybrid' to align with updated documentation and improve clarity ([4c4dcec](https://github.com/vergissberlin/azure-cloud-shell-development/commit/4c4dcec63bd8024b29f4e5fa3458a165796952b7))
* **editorconfig:** add .editorconfig file to enforce consistent coding style across editors ([b5e0799](https://github.com/vergissberlin/azure-cloud-shell-development/commit/b5e07997cef758dc4eb1b8256da588abdcd7d70e))
* **gitignore:** add .bats-core/ to ignore list for local bats-core dependencies ([79b0281](https://github.com/vergissberlin/azure-cloud-shell-development/commit/79b02816256dca0e3815686e504c1c20e6780243))

## [1.4.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.3.0...1.4.0) (2026-04-09)


### Features

* **cshell:** add automatic bash completion setup in .bashrc ([1fde870](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1fde8700cda0503af4e1644fb2f6459e858e3c86))


### Bug Fixes

* **cshell:** prevent redundant copying of script if already installed ([9609246](https://github.com/vergissberlin/azure-cloud-shell-development/commit/9609246eb6414645614c676cc789ed61d6e31857))


### Code Refactoring

* **cshell:** remove zsh and oh-my-zsh installation and support ([7fc1303](https://github.com/vergissberlin/azure-cloud-shell-development/commit/7fc1303e4558c4b1905f90c9b649aee09fb48143))

## [1.3.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.2.0...1.3.0) (2026-04-09)


### Features

* **cshell:** add `docs` command to print project and Apigee documentation links ([053333c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/053333ca0776ebbb4b07c2e5452ed6ffac191ea5))


### Documentation

* **cshell:** add additional documentation links to cmd_hybrid function for better guidance ([9ad9d76](https://github.com/vergissberlin/azure-cloud-shell-development/commit/9ad9d76e0e4d7c70c4f36d41ad5faa61e2158106))
* **cshell:** add links to project README, releases, issues, and contributing guide to enhance user accessibility and provide comprehensive project documentation ([1cc582a](https://github.com/vergissberlin/azure-cloud-shell-development/commit/1cc582aeba32717b02b0393584cb84a869a74862))
* **README.md:** update README with information about the new `cshell docs` command ([053333c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/053333ca0776ebbb4b07c2e5452ed6ffac191ea5))

## [1.2.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.1.0...1.2.0) (2026-04-09)


### Features

* **cshell:** add shell autocomplete for Bash and Zsh ([215dce4](https://github.com/vergissberlin/azure-cloud-shell-development/commit/215dce466178fa7f70a4d328d53e7f49666b4fe4))
* **cshell:** add update command to update cshell to latest release ([3c66cc3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c66cc307f6a07f3d22a6aec491f3ccdcdff831b))
* **cshell:** implement version check and update notice for commands ([3c66cc3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c66cc307f6a07f3d22a6aec491f3ccdcdff831b))
* **scripts:** add build-standalone-scripts.sh to generate standalone scripts ([7178080](https://github.com/vergissberlin/azure-cloud-shell-development/commit/71780805a4b14ec7ad32f5921922943c4effb4c4))
* **workflows:** add standalone-build-check for PRs and main branch ([7178080](https://github.com/vergissberlin/azure-cloud-shell-development/commit/71780805a4b14ec7ad32f5921922943c4effb4c4))


### Bug Fixes

* **cshell:** ensure update command handles missing curl gracefully ([3c66cc3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c66cc307f6a07f3d22a6aec491f3ccdcdff831b))


### Documentation

* **README:** add section on build model for source vs generated assets ([7178080](https://github.com/vergissberlin/azure-cloud-shell-development/commit/71780805a4b14ec7ad32f5921922943c4effb4c4))
* **README:** document new update command and update notice feature ([3c66cc3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c66cc307f6a07f3d22a6aec491f3ccdcdff831b))
* **README:** update setup steps to include autocomplete installation ([215dce4](https://github.com/vergissberlin/azure-cloud-shell-development/commit/215dce466178fa7f70a4d328d53e7f49666b4fe4))


### Styles

* **cshell:** update terminology for consistency and clarity in messages ([3a78bc1](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3a78bc19df8936eab214e381afcb26e90461cb16))


### Code Refactoring

* **cli-utils:** simplify header function by removing boxen-style borders for a more compact display ([ddfde29](https://github.com/vergissberlin/azure-cloud-shell-development/commit/ddfde29d650e4357de0287ee5e3a134c827e9faf))
* **cshell:** improve update target path resolution logic ([3c66cc3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/3c66cc307f6a07f3d22a6aec491f3ccdcdff831b))


### Continuous Integration

* **version-sync-check:** add GitHub Actions workflow to ensure version consistency ([b714199](https://github.com/vergissberlin/azure-cloud-shell-development/commit/b7141995d70361116a3a0ac26e46677853883ee9))
* **workflows:** update release-build-assets to use build script for standalone scripts ([7178080](https://github.com/vergissberlin/azure-cloud-shell-development/commit/71780805a4b14ec7ad32f5921922943c4effb4c4))


### Chores

* **cshell, install.sh:** add CLI utils fallback for standalone execution ([7178080](https://github.com/vergissberlin/azure-cloud-shell-development/commit/71780805a4b14ec7ad32f5921922943c4effb4c4))
* update release-please configuration to use generic type for cshell and increment version to 1.1.0 ([c2651b9](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c2651b98eefc26fa63370bf92f8d7ce483b3ab3f))

## [1.1.0](https://github.com/vergissberlin/azure-cloud-shell-development/compare/1.0.0...1.1.0) (2026-04-09)


### Features

* add Azure Cloud Shell detection to enhance installation process and user guidance ([0140c64](https://github.com/vergissberlin/azure-cloud-shell-development/commit/0140c6484c104ab690a2d43e0285bb80f26600ef))
* add CONTRIBUTING.md, curl install script, and `cshell init` command ([e86b7e8](https://github.com/vergissberlin/azure-cloud-shell-development/commit/e86b7e8d9392ea1c24461846b44627eb36bde85d))
* add CONTRIBUTING.md, install.sh, and cshell init command ([051ed37](https://github.com/vergissberlin/azure-cloud-shell-development/commit/051ed3761a95f8c91ba877531448fd69e961db3c))
* add support for cross-tenant replication in cshell init command ([c0233e4](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c0233e40b2df9c0b487e21b02ea07d42cd89991d))
* add support for resolving Azure Storage Account key for authentication fallback in cshell ([80be229](https://github.com/vergissberlin/azure-cloud-shell-development/commit/80be22946ddb6c5807f9b1bf8df9cbb21fea4a2a))
* add versioning support to cshell and enhance installation script to display installed version ([2f4fefe](https://github.com/vergissberlin/azure-cloud-shell-development/commit/2f4fefe3eaf7cbbb95e501499dc30927c7afcfcc))
* enhance cshell init command to include storage access tier and improve user prompts for storage SKU ([01614ae](https://github.com/vergissberlin/azure-cloud-shell-development/commit/01614ae9f8d01fc354dbf67bd254f0aa98b82cbb))
* enhance cshell installation process to support user-specific installation paths and improve architecture detection for gcloud CLI ([869955b](https://github.com/vergissberlin/azure-cloud-shell-development/commit/869955b3d7c3bf224a994f9149df73a615fe4bfb))
* enhance installation process with updated install script and improved cshell init command ([a9af09c](https://github.com/vergissberlin/azure-cloud-shell-development/commit/a9af09cf4c5cf8cd21b29c31de45d9c2ddf2d3d8))
* implement Azure Storage Account key resolution for improved authentication in cshell ([87b93d2](https://github.com/vergissberlin/azure-cloud-shell-development/commit/87b93d2ff6d0565ea8472096ce57e51409cbe8ec))
* implement blob upload and download functions with fallback support for Azure Storage ([33d233d](https://github.com/vergissberlin/azure-cloud-shell-development/commit/33d233d33d64788818f679b37bbaf802eebe69ce))
* update README to include information about GitHub Actions uploading release assets ([cb8b7f7](https://github.com/vergissberlin/azure-cloud-shell-development/commit/cb8b7f78d1b57d2c701b3d998bad1404569253cf))


### Bug Fixes

* restrict package manager installation commands to root users and improve error messaging for non-root environments ([f996af3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/f996af3bc8fcdbe4ba1550af8c55dd89310137ef))
* update default resource group name in cshell init command and README ([64af707](https://github.com/vergissberlin/azure-cloud-shell-development/commit/64af70773812c60fb7dda3265ca59619aec0b83e))
* update install script to support fallback installation directory and improve user guidance ([a5392c6](https://github.com/vergissberlin/azure-cloud-shell-development/commit/a5392c65227c5b2a01a87df45b0e0d6afd1543fa))
* update installation instructions and enhance cshell setup process with additional package manager support ([c4c6d63](https://github.com/vergissberlin/azure-cloud-shell-development/commit/c4c6d63e787daef9833f6cd231274eeefc5f8df7))


### Code Refactoring

* enhance output formatting and streamline section handling in cshell and install scripts ([8377c94](https://github.com/vergissberlin/azure-cloud-shell-development/commit/8377c948a19fd13336256beb18631052c8b9ccc0))
* improve section formatting in cshell and install scripts for better readability and customization ([5fe2bd3](https://github.com/vergissberlin/azure-cloud-shell-development/commit/5fe2bd38c2b41561a057caa9d7550c9ebbbab29f))
* standardize CLI output and improve script structure by integrating shared utility functions ([060cf02](https://github.com/vergissberlin/azure-cloud-shell-development/commit/060cf020b76b9e31f89d64b6c5b9674bca2123e1))
* streamline script source resolution and improve header formatting in cshell and install scripts ([23bfdaf](https://github.com/vergissberlin/azure-cloud-shell-development/commit/23bfdaf5d2c261151435a7750f657090df72bc42))


### Chores

* add conditional token handling for release-please action in GitHub Actions workflow ([525ac24](https://github.com/vergissberlin/azure-cloud-shell-development/commit/525ac24d787197bf14a74063119a4aab2a5fc235))
* update cshell version to 1.0.0 and enhance install script to resolve latest release tag automatically ([b41115a](https://github.com/vergissberlin/azure-cloud-shell-development/commit/b41115a1cabd437cbc92cc162ca706d0ed5fa2fe))

## Changelog

All notable changes to this project are documented in this file.

This file is managed by Release Please.
