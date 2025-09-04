# Simple Kanban Board

A self-hosted kanban board application with drag-and-drop functionality, built for complete ownership and customization.

## 🎉 MVP Status: COMPLETE ✅

**Current Version**: MVP 1.0 (Production Ready)  
**Last Updated**: September 4, 2025  
**Branch**: `kanban-main1`

## Overview

This project provides a containerized kanban board that you fully own and control, with no vendor lock-in or licensing concerns. Built with FastAPI backend, PostgreSQL database, and modern web frontend.

## ✅ Delivered MVP Features

- **Complete Kanban Functionality**: Full CRUD operations for boards, columns, and tasks
- **Drag-and-Drop**: Tasks move between columns with full persistence
- **Task Aging**: Color-coded indicators showing "days open" (blue→green→orange→red)
- **Board Management**: Multiple boards with persistent selection across sessions
- **Modern UI**: Responsive design with animations and professional styling
- **Self-Hosted**: Complete Kubernetes deployment with PostgreSQL backend
- **Data Persistence**: All changes persist correctly across page refreshes and restarts

## 📋 Next Phase: Multi-User Authentication

**Status**: Planned for Phase 2  
**Documentation**: Complete design and 6-week implementation plan available

### Planned Features
- **Google OIDC Integration**: Secure authentication with Google accounts
- **Role-Based Access Control**: Owner, Editor, Viewer permissions
- **Board Sharing**: Invite users and manage collaboration
- **User Dashboard**: Personal board management interface
- **Admin Interface**: System administration and user management

## Current Architecture

### Backend Stack
- **Framework**: FastAPI (Python)
- **Database**: PostgreSQL with SQLAlchemy ORM
- **API Design**: RESTful endpoints with proper HTTP status codes
- **Data Models**: Board → Column → Task hierarchy

### Frontend Stack
- **Technology**: Vanilla JavaScript (ES6+)
- **Styling**: Modern CSS with Flexbox/Grid
- **Icons**: FontAwesome integration
- **State Management**: Class-based architecture with localStorage persistence

### Deployment Stack
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Kubernetes with Helm charts
- **Development**: Skaffold for rapid iteration
- **Database**: PostgreSQL with automated migrations

## Quick Start

### Development
```bash
# Clone and setup
git clone https://github.com/your-repo/simple-kanban.git
cd simple-kanban

# Start development environment with Skaffold
skaffold dev --port-forward

# Access application
# Application: http://127.0.0.1:4503
# API docs: http://127.0.0.1:4503/docs
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

### Application
- `GET /` - Kanban board web interface
- `GET /health` - Health check
- `GET /docs` - OpenAPI documentation

### Boards
- `GET /api/boards/` - List all boards
- `POST /api/boards/` - Create new board
- `GET /api/boards/{id}` - Get board details
- `PUT /api/boards/{id}` - Update board
- `DELETE /api/boards/{id}` - Delete board

### Columns & Tasks
- `GET /api/columns/board/{board_id}` - Get columns with tasks for a board
- `POST /api/tasks/` - Create new task
- `PUT /api/tasks/{id}` - Update task
- `POST /api/tasks/{id}/move` - Move task between columns
- `DELETE /api/tasks/{id}` - Delete task

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
