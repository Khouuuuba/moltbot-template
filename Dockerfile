# ==============================================================================
# Moltbot Template - Optimized for Railway Deployment
# ==============================================================================
# This Dockerfile is designed for quick builds and small image size.
# Railway will automatically build and deploy from this file.
#
# Build: docker build -t moltbot .
# Run:   docker run -d -p 3000:3000 --env-file .env moltbot
# ==============================================================================

# Stage 1: Builder - Install dependencies and build
FROM node:22-bookworm AS builder

# Install build tools
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"
RUN corepack enable

WORKDIR /build

# Clone Moltbot source
# Pin to a specific commit for reproducible builds
ARG MOLTBOT_VERSION=main
RUN git clone --depth 1 --branch ${MOLTBOT_VERSION} https://github.com/openclaw/openclaw.git . && \
    rm -rf .git

# Install dependencies (cached layer if pnpm-lock.yaml unchanged)
RUN pnpm install --frozen-lockfile

# Build the application
ENV CLAWDBOT_A2UI_SKIP_MISSING=1
ENV CLAWDBOT_PREFER_PNPM=1
RUN pnpm build && pnpm ui:install && pnpm ui:build

# ==============================================================================
# Stage 2: Runtime - Minimal production image
# ==============================================================================
FROM node:22-bookworm-slim AS runtime

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built application from builder
COPY --from=builder /build/dist ./dist
COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build/package.json ./package.json
COPY --from=builder /build/ui/dist ./ui/dist

# Copy our startup scripts
COPY scripts/ ./scripts/
RUN chmod +x ./scripts/*.sh

# Create data directory for persistent storage
RUN mkdir -p /data && chown node:node /data

# Set production environment
ENV NODE_ENV=production
ENV CLAWDBOT_STATE_DIR=/data
ENV CLAWDBOT_PREFER_PNPM=1
ENV PORT=3000

# Security: Run as non-root user
USER node

# Expose the gateway port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start Moltbot via our startup script
CMD ["/app/scripts/start.sh"]
