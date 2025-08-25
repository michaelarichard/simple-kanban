# Observability Architecture - Simple Kanban Board

## Overview

The Simple Kanban Board implements comprehensive observability using OpenTelemetry with export to a Prometheus Gateway collector. This provides distributed tracing, metrics collection, and structured logging for production monitoring.

## OpenTelemetry Integration

### Tracing
- **Automatic instrumentation** for FastAPI, SQLAlchemy, Redis, and HTTP clients
- **Custom spans** for business logic (task operations, user workflows)
- **Correlation IDs** linking traces across service boundaries
- **OTLP export** to Prometheus Gateway collector

### Metrics
- **Application metrics**: Request rates, response times, error rates
- **Business metrics**: Task creation/completion rates, user activity
- **Infrastructure metrics**: Database connections, Redis cache hit rates
- **Custom metrics**: Kanban workflow performance indicators

### Logging
- **Structured logging** with JSON format for machine parsing
- **Correlation IDs** linking logs to traces
- **Log levels** configurable via environment variables
- **Sensitive data filtering** to prevent credential exposure

## Metrics Collection

### Application Metrics
```python
# Request metrics
http_requests_total = Counter("http_requests_total", "Total HTTP requests", ["method", "endpoint", "status"])
http_request_duration = Histogram("http_request_duration_seconds", "HTTP request duration")

# Business metrics
tasks_created_total = Counter("kanban_tasks_created_total", "Total tasks created", ["project_id"])
tasks_completed_total = Counter("kanban_tasks_completed_total", "Total tasks completed", ["project_id"])
active_users = Gauge("kanban_active_users", "Currently active users")
```

### Infrastructure Metrics
```python
# Database metrics
db_connections_active = Gauge("db_connections_active", "Active database connections")
db_query_duration = Histogram("db_query_duration_seconds", "Database query duration", ["operation"])

# Redis metrics
redis_operations_total = Counter("redis_operations_total", "Total Redis operations", ["operation"])
redis_cache_hit_rate = Gauge("redis_cache_hit_rate", "Redis cache hit rate")
```

## Prometheus Gateway Configuration

### Environment Variables
```bash
# OpenTelemetry configuration
OTEL_SERVICE_NAME=simple-kanban
OTEL_SERVICE_VERSION=1.0.0
OTEL_RESOURCE_ATTRIBUTES=service.name=simple-kanban,service.version=1.0.0

# Prometheus Gateway - OTLP supports both HTTP and gRPC
# HTTP (recommended for simplicity and firewall compatibility)
OTEL_EXPORTER_OTLP_ENDPOINT=http://prometheus-gateway:4318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf

# Alternative: gRPC (better performance, more efficient)
# OTEL_EXPORTER_OTLP_ENDPOINT=http://prometheus-gateway:4317
# OTEL_EXPORTER_OTLP_PROTOCOL=grpc

OTEL_EXPORTER_OTLP_INSECURE=true

# Tracing configuration
OTEL_TRACES_EXPORTER=otlp
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp
```

### Export Configuration
```python
from opentelemetry import trace, metrics
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider

# Configure trace provider
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Configure OTLP exporters
span_exporter = OTLPSpanExporter(
    endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT"),
    insecure=True
)

metric_exporter = OTLPMetricExporter(
    endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT"),
    insecure=True
)
```

## Custom Instrumentation

### FastAPI Middleware
```python
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.instrumentation.redis import RedisInstrumentor

# Auto-instrument FastAPI
FastAPIInstrumentor.instrument_app(app)

# Auto-instrument SQLAlchemy
SQLAlchemyInstrumentor().instrument(engine=engine)

# Auto-instrument Redis
RedisInstrumentor().instrument()
```

### Business Logic Tracing
```python
@tracer.start_as_current_span("create_task")
def create_task(task_data: TaskCreate, user_id: str):
    with tracer.start_as_current_span("validate_task_data") as span:
        span.set_attribute("task.title", task_data.title)
        span.set_attribute("user.id", user_id)
        # Validation logic
    
    with tracer.start_as_current_span("save_to_database"):
        # Database operations
        tasks_created_total.labels(project_id=task_data.project_id).inc()
    
    return task
```

## Health Check Integration

### Comprehensive Health Endpoints
```python
@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow()}

@app.get("/health/detailed")
async def detailed_health_check():
    checks = {
        "database": await check_database_health(),
        "redis": await check_redis_health(),
        "prometheus_gateway": await check_prometheus_gateway_health()
    }
    
    overall_status = "healthy" if all(check["status"] == "healthy" for check in checks.values()) else "unhealthy"
    
    return {
        "status": overall_status,
        "checks": checks,
        "timestamp": datetime.utcnow()
    }
```

## Correlation ID Implementation

### Request Correlation
```python
import uuid
from contextvars import ContextVar

correlation_id: ContextVar[str] = ContextVar('correlation_id')

@app.middleware("http")
async def correlation_id_middleware(request: Request, call_next):
    # Extract or generate correlation ID
    corr_id = request.headers.get("X-Correlation-ID", str(uuid.uuid4()))
    correlation_id.set(corr_id)
    
    # Add to response headers
    response = await call_next(request)
    response.headers["X-Correlation-ID"] = corr_id
    
    return response
```

### Structured Logging
```python
import structlog

logger = structlog.get_logger()

def log_with_correlation(**kwargs):
    corr_id = correlation_id.get(None)
    if corr_id:
        kwargs["correlation_id"] = corr_id
    logger.info(**kwargs)
```

## Monitoring Dashboards

### Key Performance Indicators
- **Request Rate**: HTTP requests per second
- **Response Time**: P50, P95, P99 latencies
- **Error Rate**: 4xx/5xx error percentage
- **Task Throughput**: Tasks created/completed per hour
- **User Activity**: Active users, session duration
- **Database Performance**: Query time, connection pool usage
- **Cache Performance**: Redis hit rate, memory usage

### Alert Conditions
- **High Error Rate**: >5% 5xx errors in 5 minutes
- **High Latency**: P95 response time >500ms
- **Database Issues**: Connection pool exhaustion
- **Cache Issues**: Redis unavailable or high memory usage
- **Service Unavailable**: Health check failures

## Local Metrics Endpoint

### Prometheus Scraping Support
In addition to OTLP export to Prometheus Gateway, the application exposes a local `/metrics` endpoint for direct Prometheus scraping:

```python
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint for local scraping"""
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )
```

### Overhead Assessment
**Local metrics endpoint adds minimal overhead:**
- **Memory**: ~1-2MB for metrics registry and counters
- **CPU**: <1% additional load for metric collection
- **Network**: Only when scraped (typically every 15-30 seconds)
- **Latency**: No impact on request processing (async collection)

**Benefits vs Overhead:**
- ✅ **Dual export strategy**: Both push (OTLP) and pull (scraping) supported
- ✅ **Fallback option**: If OTLP export fails, metrics still available
- ✅ **Development friendly**: Easy to test metrics locally
- ✅ **Standard compliance**: Works with any Prometheus-compatible system

## Development vs Production

### Development Configuration
```yaml
# docker-compose.yml - development
services:
  simple-kanban:
    environment:
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:14250
      - OTEL_TRACES_SAMPLER=always_on
      - LOG_LEVEL=DEBUG
    ports:
      - "8000:8000"  # Expose metrics endpoint for local testing
```

### Production Configuration
```yaml
# Helm values - production
observability:
  enabled: true
  prometheusGateway:
    endpoint: "prometheus-gateway.monitoring.svc.cluster.local:4317"
  tracing:
    samplingRate: 0.1  # Sample 10% of traces
  logging:
    level: INFO
    format: json
```

## Security Considerations

### Data Privacy
- **PII Filtering**: Remove sensitive data from traces and logs
- **Credential Protection**: Never log passwords, tokens, or secrets
- **Data Retention**: Configure appropriate retention policies
- **Access Control**: Restrict access to observability data

### Network Security
- **TLS Encryption**: Use TLS for OTLP export in production
- **Authentication**: Secure Prometheus Gateway access
- **Network Policies**: Restrict observability traffic to authorized services

## Implementation Timeline

### Phase 1: Basic Observability (Week 1)
- OpenTelemetry SDK integration
- Basic HTTP request tracing
- Health check endpoints
- Prometheus Gateway export

### Phase 2: Custom Metrics (Week 2)
- Business metrics implementation
- Database and Redis instrumentation
- Correlation ID implementation
- Structured logging

### Phase 3: Advanced Features (Week 3)
- Custom spans for business logic
- Performance monitoring
- Alert configuration
- Dashboard creation

This observability architecture provides comprehensive monitoring capabilities while integrating seamlessly with existing Prometheus Gateway infrastructure.
