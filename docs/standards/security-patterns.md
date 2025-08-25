---
description: Security patterns and trust validation from chat history analysis
---

# Security Patterns and Trust Validation

Based on project history, these security patterns must be implemented in all projects.

## Container Security Standards

### Non-Root User Requirements
- **UID/GID**: Always use 1000:1000 for application user
- **User Creation**: Create dedicated user in Dockerfile
- **File Ownership**: Ensure proper ownership with `--chown` in COPY commands
- **Security Context**: Configure in Kubernetes manifests

### Filesystem Security
- **Read-Only Root**: Set `readOnlyRootFilesystem: true` where possible
- **Writable Volumes**: Mount emptyDir for `/tmp` and cache directories
- **Minimal Permissions**: Drop all capabilities, disable privilege escalation

## Trust and Provenance Tracking

### Information Integrity Patterns
- **Source Verification**: Track original sources and validate authenticity
- **Temporal Analysis**: Monitor information propagation speed and patterns
- **Content Validation**: Implement similarity scoring and originality checks
- **Trust Scoring**: Multi-factor trust calculation (Source 40%, Temporal 30%, Content 30%)

### Data Structure Standards
```json
{
  "id": "unique_identifier",
  "title": "content_title", 
  "content": "actual_content",
  "date": "ISO-8601-timestamp",
  "source": "domain.com",
  "type": "analysis|news|social|official",
  "trust_score": 0.0-1.0,
  "derived_from": ["parent_ids"],
  "contradicts": ["conflicting_ids"]
}
```

## API Security Patterns

### Authentication and Authorization
- **API Keys**: Never hardcode, use environment variables or secrets
- **CORS Configuration**: Restrict origins in production
- **Rate Limiting**: Implement request throttling
- **Input Validation**: Strict validation with Pydantic models

### Error Handling
- **Sanitized Responses**: Never expose internal errors
- **Logging**: Log security events without sensitive data
- **Health Checks**: Implement comprehensive health endpoints

## Dependency Security

### Supply Chain Protection
- **Pinned Versions**: Always pin dependency versions
- **Vulnerability Scanning**: Integrate Trivy or similar tools
- **License Compliance**: Track and validate licenses
- **Update Strategy**: Regular security updates with testing

### Secret Management
- **Environment Variables**: Use for configuration
- **Kubernetes Secrets**: For sensitive data
- **Secret Rotation**: Implement rotation strategies
- **Audit Trail**: Log secret access and changes

## Monitoring and Alerting

### Security Monitoring
- **Access Logs**: Monitor API access patterns
- **Anomaly Detection**: Identify unusual behavior
- **Performance Metrics**: Track resource usage
- **Error Rates**: Monitor failure patterns

### Incident Response
- **Logging Standards**: Structured logging with correlation IDs
- **Alert Thresholds**: Define clear alerting criteria
- **Response Procedures**: Document incident response steps
- **Recovery Plans**: Automated recovery where possible
