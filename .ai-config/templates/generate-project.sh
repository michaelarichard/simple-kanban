#!/bin/bash
# Project Generator Script
# Usage: ./generate-project.sh <project-name> [language] [target-dir]

set -e

PROJECT_NAME="$1"
LANGUAGE="${2:-python}"
TARGET_DIR="${3:-$(pwd)}"
TEMPLATE_DIR="/home/windsurf/Projects/.ai-config/templates"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Validation functions
validate_project_name() {
    if [[ -z "$PROJECT_NAME" ]]; then
        echo -e "${RED}Error: Project name is required${NC}"
        echo "Usage: $0 <project-name> [language] [target-dir]"
        exit 1
    fi
    
    if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
        echo -e "${RED}Error: Project name must contain only lowercase letters, numbers, and hyphens${NC}"
        exit 1
    fi
}

validate_language() {
    case "$LANGUAGE" in
        python|golang|js|javascript)
            ;;
        *)
            echo -e "${RED}Error: Unsupported language '$LANGUAGE'. Supported: python, golang, js${NC}"
            exit 1
            ;;
    esac
}

validate_target_dir() {
    if [[ ! -d "$TARGET_DIR" ]]; then
        echo -e "${RED}Error: Target directory '$TARGET_DIR' does not exist${NC}"
        exit 1
    fi
    
    if [[ ! -w "$TARGET_DIR" ]]; then
        echo -e "${RED}Error: Target directory '$TARGET_DIR' is not writable${NC}"
        exit 1
    fi
}

# Main generation function
generate_project() {
    local project_path="$TARGET_DIR/$PROJECT_NAME"
    
    echo -e "${BLUE}🚀 Generating project: $PROJECT_NAME${NC}"
    echo -e "${BLUE}   Language: $LANGUAGE${NC}"
    echo -e "${BLUE}   Location: $project_path${NC}"
    
    # Check if project already exists
    if [[ -d "$project_path" ]]; then
        echo -e "${RED}Error: Project directory '$project_path' already exists${NC}"
        exit 1
    fi
    
    # Copy template
    echo -e "${YELLOW}📁 Copying template structure...${NC}"
    cp -r "$TEMPLATE_DIR/python-project" "$project_path"
    cd "$project_path"
    
    # Copy workflow documentation
    echo -e "${YELLOW}📚 Copying workflow documentation...${NC}"
    mkdir -p docs/workflows docs/standards docs/processes
    cp -r /home/windsurf/Projects/.ai-config/processes/* docs/processes/
    cp -r /home/windsurf/Projects/.ai-config/standards/* docs/standards/
    
    # Create workflow reference in docs
    cat > docs/workflows/README.md << EOF
# Workflow Reference

This project includes copies of all standard workflows for local reference:

## Available Workflows
- \`/new-project\` - Generate new containerized project
- \`/project-01-define-product\` - Define product goals and requirements
- \`/project-02-product-research\` - Research market and competition
- \`/project-03-create-user-stories\` - Create actionable user stories
- \`/project-04-design-architecture\` - Design system architecture
- \`/project-05-review\` - Review requirements and design
- \`/project-06-generate-rules\` - Create project-specific rules
- \`/project-08-plan-features\` - Plan feature development
- \`/project-09-develop-feature\` - Develop individual features
- \`/code-review\` - Perform code reviews
- \`/stage-changes\` - Stage and deploy changes

## Process Flow
Follow the \`idea-to-project.md\` process for structured development from concept to implementation.
EOF
    
    # Replace placeholders
    echo -e "${YELLOW}🔄 Replacing template placeholders...${NC}"
    find . -type f -name "*.yaml" -o -name "*.yml" -o -name "*.md" -o -name "*.py" -o -name "*.tpl" -o -name "*.sh" | \
        xargs sed -i "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g"
    
    # Rename helm chart directory
    mv "helm/PROJECT_NAME_PLACEHOLDER" "helm/$PROJECT_NAME"
    
    # Language-specific customizations
    case "$LANGUAGE" in
        golang|go)
            customize_golang
            ;;
        js|javascript)
            customize_javascript
            ;;
        python)
            # Python is the default template
            ;;
    esac
    
    # Make scripts executable
    chmod +x test.sh
    
    # Initialize git repository
    echo -e "${YELLOW}📦 Initializing git repository...${NC}"
    git init
    git add .
    git commit -m "Initial commit from template"
    
    echo -e "${GREEN}✅ Project '$PROJECT_NAME' created successfully!${NC}"
    echo -e "${GREEN}📍 Location: $project_path${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  cd $PROJECT_NAME"
    echo -e "  make setup"
    echo -e "  make test"
    echo -e "  make dev"
}

customize_golang() {
    echo -e "${YELLOW}🐹 Customizing for Go...${NC}"
    
    # Replace requirements.txt with go.mod
    cat > go.mod << EOF
module $PROJECT_NAME

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/stretchr/testify v1.8.4
)
EOF
    rm requirements.txt
    
    # Replace Python main with Go main
    cat > main.go << 'EOF'
package main

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

type HealthResponse struct {
    Status  string `json:"status"`
    Version string `json:"version"`
}

type EchoRequest struct {
    Message string `json:"message"`
}

type EchoResponse struct {
    Echo   string `json:"echo"`
    Length int    `json:"length"`
}

func main() {
    r := gin.Default()
    
    r.GET("/", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "PROJECT_NAME_PLACEHOLDER API",
            "status":  "running",
            "docs":    "/docs",
        })
    })
    
    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, HealthResponse{
            Status:  "healthy",
            Version: "1.0.0",
        })
    })
    
    r.POST("/echo", func(c *gin.Context) {
        var req EchoRequest
        if err := c.ShouldBindJSON(&req); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }
        
        if req.Message == "" {
            c.JSON(http.StatusBadRequest, gin.H{"error": "Message cannot be empty"})
            return
        }
        
        c.JSON(http.StatusOK, EchoResponse{
            Echo:   req.Message,
            Length: len(req.Message),
        })
    })
    
    r.Run(":8000")
}
EOF
    rm -rf src/
    
    # Update Dockerfile for Go
    cat > Dockerfile << 'EOF'
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates curl
RUN addgroup -g 1000 appuser && adduser -D -u 1000 -G appuser appuser

WORKDIR /app
COPY --from=builder --chown=appuser:appuser /app/main .

USER appuser
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["./main"]
EOF
}

customize_javascript() {
    echo -e "${YELLOW}🟨 Customizing for JavaScript/Node.js...${NC}"
    
    # Replace requirements.txt with package.json
    cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "A containerized Node.js application",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js",
    "test": "jest",
    "lint": "eslint src/ tests/"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "nodemon": "^3.0.1",
    "eslint": "^8.52.0"
  }
}
EOF
    rm requirements.txt
    
    # Replace Python main with Node.js app
    cat > src/app.js << 'EOF'
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
    res.json({
        message: 'PROJECT_NAME_PLACEHOLDER API',
        status: 'running',
        docs: '/docs'
    });
});

app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        version: '1.0.0'
    });
});

app.post('/echo', (req, res) => {
    const { message } = req.body;
    
    if (!message || message.trim() === '') {
        return res.status(400).json({ error: 'Message cannot be empty' });
    }
    
    res.json({
        echo: message,
        length: message.length
    });
});

app.get('/metrics', (req, res) => {
    res.json({
        requests_total: 0,
        uptime_seconds: process.uptime(),
        memory_usage_mb: Math.round(process.memoryUsage().heapUsed / 1024 / 1024)
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});

module.exports = app;
EOF
    rm src/main.py
    
    # Update Dockerfile for Node.js
    cat > Dockerfile << 'EOF'
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
RUN apk --no-cache add curl
RUN addgroup -g 1000 appuser && adduser -D -u 1000 -G appuser appuser

WORKDIR /app
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --chown=appuser:appuser . .

USER appuser
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["npm", "start"]
EOF
}

# Main execution
main() {
    validate_project_name
    validate_language
    validate_target_dir
    generate_project
}

# Show help if no arguments
if [[ $# -eq 0 ]]; then
    echo "Project Generator"
    echo "Usage: $0 <project-name> [language] [target-dir]"
    echo ""
    echo "Arguments:"
    echo "  project-name    Name of the project (lowercase, hyphens allowed)"
    echo "  language        Programming language (python, golang, js) [default: python]"
    echo "  target-dir      Target directory [default: current directory]"
    echo ""
    echo "Examples:"
    echo "  $0 my-api python"
    echo "  $0 web-service golang /home/user/projects"
    echo "  $0 frontend-app js"
    exit 0
fi

main "$@"
