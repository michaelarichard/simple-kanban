#!/bin/bash
# Integration test script for simple-kanban

set -e

PROJECT_NAME="simple-kanban"
BASE_URL="http://localhost:8000"

echo "🧪 Starting integration tests for $PROJECT_NAME"

# Function to wait for service to be ready
wait_for_service() {
    echo "⏳ Waiting for service to be ready..."
    for i in {1..30}; do
        if curl -s "$BASE_URL/health" > /dev/null 2>&1; then
            echo "✅ Service is ready"
            return 0
        fi
        echo "   Attempt $i/30 - waiting..."
        sleep 2
    done
    echo "❌ Service failed to start"
    exit 1
}

# Test health endpoint
test_health() {
    echo "🔍 Testing health endpoint..."
    response=$(curl -s "$BASE_URL/health")
    if echo "$response" | grep -q "healthy"; then
        echo "✅ Health check passed"
    else
        echo "❌ Health check failed: $response"
        exit 1
    fi
}

# Test root endpoint
test_root() {
    echo "🔍 Testing root endpoint..."
    response=$(curl -s "$BASE_URL/")
    if echo "$response" | grep -q "running"; then
        echo "✅ Root endpoint test passed"
    else
        echo "❌ Root endpoint test failed: $response"
        exit 1
    fi
}

# Test echo endpoint
test_echo() {
    echo "🔍 Testing echo endpoint..."
    response=$(curl -s -X POST "$BASE_URL/echo" \
        -H "Content-Type: application/json" \
        -d '{"message": "test message"}')
    
    if echo "$response" | grep -q "test message"; then
        echo "✅ Echo endpoint test passed"
    else
        echo "❌ Echo endpoint test failed: $response"
        exit 1
    fi
}

# Test metrics endpoint
test_metrics() {
    echo "🔍 Testing metrics endpoint..."
    response=$(curl -s "$BASE_URL/metrics")
    if echo "$response" | grep -q "requests_total"; then
        echo "✅ Metrics endpoint test passed"
    else
        echo "❌ Metrics endpoint test failed: $response"
        exit 1
    fi
}

# Test OpenAPI docs
test_docs() {
    echo "🔍 Testing OpenAPI docs..."
    status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/docs")
    if [ "$status" = "200" ]; then
        echo "✅ OpenAPI docs test passed"
    else
        echo "❌ OpenAPI docs test failed with status: $status"
        exit 1
    fi
}

# Main test execution
main() {
    wait_for_service
    test_health
    test_root
    test_echo
    test_metrics
    test_docs
    
    echo "🎉 All integration tests passed!"
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
