#!/bin/bash
# ==============================================================================
# Moltbot Health Check Script
# ==============================================================================
# Used by Docker HEALTHCHECK and Railway health checks.
# Returns 0 if healthy, 1 if unhealthy.
# ==============================================================================

PORT="${PORT:-3000}"

# Try to reach the health endpoint
response=$(curl -sf "http://localhost:${PORT}/health" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "Healthy: $response"
    exit 0
else
    echo "Unhealthy: Could not reach health endpoint"
    exit 1
fi
