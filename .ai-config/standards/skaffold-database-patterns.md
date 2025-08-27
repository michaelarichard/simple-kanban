---
description: Skaffold database and cache deployment patterns
---

# Skaffold Database and Cache Patterns

## Overview

Standard patterns for deploying PostgreSQL and Redis alongside applications using Skaffold and Bitnami Helm charts.

## PostgreSQL Integration

### Basic Configuration
```yaml
- name: app-postgres
  remoteChart: bitnami/postgresql
  version: "16.7.11"
  setValues:
    auth.postgresPassword: ${POSTGRES_PASSWORD:-dev-password}
    auth.username: ${DB_USER:-appuser}
    auth.password: ${DB_PASSWORD:-dev-password}
    auth.database: ${DB_NAME:-appdb}
    primary.persistence.size: ${PG_STORAGE:-8Gi}
    metrics.enabled: ${ENABLE_METRICS:-false}
```

### Environment-Specific Values

#### Development
```yaml
setValues:
  auth.postgresPassword: simple-dev-password
  auth.username: appuser
  auth.password: simple-dev-password
  auth.database: appdb
  primary.persistence.size: 8Gi
  metrics.enabled: false
```

#### Production
```yaml
setValues:
  auth.postgresPassword: ${POSTGRES_PASSWORD}
  auth.username: ${DB_USER}
  auth.password: ${DB_PASSWORD}
  auth.database: ${DB_NAME}
  primary.persistence.size: 100Gi
  metrics.enabled: true
  primary.resources:
    limits:
      cpu: 2000m
      memory: 4Gi
    requests:
      cpu: 1000m
      memory: 2Gi
```

## Redis Integration

### Basic Configuration
```yaml
- name: app-redis
  remoteChart: bitnami/redis
  version: "21.2.3"
  setValues:
    auth.password: ${REDIS_PASSWORD:-dev-password}
    master.persistence.size: ${REDIS_STORAGE:-8Gi}
    metrics.enabled: ${ENABLE_METRICS:-false}
```

### Environment-Specific Values

#### Development
```yaml
setValues:
  auth.password: simple-dev-password
  master.persistence.size: 8Gi
  metrics.enabled: false
```

#### Production
```yaml
setValues:
  auth.password: ${REDIS_PASSWORD}
  master.persistence.size: 20Gi
  metrics.enabled: true
  master.resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi
```

## Complete Skaffold Example

```yaml
apiVersion: skaffold/v4beta7
kind: Config
metadata:
  name: example-app
build:
  artifacts:
  - image: example-app
    docker:
      dockerfile: Dockerfile
  local:
    push: false
deploy:
  helm:
    releases:
    - name: example-app-postgres
      remoteChart: bitnami/postgresql
      version: "13.2.24"
      setValues:
        auth.postgresPassword: dev-password
        auth.username: appuser
        auth.password: dev-password
        auth.database: appdb
        primary.persistence.size: 8Gi
    - name: example-app-redis
      remoteChart: bitnami/redis
      version: "18.19.4"
      setValues:
        auth.password: dev-password
        master.persistence.size: 8Gi
    - name: example-app
      chartPath: helm/example-app
      valuesFiles:
      - helm/example-app/values-dev.yaml
      setValues:
        image.repository: example-app
        image.tag: example-app
portForward:
- resourceType: service
  resourceName: example-app
  port: 8000
  localPort: 8000
- resourceType: service
  resourceName: example-app-postgres
  port: 5432
  localPort: 5432
- resourceType: service
  resourceName: example-app-redis-master
  port: 6379
  localPort: 6379
profiles:
- name: dev
  deploy:
    helm:
      releases:
      - name: example-app-postgres
        remoteChart: bitnami/postgresql
        version: "13.2.24"
        setValues:
          auth.postgresPassword: dev-password
          auth.username: appuser
          auth.password: dev-password
          auth.database: appdb
          primary.persistence.size: 8Gi
      - name: example-app-redis
        remoteChart: bitnami/redis
        version: "18.19.4"
        setValues:
          auth.password: dev-password
          master.persistence.size: 8Gi
      - name: example-app
        chartPath: helm/example-app
        valuesFiles:
        - helm/example-app/values-dev.yaml
- name: prod
  deploy:
    helm:
      releases:
      - name: example-app-postgres
        remoteChart: bitnami/postgresql
        version: "13.2.24"
        setValues:
          auth.postgresPassword: ${POSTGRES_PASSWORD}
          auth.username: ${DB_USER}
          auth.password: ${DB_PASSWORD}
          auth.database: ${DB_NAME}
          primary.persistence.size: 100Gi
          metrics.enabled: true
      - name: example-app-redis
        remoteChart: bitnami/redis
        version: "18.19.4"
        setValues:
          auth.password: ${REDIS_PASSWORD}
          master.persistence.size: 20Gi
          metrics.enabled: true
      - name: example-app
        chartPath: helm/example-app
        valuesFiles:
        - helm/example-app/values-prod.yaml
```

## Application Configuration

### Helm Values Integration

#### Development Values (values-dev.yaml)
```yaml
storage:
  postgres:
    hostname: example-app-postgres
    username: appuser
    database: appdb
    password: dev-password

cache:
  redis:
    hostname: example-app-redis-master
    password: dev-password
```

#### Production Values (values-prod.yaml)
```yaml
storage:
  postgres:
    hostname: example-app-postgres
    username: appuser
    database: appdb
    credentialsSecret: example-app-postgres-secret
    adminPasswordKey: postgres-password
    userPasswordKey: password

cache:
  redis:
    hostname: example-app-redis-master
    credentialsSecret: example-app-redis-secret
    passwordKey: redis-password
```

## Service Naming Conventions

- **PostgreSQL Service**: `{app-name}-postgres`
- **Redis Master Service**: `{app-name}-redis-master`
- **Redis Replica Service**: `{app-name}-redis-replica` (if replicas enabled)

## Best Practices

1. **Version Pinning**: Always specify exact chart versions
2. **Resource Limits**: Define appropriate CPU/memory limits for production
3. **Persistence**: Use appropriate storage sizes for each environment
4. **Metrics**: Enable metrics collection in production environments
5. **Security**: Use Kubernetes secrets for production passwords
6. **Port Forwarding**: Include database ports for local development access

## Environment Variables for Production

```bash
# PostgreSQL
export POSTGRES_PASSWORD="secure-postgres-password"
export DB_USER="appuser"
export DB_PASSWORD="secure-user-password"
export DB_NAME="appdb"

# Redis
export REDIS_PASSWORD="secure-redis-password"

# Storage
export PG_STORAGE="100Gi"
export REDIS_STORAGE="20Gi"

# Monitoring
export ENABLE_METRICS="true"
```
