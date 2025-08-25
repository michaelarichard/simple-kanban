---
description: Standard project templates and patterns
---

# Project Templates

## Container-First Development Standards

All projects must follow these containerization principles:

### Security Requirements
- **Non-root user**: All containers run with dedicated user (uid:gid 1000:1000)
- **Minimal base images**: Use official slim/alpine variants
- **Multi-stage builds**: Separate build and runtime environments
- **Security scanning**: Integrate vulnerability scanning in CI/CD

### File Structure Standards
```
project-name/
├── src/                    # Source code
├── tests/                  # Test files
├── docs/                   # Documentation
├── helm/                   # Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   ├── values-prod.yaml
│   └── templates/
├── Dockerfile              # Multi-stage container build
├── Makefile               # Standard targets: test, lint, deploy
├── skaffold.yaml          # Development workflow
├── requirements.txt       # Dependencies (Python)
├── .gitignore
├── .dockerignore
└── README.md
```

### Required Makefile Targets

All projects must include these standardized Makefile targets:

```makefile
setup:          # Setup development environment
test:           # Run all tests (unit + integration)
lint:           # Run comprehensive linting and security checks
build:          # Build application/container
run:            # Run application locally
deploy:         # Deploy to dev environment (default)
deploy-dev:     # Deploy to development
deploy-prod:    # Deploy to production
clean:          # Clean build artifacts
security:       # Run security scans

# Python-specific linting targets
lint-python:    # Black, Ruff, Pyright
lint-security:  # Checkov, Bandit, Safety
lint-check:     # Check formatting without changes
lint-format:    # Auto-format code
fix-black:      # Auto-fix with Black
fix-ruff:       # Auto-fix with Ruff
```

### Helm Chart Requirements
- **Resource limits**: Always define CPU/memory limits
- **Health checks**: Liveness and readiness probes
- **Security context**: Non-root, read-only filesystem where possible
- **ConfigMaps/Secrets**: Externalize configuration
- **Horizontal Pod Autoscaler**: For production workloads

### Testing Standards
- **Unit tests**: Minimum 80% coverage
- **Integration tests**: API endpoint testing
- **Security tests**: Container scanning, dependency checks
- **Performance tests**: Load testing for APIs

## Language-Specific Templates

### Python Template
- **Framework**: FastAPI for APIs, Flask for simple web apps
- **Testing**: pytest with coverage reporting
- **Linting**: black, flake8, mypy
- **Dependencies**: requirements.txt with pinned versions
- **ASGI Server**: uvicorn with gunicorn workers

### Go Template
- **Framework**: Gin or Echo for web services
- **Testing**: Go standard testing with testify
- **Linting**: golangci-lint
- **Dependencies**: Go modules with vendor directory
- **Build**: Multi-stage Docker builds

### JavaScript/Node.js Template
- **Framework**: Express.js or Fastify
- **Testing**: Jest with supertest for API testing
- **Linting**: ESLint with Prettier
- **Dependencies**: package-lock.json for reproducible builds
- **Runtime**: Node.js LTS in Alpine container
