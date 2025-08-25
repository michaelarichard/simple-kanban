# Simple Kanban Board

A self-hosted kanban board application with drag-and-drop functionality, built for complete ownership and customization.

## Overview

This project provides a containerized kanban board that you fully own and control, with no vendor lock-in or licensing concerns. Built with FastAPI backend, PostgreSQL database, and modern web frontend.

## Key Features

- **Self-hosted**: Complete ownership and control of your data
- **Single container**: Deploy anywhere with `docker run`
- **Drag-and-drop**: Intuitive kanban board interface
- **Fast & lightweight**: Minimal resource requirements
- **Customizable**: Easy to modify and extend
- **Secure**: Container security best practices
- **Production-ready**: Helm charts and CI/CD integration
- **Full observability**: OpenTelemetry tracing and metrics
- **Local monitoring**: Built-in Prometheus + Grafana stack
- **Task metadata and attachments** using flexible JSONB storage
- **Real-time collaboration** via WebSocket connections

### Story Planning Integration
- **Epic and user story management** with hierarchical organization
- **Task-to-story linking** for traceability
- **Task point estimation** and sprint planning
- **Velocity tracking** and burndown charts

### API-First Design
- **Comprehensive REST API** with full CRUD operations
- **Swagger/OpenAPI documentation** auto-generated
- **CLI tool integration** for automation and scripting
- **Webhook support** for external integrations

### Self-Hosted Deployment
- **Container-first architecture** with Docker and Kubernetes
- **Zero manual deployment steps** with automated database migrations
- **High availability** with PostgreSQL replication and Redis clustering
- **Security-focused** with OAuth2/JWT authentication

## Quick Start

### Development
```bash
# Clone and setup
git clone https://github.com/michaelarichard/simple-kanban.git
cd simple-kanban
make setup

# Generate secrets (requires GPG key)
make secrets-gen

# Start development environment
make dev

# Start with full monitoring stack
make dev-monitoring
```

### Local Monitoring Stack
```bash
# Start Prometheus + Grafana + AlertManager
make monitoring-up

# Access monitoring services
# Grafana: http://localhost:3000 (admin/admin123)
# Prometheus: http://localhost:9090
# Application metrics: http://localhost:8000/metrics
```

### Production Deployment
```bash
# Build and deploy with Helm
make build
make deploy
```

### Docker Run
```bash
# Simple single-container deployment
docker run -p 8000:8000 -v kanban-data:/app/data simple-kanban:latest
```

## Project Structure

```
simple-kanban/
├── helm/                   # Kubernetes deployment
│   └── simple-kanban/     # Helm chart
├── monitoring/            # Local monitoring stack
│   ├── prometheus/        # Prometheus configuration
│   ├── grafana/          # Grafana dashboards
│   └── alertmanager/     # Alert configuration
├── scripts/               # Utility scripts
│   └── generate-secrets.py # SOPS secret generation
├── docs/                  # Documentation
│   └── *.md              # Project documentation
├── .ai-config/           # AI workflow configuration
├── docker-compose.monitoring.yml # Local monitoring stack
├── Dockerfile            # Container definition
├── pyproject.toml        # Python dependencies
└── Makefile             # Development commands tests
```

## API Endpoints

- `GET /` - Root endpoint
- `GET /health` - Health check
- `GET /health/detailed` - Detailed health with dependency checks
- `GET /metrics` - Prometheus metrics endpoint
- `GET /docs` - OpenAPI documentation

## Configuration

### Environment Variables

- `ENVIRONMENT`: Runtime environment (development/production)
- `LOG_LEVEL`: Logging level (DEBUG/INFO/WARNING/ERROR)
- `WORKERS`: Number of worker processes
- `OTEL_SERVICE_NAME`: OpenTelemetry service name
- `OTEL_EXPORTER_OTLP_ENDPOINT`: Prometheus Gateway endpoint
- `OTEL_EXPORTER_OTLP_PROTOCOL`: Protocol (http/protobuf or grpc)

### Helm Values

- **Development**: `helm/values-dev.yaml`
- **Production**: `helm/values-prod.yaml`

## Security

- Non-root container user (uid:gid 1000:1000)
- Read-only root filesystem
- Security contexts in Kubernetes
- Health checks and resource limits
- Vulnerability scanning with Trivy

## Testing

### Unit Tests
```bash
pytest tests/ -v --cov=src
```

### Integration Tests
```bash
./test.sh
```

### Linting
```bash
black --check src/ tests/
flake8 src/ tests/
mypy src/
```

## Monitoring

- Health checks at `/health`
- Basic metrics at `/metrics`
- Kubernetes probes configured
- Resource monitoring via Kubernetes

## Contributing

1. Follow the development guidelines in `.ai-config/standards/`
2. Write tests for new features
3. Ensure code passes linting
4. Update documentation as needed

## License

[Your License Here]
