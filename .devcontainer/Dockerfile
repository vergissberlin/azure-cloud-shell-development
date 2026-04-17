# Dev container image: bake apt deps into a layer (faster CI + local rebuilds than postCreate only).
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3 \
        ca-certificates \
        coreutils \
    && rm -rf /var/lib/apt/lists/*
