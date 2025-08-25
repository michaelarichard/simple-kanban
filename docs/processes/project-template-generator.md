---
description: Generate new project from template with language-specific customization
---

# Project Template Generator Workflow

This workflow creates a new project from the standardized template with language-specific customizations.

## Usage

When creating a new project, specify:
- **Project name**: The name of your new project
- **Language**: python, golang, or js (defaults to python)
- **Target directory**: Where to create the project

## Steps

1. **Validate Input Parameters**
   ```bash
   # Ensure project name is valid (lowercase, hyphens only)
   # Check target directory exists and is writable
   # Validate language is supported
   ```

2. **Copy Template Structure**
   ```bash
   cp -r /home/windsurf/Projects/.ai-config/templates/python-project/ {target-dir}/{project-name}/
   cd {target-dir}/{project-name}
   ```

3. **Replace Template Placeholders**
   - Replace `simple-kanban` with actual project name in all files
   - Update file names containing placeholder
   - Customize language-specific configurations

4. **Initialize Git Repository**
   ```bash
   git init
   git add .
   git commit -m "Initial commit from template"
   ```

5. **Language-Specific Customization**

   ### Python (Default)
   - No additional changes needed
   - Template is Python-ready

   ### Go
   - Replace `requirements.txt` with `go.mod`
   - Update `Dockerfile` for Go build process
   - Modify `src/main.py` to `main.go`
   - Update test structure for Go

   ### JavaScript/Node.js
   - Replace `requirements.txt` with `package.json`
   - Update `Dockerfile` for Node.js
   - Modify `src/main.py` to `src/app.js`
   - Update test structure for Jest

6. **Validate Template Generation**
   ```bash
   make setup
   make test
   make lint
   ```

7. **Initialize Development Environment**
   ```bash
   skaffold dev --port-forward
   ```

## Template Customization Script

Create a helper script to automate the template generation:

```bash
#!/bin/bash
# generate-project.sh
PROJECT_NAME="$1"
LANGUAGE="${2:-python}"
TARGET_DIR="${3:-$(pwd)}"

# Validation and generation logic here
```

## Post-Generation Checklist

- [ ] All placeholder text replaced
- [ ] Git repository initialized
- [ ] Dependencies install successfully
- [ ] Tests pass
- [ ] Docker image builds
- [ ] Skaffold development works
- [ ] Helm chart validates
- [ ] Documentation updated
