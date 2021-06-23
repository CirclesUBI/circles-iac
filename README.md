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

* [`terraform`] v0.12.x (higher not compatible)
* [`helm`]
* [`doctl`]

[`doctl`]: https://docs.digitalocean.com/reference/doctl/how-to/install
[`helm`]: https://helm.sh/docs/intro/install
[`terraform`]: https://releases.hashicorp.com/terraform

## Overview

* [`do-infra-setup`]: Terraform files to deploy Circles staging and production infrastructure on DigitalOcean
* [`helm/circles-infra-suite`]: Helm chart and templates to deploy Circles services from Docker images

[`do-infra-setup`]: do-infra-setup
[`helm/circles-infra-suite`]: helm/circles-infra-suite

## Images registry

Circles repositories automatically build and upload Docker images of their latest versions. These images are available in our DigitalOcean registry and publicly on [`DockerHub`].

[`DockerHub`]: https://hub.docker.com/u/joincircles

## Provisioning via `docker-compose`

In case you don't want to deploy Circles infrastructure with DigitalOcean and Kubernetes you can have a look at our [`circles-docker`] repository which allows a similar setup with `docker-compose` for local development and easier production server deployments.

[`circles-docker`]: https://github.com/CirclesUBI/circles-docker

## License

GNU Affero General Public License v3.0 [`AGPL-3.0`]

[`AGPL-3.0`]: LICENSE
