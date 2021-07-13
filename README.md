<div align="center">
	<img width="80" src="https://raw.githubusercontent.com/CirclesUBI/.github/main/assets/logo.svg" />
</div>

<h1 align="center">circles-iac</h1>

<div align="center">
 <strong>
    Infrastructure provisioning for Circles
 </strong>
</div>

<br />

<div align="center"> 
  <!-- Discourse -->
  <a href="https://aboutcircles.com/">
    <img src="https://img.shields.io/discourse/topics?server=https%3A%2F%2Faboutcircles.com%2F&style=flat-square&color=%23faad26" alt="chat" height="18"/>
  </a>
  <!-- Twitter -->
  <a href="https://twitter.com/CirclesUBI">
    <img src="https://img.shields.io/twitter/follow/circlesubi.svg?label=twitter&style=flat-square&color=%23f14d48" alt="Follow Circles" height="18">
  </a>
</div>

<div align="center">
  <h3>
    <a href="https://handbook.joincircles.net">
      Handbook
    </a>
    <span> | </span>
    <a href="https://github.com/CirclesUBI/.github/blob/main/CONTRIBUTING.md">
      Contributing
    </a>
  </h3>
</div>

<br/>

Setup and deployment infrastructure using Terraform and Helm to manage volumes and [`Circles`] services with Kubernetes on DigitalOcean.

[`Circles`]: https://joincircles.net

## Requirements

* [`terraform`] 1.0.0
* [`helm`] 3.6.0
* [`kubectl`] 1.20
* [`doctl`] 1.61.0

[`doctl`]: https://docs.digitalocean.com/reference/doctl/how-to/install
[`kubectl`]: https://kubernetes.io/docs/tasks/tools
[`helm`]: https://helm.sh/docs/intro/install
[`terraform`]: https://www.terraform.io/downloads.html

## Overview

* [`do-infra-setup`]: Terraform files to deploy Circles staging and production infrastructure on DigitalOcean
* [`helm/circles-infra-suite`]: Helm chart and templates to deploy Circles services from Docker images
* [`secrets`]: Helpers to create secrets on Kubernetes cluster

[`do-infra-setup`]: do-infra-setup
[`helm/circles-infra-suite`]: helm/circles-infra-suite
[`secrets`]: secrets

## Usage

### Setup

1. Use terraform [`do-infra-setup`] to provision a Kubernetes cluster, PostgreSQL database, NFS Provisioner, Ingress controller and LetsEncrypt issuer on DigitalOcean
2. Create required secrets via [`secrets`] helper tools
3. Use helm [`helm/circles-infra-suite`] to deploy Circles services on Kubernetes cluster

### Deployment of new services

1. Follow all steps to create new releases and docker images of [`circles-api`](https://github.com/CirclesUBI/circles-api/blob/main/RELEASE.md) and [`safe-relay-service`](https://github.com/CirclesUBI/safe-relay-service/blob/main/RELEASE.md).
2. Make sure the docker images are uploaded and ready in the Digital Ocean registry, this might take a few minutes.
3. Change the values in the regarding `imageTag` field for [`staging`](https://github.com/CirclesUBI/circles-iac/blob/main/helm/circles-infra-suite/values-staging.yaml) and [`production`](https://github.com/CirclesUBI/circles-iac/blob/main/helm/circles-infra-suite/values-production.yaml) to the versions you want to release.
4. Make sure you're using the right Kubernetes context (staging / production cluster) via `kubectl config current-context`. You can switch the context via `kubectl config use-context <name>`.
5. Run `./helm-upgrade.sh <production|staging>` to apply the changes on the Kubernetes cluster.

### Secrets

This setup requires the following `Secret` objects to be created on the Kubernetes cluster. Check [`secrets`] for further helper tools to maintain secrets:

**relayer:**

* `SAFE_FUNDER_PRIVATE_KEY`: Wallet with funds to pay for Safe creation
* `SAFE_TX_SENDER_PRIVATE_KEY`: Wallet with funds to pay for transactions
* `DJANGO_SECRET_KEY`: Hashing salt for Relayer Django app

**aws:**

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

**db:**

* `POSTGRES_HOST`
* `POSTGRES_PASSWORD`
* `POSTGRES_PORT`
* `POSTGRES_USER`

### Images registry

Circles repositories automatically build and upload Docker images of their latest versions. These images are available in our DigitalOcean registry and publicly on [`DockerHub`].

[`DockerHub`]: https://hub.docker.com/u/joincircles

### Provisioning via `docker-compose`

In case you don't want to deploy Circles infrastructure with DigitalOcean and Kubernetes you can have a look at our [`circles-docker`] repository which allows a similar setup with `docker-compose` for local development and easier production server deployments.

[`circles-docker`]: https://github.com/CirclesUBI/circles-docker

## License

GNU Affero General Public License v3.0 [`AGPL-3.0`]

[`AGPL-3.0`]: LICENSE
