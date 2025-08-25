# PROJECT_NAME_PLACEHOLDER

A containerized Python FastAPI application with Kubernetes deployment.

## Features

- **FastAPI**: Modern, fast web framework for building APIs
- **Containerized**: Docker with multi-stage builds and non-root user
- **Kubernetes Ready**: Helm charts with dev/prod configurations
- **Testing**: Unit tests with pytest and integration tests
- **Security**: Non-root containers, security contexts, health checks
- **Development Workflow**: Skaffold for local development

## Quick Start

### Prerequisites

- Docker
- kubectl
- Skaffold
- Python 3.11+

### Development Setup

1. **Clone and setup**:
   ```bash
   git clone <repository>
   cd PROJECT_NAME_PLACEHOLDER
   make setup
   ```

2. **Run tests**:
   ```bash
   make test
   make lint
   ```

3. **Start development**:
   ```bash
   make dev
   # or
   skaffold dev
   ```

4. **Access the application**:
   - API: http://localhost:8000
   - Docs: http://localhost:8000/docs
   - Health: http://localhost:8000/health

### Production Deployment

```bash
# Build and deploy
make deploy

# Or with specific profile
skaffold run -p prod
```

## Project Structure

```
PROJECT_NAME_PLACEHOLDER/
├── src/                    # Source code
│   └── main.py            # FastAPI application
├── tests/                 # Test files
│   └── test_main.py       # Unit tests
├── helm/                  # Helm chart
│   └── PROJECT_NAME_PLACEHOLDER/
├── Dockerfile             # Container definition
├── Makefile              # Build automation
├── skaffold.yaml         # Development workflow
├── requirements.txt      # Python dependencies
└── test.sh              # Integration tests
```

## API Endpoints

- `GET /` - Root endpoint
- `GET /health` - Health check
- `POST /echo` - Echo message endpoint
- `GET /metrics` - Basic metrics
- `GET /docs` - OpenAPI documentation

## Configuration

### Environment Variables

- `ENVIRONMENT`: Runtime environment (development/production)
- `LOG_LEVEL`: Logging level (DEBUG/INFO/WARNING/ERROR)
- `WORKERS`: Number of worker processes

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
