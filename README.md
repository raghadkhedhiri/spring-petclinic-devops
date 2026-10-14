# Spring PetClinic — DevSecOps on Microsoft Azure

DevSecOps and Cloud project based on the Spring PetClinic application.

The objective of this project is to build a complete, reproducible and secure delivery chain around an existing Spring Boot application, from source-code validation to deployment, monitoring and alerting on Microsoft Azure.

The project was developed incrementally using Git branches and Pull Requests.

---

## Project Overview

Spring PetClinic is used as the application workload so that the project can focus on DevOps, Cloud and security practices rather than on the development of a new business application.

The initial application used the embedded H2 database for local validation.  
The target architecture uses PostgreSQL as an external persistent database and deploys the application on a K3s Kubernetes cluster hosted on Microsoft Azure.

The complete project covers:

- Continuous Integration with GitHub Actions
- Maven build and automated tests
- SonarQube Cloud quality analysis
- CodeQL static security analysis
- JaCoCo test coverage enforcement
- Docker multi-stage containerization
- Trivy container vulnerability scanning
- GitHub Container Registry
- Microsoft Azure infrastructure
- Terraform Infrastructure as Code
- Ansible server configuration
- K3s Kubernetes
- PostgreSQL persistent storage
- Kubernetes Deployments, Services and Ingress
- Secure Continuous Deployment using Azure OIDC
- Azure RBAC with least-privilege permissions
- OWASP ZAP dynamic security testing
- Spring Boot Actuator and Micrometer
- Prometheus monitoring
- Grafana dashboards
- Alertmanager
- Gmail incident notifications

---

## Global Architecture

```text
Developer
   |
   v
Git / GitHub
   |
   v
Pull Request
   |
   v
GitHub Actions CI
   |
   +--> Maven build and tests
   +--> JaCoCo coverage
   +--> SonarQube
   +--> CodeQL SAST
   +--> Docker build
   +--> Trivy image scan
   |
   v
GitHub Container Registry
   |
   v
GitHub Actions CD
   |
   +--> Azure OIDC authentication
   +--> Azure RBAC
   +--> Azure Run Command
   |
   v
Microsoft Azure VM
   |
   v
K3s Kubernetes
   |
   +--> Traefik Ingress
   |
   +--> PetClinic Deployment
   |       +--> Replica 1
   |       +--> Replica 2
   |
   +--> PostgreSQL StatefulSet
           |
           +--> PersistentVolumeClaim

Monitoring:
PetClinic
   |
   v
Spring Boot Actuator / Micrometer
   |
   v
Prometheus
   |
   +--> Grafana
   |
   v
Alertmanager
   |
   v
Gmail notifications

Security after deployment:
PetClinic public endpoint
   |
   v
OWASP ZAP Baseline Scan
```

---

## Technology Stack

### Application

- Java / Spring Boot
- Maven Wrapper
- Spring Data JPA
- Thymeleaf
- PostgreSQL
- Spring Boot Actuator
- Micrometer Prometheus Registry

### CI/CD

- Git
- GitHub
- GitHub Actions
- GitHub Container Registry
- Azure OIDC
- Azure Run Command

### Quality and Security

- SonarQube Cloud
- CodeQL
- JaCoCo
- Trivy
- OWASP ZAP

### Containers and Orchestration

- Docker
- Docker Compose
- Kubernetes
- K3s
- Traefik

### Infrastructure and Configuration

- Microsoft Azure
- Terraform
- Ansible

### Observability

- Prometheus
- Grafana
- Alertmanager
- Gmail SMTP notifications

---

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── cd.yml
│       └── dast.yml
│
├── infra/
│   ├── terraform/
│   └── ansible/
│
├── k8s/
│   ├── base/
│   └── monitoring/
│
├── scripts/
│
├── src/
│
├── Dockerfile
├── compose.yaml
├── pom.xml
└── README.md
```

The repository separates application code, infrastructure, Kubernetes resources, automation and CI/CD workflows.

---

# Continuous Integration

The main CI workflow is implemented with GitHub Actions.

It is triggered for:

- Pull Requests targeting `main`
- pushes to `main`

This provides two levels of validation:

```text
feature branch
      |
      v
Pull Request
      |
      v
CI validation
      |
      v
Merge
      |
      v
main
      |
      v
Final CI validation
```

The CI pipeline contains several complementary controls.

---

## Maven Build and Tests

The project is built and tested using the Maven Wrapper:

```bash
./mvnw -B verify
```

Using the Maven Wrapper helps keep the build reproducible without requiring a manually installed Maven version.

---

## SonarQube Cloud

SonarQube Cloud is integrated into the CI workflow to perform static code-quality and security analysis.

The analysis is executed from Maven during the build.

It provides checks such as:

- code quality
- maintainability
- reliability
- security issues
- duplication
- quality gate validation

Authentication is provided through a GitHub Actions secret and is not committed to the repository.

---

## CodeQL SAST

GitHub CodeQL is used as an additional Static Application Security Testing mechanism.

The CodeQL job:

1. checks out the source code;
2. initializes CodeQL for Java/Kotlin;
3. builds the application;
4. performs semantic security analysis.

This complements SonarQube by providing a second static-security analysis layer.

---

## JaCoCo Test Coverage

JaCoCo is integrated into Maven to measure automated test coverage.

A minimum line coverage threshold of:

```text
80 %
```

is configured in the Maven verification phase.

The build therefore validates both test execution and the configured coverage requirement.

---

# Containerization

## Docker

PetClinic is containerized using a multi-stage Docker build.

The build stage compiles the application, while the runtime stage contains only the components required to execute the application.

This approach reduces unnecessary build tools in the final runtime image.

The application listens on:

```text
8080
```

---

## PostgreSQL with Docker Compose

During the intermediate local integration phase, PostgreSQL can be run using Docker Compose.

Database credentials are provided through environment variables rather than hard-coded into the application.

Sensitive local configuration files are excluded from Git.

An example environment configuration can be provided without publishing real credentials.

---

# Container Security with Trivy

The Docker image built by the CI pipeline is scanned using Trivy.

The scan covers:

```text
OS packages
+
application libraries
```

The workflow is configured to detect:

```text
HIGH
CRITICAL
```

severity findings and uses a non-zero exit code when such findings are detected.

Security databases evolve independently from the source code. Therefore, a scan may report newly disclosed vulnerabilities even when no application source file has changed.

---

# GitHub Container Registry

After successful validation on the main branch, the Docker image can be published to GitHub Container Registry.

Images are versioned using the Git commit SHA.

A moving `latest` tag is also maintained for the current main version.

Conceptually:

```text
ghcr.io/<owner>/petclinic-app:<commit-sha>
ghcr.io/<owner>/petclinic-app:latest
```

Using immutable commit-based tags improves deployment traceability.

---

# Microsoft Azure Infrastructure

The target environment is hosted on Microsoft Azure.

The infrastructure includes resources such as:

- Resource Group
- Virtual Network
- Subnet
- Network Security Group
- Network Interface
- Public IP address
- Linux Virtual Machine
- Managed Identity used for CD

The infrastructure is managed as code rather than created manually as the primary deployment mechanism.

---

# Infrastructure as Code with Terraform

Terraform is used to describe and provision the Azure infrastructure.

The Terraform configuration is located under:

```text
infra/terraform/
```

Typical validation commands are:

```bash
terraform -chdir=infra/terraform fmt -check
terraform -chdir=infra/terraform validate
terraform -chdir=infra/terraform plan
```

Actual infrastructure changes should always be reviewed through the Terraform plan before applying them.

Local variable files and sensitive values are not intended to be committed to Git.

---

# Configuration Management with Ansible

Ansible is used to configure the Azure Linux VM and automate the installation of the Kubernetes environment.

The configuration is located under:

```text
infra/ansible/
```

Ansible is used notably for:

- host configuration;
- K3s installation;
- Helm installation;
- monitoring-stack deployment;
- monitoring configuration.

This keeps server configuration reproducible rather than relying on undocumented manual operations.

---

# Kubernetes with K3s

The application runs on a K3s Kubernetes cluster hosted on the Azure VM.

K3s provides a lightweight Kubernetes distribution suitable for the project environment.

The cluster uses Traefik as the ingress controller.

---

## PetClinic Deployment

PetClinic is deployed as a Kubernetes Deployment with:

```text
2 replicas
```

Using two application replicas provides application-level redundancy within the node.

Because the current project uses a single K3s node, this should not be interpreted as full cluster high availability.

---

## PostgreSQL StatefulSet

PostgreSQL is deployed using a Kubernetes StatefulSet.

Persistent storage is requested through a PersistentVolumeClaim.

Conceptually:

```text
PetClinic Pods
      |
      v
PostgreSQL Service
      |
      v
PostgreSQL StatefulSet
      |
      v
PersistentVolumeClaim
```

The database is therefore separated from the application Pods and benefits from persistent storage.

---

## Kubernetes Networking

The public application request follows this path:

```text
Internet
   |
   v
Azure Public IP :80
   |
   v
Azure Network Security Group
   |
   v
K3s / Traefik
   |
   v
Kubernetes Ingress
   |
   v
PetClinic Service :80
   |
   v
PetClinic Pods :8080
```

The Pods themselves are not directly exposed to the Internet.

---

# Continuous Deployment

Continuous Deployment is implemented using a dedicated GitHub Actions workflow.

The CD workflow starts only after the corresponding CI workflow has completed successfully on `main`.

Conceptually:

```text
CI success
    |
    v
CD workflow
    |
    v
Azure authentication
    |
    v
Deployment command
    |
    v
Kubernetes rollout
    |
    v
Deployment verification
```

---

## Secure Azure Authentication with OIDC

The deployment workflow uses OpenID Connect instead of storing a long-lived Azure password or service-principal secret in GitHub.

The authentication flow is:

```text
GitHub Actions
      |
      | OIDC identity token
      v
Microsoft Entra ID / Azure
      |
      | short-lived authentication
      v
Authorized deployment operation
```

This reduces dependency on persistent Cloud credentials.

---

## Least-Privilege RBAC

A dedicated Azure identity and limited role are used by the deployment workflow.

The objective is to provide only the permissions required by the CD process rather than assigning broad administrative privileges.

---

## Deployment through Azure Run Command

The GitHub-hosted runner does not require permanent SSH access to the VM.

Azure Run Command is used to execute the controlled deployment operation on the Azure VM.

The deployment process:

1. identifies the image corresponding to the validated Git commit;
2. updates the PetClinic Kubernetes Deployment;
3. waits for the Kubernetes rollout;
4. verifies the deployed image;
5. checks Pod status;
6. performs an application availability test.

This ensures that a workflow is not considered successful solely because the deployment command was submitted.

---

# Dynamic Application Security Testing

After a successful deployment, a separate DAST workflow validates the deployed application using OWASP ZAP.

The process is:

```text
Successful CD
     |
     v
Check application availability
     |
     v
OWASP ZAP Baseline Scan
```

The baseline scan is intentionally used as a security-observation step rather than as evidence that the application contains no vulnerabilities.

The generated scan report can be preserved as a GitHub Actions artifact for analysis.

---

# Monitoring and Observability

The final platform includes an observability layer based on:

- Spring Boot Actuator
- Micrometer
- Prometheus
- Grafana
- Alertmanager

---

## Application Metrics

Micrometer exposes application metrics in Prometheus format.

Spring Boot management endpoints use a dedicated management port:

```text
9090
```

The relevant monitoring endpoints include:

```text
/actuator/health
/actuator/prometheus
```

The management endpoint is separated from the public application port.

---

## ServiceMonitor

A Kubernetes Service dedicated to metrics exposes PetClinic metrics internally.

A Prometheus `ServiceMonitor` instructs Prometheus to scrape:

```text
/actuator/prometheus
```

at a configured interval.

Monitoring services remain internal to the Kubernetes environment rather than being permanently exposed publicly.

---

# Prometheus

Prometheus collects and stores metrics from the application and Kubernetes environment.

The monitoring configuration includes persistent storage and retention settings.

PetClinic monitoring verifies that application metric targets can be successfully scraped.

---

# Grafana

Grafana provides the visualization layer.

The project includes a version-controlled PetClinic dashboard displaying information such as:

- PetClinic metrics target state
- available replicas
- HTTP request rate
- HTTP latency
- JVM heap usage
- application CPU usage
- container restarts

This provides an operational view of the running application.

---

# Alerting

Prometheus rules are configured for operational conditions such as:

- PetClinic monitoring target unavailable;
- expected application replicas unavailable;
- PetClinic container restarts.

The alerts are processed by Alertmanager.

---

# Gmail Notifications

Alertmanager is configured to send selected alerts by email through Gmail SMTP.

Only relevant severity levels are routed to the email receiver:

```text
warning
critical
```

The Gmail application password is stored in a Kubernetes Secret and is not committed to the repository.

The notification chain was validated using a synthetic monitoring alert rather than by intentionally breaking the production application.

The test validated both lifecycle states:

```text
FIRING
RESOLVED
```

The resulting chain is:

```text
Prometheus
    |
    v
Alertmanager
    |
    v
Gmail
```

---

# Security Principles

The project applies several security practices throughout the delivery chain:

- secrets are kept out of Git;
- GitHub Actions secrets and repository variables are used where appropriate;
- Azure authentication uses OIDC;
- Cloud permissions follow a least-privilege approach;
- CodeQL provides SAST analysis;
- SonarQube provides code-quality and security analysis;
- Trivy scans the container image and libraries;
- OWASP ZAP performs dynamic application testing;
- monitoring services are not intended to remain publicly exposed;
- PostgreSQL is accessed internally through Kubernetes networking.

---

# Traceability

Git branches and Pull Requests were used progressively throughout the project.

The implementation was separated into logical stages such as:

```text
CI
Docker
Container registry
Terraform / Azure
Kubernetes
Continuous Deployment
DAST
Monitoring
Alerting
Hardening and fixes
```

This approach provides a Git history showing the progressive implementation and correction of the platform.

---

# Main Validation Points

The project has demonstrated the following technical capabilities:

| Area | Validation |
|---|---|
| Application build | Maven build and automated tests |
| Test quality | JaCoCo coverage threshold |
| Code quality | SonarQube Cloud |
| Static security | CodeQL |
| Containerization | Docker multi-stage build |
| Container security | Trivy |
| Registry | GitHub Container Registry |
| Infrastructure | Terraform on Microsoft Azure |
| Configuration | Ansible |
| Kubernetes | K3s |
| Application | Two PetClinic replicas |
| Database | PostgreSQL with persistent storage |
| Networking | Traefik Ingress |
| CD security | Azure OIDC and RBAC |
| Deployment | Kubernetes rollout validation |
| Dynamic security | OWASP ZAP |
| Metrics | Actuator and Micrometer |
| Monitoring | Prometheus |
| Visualization | Grafana |
| Alerting | Alertmanager |
| Notification | Gmail FIRING / RESOLVED validation |

---

# Known Limitations

This project is an engineering and learning environment rather than a production-grade highly available platform.

Current limitations include:

- the K3s cluster uses a single node;
- two PetClinic replicas do not provide node-level high availability;
- the public application endpoint currently uses HTTP rather than HTTPS/TLS;
- disaster-recovery and database-restore procedures are not implemented as a complete production workflow;
- Terraform state is currently managed locally rather than through a shared remote backend;
- DAST baseline analysis is not used as proof of zero vulnerabilities.

These limitations identify clear opportunities for future improvement.

---

# Possible Future Improvements

Potential extensions include:

- HTTPS/TLS termination;
- multi-node Kubernetes architecture;
- remote Terraform state backend;
- GitOps-based deployment;
- stronger disaster-recovery procedures;
- automated database restore tests;
- progressive strengthening of DAST security gates.

---

# Local Application Validation

The application can be built with:

```bash
./mvnw -B verify
```

For local development:

```bash
./mvnw spring-boot:run
```

The local application is normally accessible at:

```text
http://localhost:8080
```

---

# Docker Build

Build the project container image locally with:

```bash
docker build -t petclinic-app:local .
```

This only builds a local image and does not deploy anything to Azure.

---

# Terraform Validation

The Terraform configuration can be checked without applying infrastructure changes:

```bash
terraform -chdir=infra/terraform fmt -check
terraform -chdir=infra/terraform validate
```

`terraform apply` is intentionally not presented as a routine validation command because it can modify Cloud infrastructure.

---

# Kubernetes Manifests

Application manifests are located under:

```text
k8s/base/
```

Monitoring resources are located under:

```text
k8s/monitoring/
```

They describe the desired Kubernetes configuration of the project.

---

# Secrets

No real passwords, Azure credentials, Gmail application passwords or database passwords should be committed to this repository.

Sensitive values are handled through mechanisms such as:

- GitHub Actions Secrets;
- GitHub repository variables;
- local ignored configuration;
- Kubernetes Secrets.

---

# Project Context

This repository contains the technical work carried out around Spring PetClinic as part of an engineering internship project at ESPRIT.

The focus of the work is DevSecOps, Cloud infrastructure, deployment automation, Kubernetes and observability.

The original Spring PetClinic application provides the application workload on top of which the DevSecOps platform was designed.

---

# License and Upstream Project

Spring PetClinic is an open-source project distributed under the Apache License 2.0.

Original upstream project:

`spring-projects/spring-petclinic`

This repository focuses on the DevSecOps and Cloud engineering work performed around that application.
