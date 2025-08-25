.PHONY: test lint deploy setup clean build run lint-python lint-security lint-check lint-format fix-black fix-ruff deploy-dev deploy-prod

# Variables
PROJECT_NAME ?= $(shell basename $(CURDIR))
IMAGE_TAG ?= latest
REGISTRY ?= localhost:5000

# Setup development environment
setup:
	python -m venv venv
	. venv/bin/activate && pip install -r requirements.txt
	pre-commit install || echo "pre-commit not available"

# Linting and code quality
lint: lint-python lint-security lint-check
	@echo "All linting and security checks passed!"

lint-python:
	@echo "Running Python linting..."
	black --check src/ tests/
	ruff check src/ tests/
	pyright src/ tests/

lint-security:
	@echo "Running security scans..."
	checkov --directory . --framework dockerfile,kubernetes
	bandit -r src/
	safety check

lint-check:
	@echo "Checking code formatting..."
	black --check --diff src/ tests/

lint-format:
	@echo "Formatting Python code..."
	black src/ tests/
	ruff --fix src/ tests/

fix-black:
	@echo "Auto-fixing with Black..."
	black src/ tests/

fix-ruff:
	@echo "Auto-fixing with Ruff..."
	ruff --fix src/ tests/

format: lint-format

# Run tests with coverage
test:
	pytest tests/ -v --cov=src --cov-report=html --cov-report=term-missing

# Build Docker image
build:
	docker build -t $(PROJECT_NAME):$(IMAGE_TAG) .

# Run application locally
run:
	uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

# Deploy using Skaffold (defaults to dev)
deploy: deploy-dev
	@echo "Deployed to development environment"

deploy-dev:
	skaffold run --profile=dev

deploy-prod:
	skaffold run --profile=prod

# Deploy for development with hot reload
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
