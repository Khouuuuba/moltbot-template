#!/bin/bash
# ==============================================================================
# Moltbot Startup Script
# ==============================================================================
# This script validates environment variables and starts the Moltbot gateway.
# Exit codes:
#   0 - Success
#   1 - Missing required environment variable
#   2 - Moltbot failed to start
# ==============================================================================

set -e

echo "=================================================="
echo "  Moltbot on Primis"
echo "  Starting gateway..."
echo "=================================================="
echo ""

# ==============================================================================
# Validate Environment Variables
# ==============================================================================

validate_env() {
    local var_name=$1
    local var_value=${!var_name}
    
    if [ -z "$var_value" ]; then
        return 1
    fi
    return 0
}

mask_secret() {
    local secret=$1
    if [ ${#secret} -lt 12 ]; then
        echo "***"
    else
        echo "${secret:0:4}...${secret: -4}"
    fi
}

# Check for AI provider key (at least one required)
HAS_AI_KEY=false

if validate_env "ANTHROPIC_API_KEY"; then
    echo "✓ Anthropic API key configured: $(mask_secret "$ANTHROPIC_API_KEY")"
    HAS_AI_KEY=true
fi

if validate_env "OPENAI_API_KEY"; then
    echo "✓ OpenAI API key configured: $(mask_secret "$OPENAI_API_KEY")"
    HAS_AI_KEY=true
fi

if [ "$HAS_AI_KEY" = false ]; then
    echo ""
    echo "❌ ERROR: No AI provider configured!"
    echo "   Set either ANTHROPIC_API_KEY or OPENAI_API_KEY"
    echo ""
    exit 1
fi

# Check for channel tokens (at least one recommended)
HAS_CHANNEL=false

if validate_env "TELEGRAM_BOT_TOKEN"; then
    echo "✓ Telegram configured: $(mask_secret "$TELEGRAM_BOT_TOKEN")"
    HAS_CHANNEL=true
fi

if validate_env "DISCORD_BOT_TOKEN"; then
    echo "✓ Discord configured: $(mask_secret "$DISCORD_BOT_TOKEN")"
    HAS_CHANNEL=true
fi

if validate_env "SLACK_BOT_TOKEN"; then
    echo "✓ Slack configured: $(mask_secret "$SLACK_BOT_TOKEN")"
    HAS_CHANNEL=true
fi

if [ "$HAS_CHANNEL" = false ]; then
    echo ""
    echo "⚠️  WARNING: No chat channels configured!"
    echo "   Set TELEGRAM_BOT_TOKEN or DISCORD_BOT_TOKEN for chat functionality"
    echo "   (Gateway will still start for API-only usage)"
    echo ""
fi

# ==============================================================================
# Show Configuration
# ==============================================================================

echo ""
echo "Configuration:"
echo "  PORT: ${PORT:-3000}"
echo "  STATE_DIR: ${CLAWDBOT_STATE_DIR:-/data}"
echo "  NODE_OPTIONS: ${NODE_OPTIONS:-(default)}"
echo ""

# ==============================================================================
# Start Moltbot Gateway
# ==============================================================================

echo "Starting Moltbot gateway..."
echo ""

# Generate a gateway token if not provided
export OPENCLAW_GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo 'primis-gateway-token')}"
echo "  GATEWAY_TOKEN: ${OPENCLAW_GATEWAY_TOKEN:0:8}..."

# Initialize OpenClaw config
echo ""
echo "Initializing OpenClaw configuration..."

# Install Telegram plugin first
echo "Installing Telegram plugin..."
node /app/dist/index.js plugins install telegram 2>&1 || echo "Plugin install completed"

# Set gateway mode to local
echo "Setting gateway mode..."
node /app/dist/index.js config set gateway.mode local 2>/dev/null || true

# Enable Telegram channel if token is provided
if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
    echo "Enabling Telegram channel..."
    node /app/dist/index.js channels enable telegram 2>&1 || echo "Channel enable completed"
fi

# Run doctor --fix to apply all fixes
echo "Running doctor --fix..."
node /app/dist/index.js doctor --fix --yes 2>&1 || echo "Doctor fix completed"
echo ""

# Run the gateway with proper signal handling
# Use "lan" to accept connections from Railway's load balancer
exec node /app/dist/index.js gateway \
    --allow-unconfigured \
    --port "${PORT:-3000}" \
    --bind lan
