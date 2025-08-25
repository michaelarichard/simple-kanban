---
description: Initialize a new containerized project with standard tooling
---

# Project Initialization Workflow

This workflow creates a new project with containerization, testing, and deployment infrastructure.

## Prerequisites
- Docker installed and running
- kubectl configured (for Helm deployment)
- Skaffold installed

## Steps

1. **Create Project Structure**
   ```bash
   mkdir -p {project-name}/{src,tests,helm/{project-name}/templates,docs}
   cd {project-name}
   ```

2. **Initialize Git Repository**
   ```bash
   git init
   echo "# {project-name}" > README.md
   ```

3. **Create Core Files**
   - `Dockerfile` (multi-stage, non-root user)
   - `requirements.txt` (Python) or equivalent
   - `Makefile` (test, lint, deploy targets)
   - `skaffold.yaml` (development workflow)
   - `.gitignore` (language-specific)
   - `.dockerignore`

4. **Setup Helm Chart**
   - `helm/values.yaml` (default configuration)
   - `helm/values-dev.yaml` (development overrides)
   - `helm/values-prod.yaml` (production overrides)
   - Basic Kubernetes manifests (deployment, service, ingress)

5. **Create Testing Infrastructure**
   - Unit test framework setup
   - Integration test structure
   - `test.sh` script for CI/CD
   - Coverage configuration

6. **Security Configuration**
   - Non-root container user
   - Security context in Helm charts
   - Environment variable management
   - Secret handling patterns

7. **Documentation**
   - README.md with setup instructions
   - API documentation structure
   - Development guide
   - Deployment instructions

8. **Initialize Development Environment**
   ```bash
   make setup
   make test
   skaffold dev
   ```

## Language-Specific Variations

### Python
- FastAPI application structure
- pytest configuration
- Black/flake8 linting
- Poetry or pip-tools for dependencies

### Go
- Go modules initialization
- Gin or Echo web framework
- Go test structure
- golangci-lint configuration

### JavaScript/Node.js
- Express.js application structure
- Jest testing framework
- ESLint/Prettier configuration
- npm/yarn package management

## Validation Checklist
- [ ] Docker image builds successfully
- [ ] Tests pass locally
- [ ] Skaffold development workflow works
- [ ] Helm chart deploys to local cluster
- [ ] Security scan passes
- [ ] Documentation is complete
