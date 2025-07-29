# Zaap

Zaap(集) is a cloud-native setup for a home lab that provides a unified interface to manage various services and applications.
It is designed to be modular, allowing users to easily add or remove components as needed.
This is an opinionated setup, meaning it comes with a set of pre-configured services and applications that can be easily deployed and managed.

For my own home lab, the underlying Kubernetes setup is based on [zaap-k3s](https://github.com/nandiheath/zaap-k3s), 
which is a lightweight Kubernetes distribution designed for home labs and edge computing.

## Overview

### Stack

| Service           | Description |
|-------------------|-------------|
| ArgoCD            | GitOps continuous delivery tool for Kubernetes |
| External-Secrets  | Kubernetes controller for managing secrets from external sources |
| 1password-Connect | Connects Kubernetes to 1Password for secret management |



### Getting Started

```bash
cp config/.env.example config/.env
# Edit config/.env to set your environment variables

./scripts/render.sh --all

```

You should also create corresponding environment variables on your Github repository to match the `.env` file.
This allows the CI steps to access the necessary secrets and configurations for generating the manifests and deploying them to your Kubernetes cluster.