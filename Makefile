.PHONY: test lint deploy setup clean build run

# Variables
PROJECT_NAME ?= $(shell basename $(CURDIR))
IMAGE_TAG ?= latest
REGISTRY ?= localhost:5000

# Setup development environment
setup:
	python -m venv venv
	. venv/bin/activate && pip install -r requirements.txt
	pre-commit install || echo "pre-commit not available"

# Secrets management with SOPS
secrets:
	@echo "🔐 Generating SOPS-encrypted secrets..."
	python scripts/generate-secrets.py

secrets-decrypt:
	@echo "🔓 Decrypting secrets..."
	sops -d .env.sops > .env
	@echo "✅ Secrets decrypted to .env"

secrets-edit:
	@echo "✏️ Editing encrypted secrets..."
	sops .env.sops

secrets-k8s-decrypt:
	@echo "🔓 Decrypting Kubernetes secrets..."
	sops -d secrets/kubernetes-secrets.yaml

secrets-k8s-apply:
	@echo "🚀 Applying Kubernetes secrets..."
	sops -d secrets/kubernetes-secrets.yaml | kubectl apply -f -

secrets-check:
	@echo "🔍 Checking SOPS setup..."
	@command -v sops >/dev/null 2>&1 || { echo "❌ SOPS not installed"; exit 1; }
	@command -v gpg >/dev/null 2>&1 || { echo "❌ GPG not installed"; exit 1; }
	@gpg --list-secret-keys >/dev/null 2>&1 || { echo "❌ No GPG keys found"; exit 1; }
	@echo "✅ SOPS and GPG are properly configured"

# Run tests with coverage
test:
	pytest tests/ -v --cov=src --cov-report=html --cov-report=term-missing

# Code quality checks
lint:
	black --check src/ tests/
	flake8 src/ tests/
	mypy src/

# Format code
format:
	black src/ tests/

# Build Docker image
build:
	docker build -t $(PROJECT_NAME):$(IMAGE_TAG) .

# Run application locally
run:
	uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

# Deploy using Skaffold
deploy:
	skaffold run

# Deploy for development
dev:
	skaffold dev

# Clean build artifacts
clean:
	rm -rf __pycache__ .pytest_cache htmlcov .coverage
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

# Security scan
security:
	docker run --rm -v $(PWD):/app -w /app aquasec/trivy fs .

# Integration test
integration-test:
	./test.sh
