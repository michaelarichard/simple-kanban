---
description: Generate a new containerized project from template
---

# New Project Generation

This workflow creates a new containerized project using the standardized template system.

## Prerequisites
- Docker installed and running
- kubectl configured (for Helm deployment)
- Skaffold installed

## Steps

1. **Gather Project Requirements**
   - Project name (lowercase, hyphens only)
   - Programming language (python, golang, js)
   - Target directory (defaults to current directory)

2. **Validate Project Name**
   - Must contain only lowercase letters, numbers, and hyphens
   - Must not already exist in target directory
   - Should be descriptive and follow naming conventions

3. **Generate Project Structure**
   ```bash
   /home/windsurf/Projects/.ai-config/templates/generate-project.sh {project-name} {language} {target-dir}
   ```

4. **Verify Generation**
   - Check all files were created correctly
   - Verify placeholders were replaced
   - Ensure proper file permissions

5. **Initialize Development Environment**
   ```bash
   cd {project-name}
   make setup
   make test
   ```

6. **Validate Container Build**
   ```bash
   make build
   docker run --rm -p 8000:8000 {project-name}:latest
   ```

7. **Test Skaffold Development Workflow**
   ```bash
   make dev
   # Verify application is accessible at http://localhost:8000
   ```

## Language-Specific Features

### Python
- FastAPI application with OpenAPI docs
- pytest testing framework
- Black/flake8 linting
- uvicorn ASGI server

### Go
- Gin web framework
- Go modules for dependencies
- Built-in testing framework
- Compiled binary deployment

### JavaScript/Node.js
- Express.js framework
- Jest testing framework
- ESLint/Prettier linting
- npm package management

## Post-Generation Checklist
- [ ] Project builds successfully
- [ ] Tests pass
- [ ] Linting passes
- [ ] Docker image builds
- [ ] Skaffold development works
- [ ] Helm chart validates
- [ ] Health checks respond
- [ ] API documentation accessible
- [ ] Git repository initialized
- [ ] README updated with project-specific info
