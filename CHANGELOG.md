# Changelog

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
