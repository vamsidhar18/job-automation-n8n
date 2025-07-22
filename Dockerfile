# Multi-stage build to keep n8n + Playwright under 4GB
FROM node:18-alpine as builder

# Install Playwright in builder stage
RUN npm install -g playwright @playwright/test
RUN npx playwright install chromium --with-deps

# Main stage - start with n8n
FROM n8nio/n8n:1.68.0

USER root

# Install minimal system dependencies
RUN apk add --no-cache \
    chromium \
    curl \
    jq \
    bash \
    python3 \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

# Copy Playwright from builder (more efficient than installing)
COPY --from=builder /root/.cache/ms-playwright/chromium-* /ms-playwright/chromium/
COPY --from=builder /usr/local/lib/node_modules/playwright /usr/local/lib/node_modules/playwright

# Install essential automation packages
RUN npm install -g \
    playwright \
    puppeteer-extra \
    puppeteer-extra-plugin-stealth \
    && npm cache clean --force

# Set up browser environment
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true
ENV CHROME_BIN=/usr/bin/chromium-browser

# Browser flags for Railway + stealth
ENV CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --disable-web-security --headless --disable-features=VizDisplayCompositor"

USER node

# Create n8n directories
RUN mkdir -p /home/node/.n8n/nodes \
    && mkdir -p /home/node/.n8n/custom \
    && chown -R node:node /home/node/.n8n

# Copy configuration files
COPY --chown=node:node n8n-config.json /home/node/.n8n/config/
COPY --chown=node:node fallback-jobs.json /home/node/.n8n/

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:${PORT:-5678}/healthz || exit 1

EXPOSE $PORT

# Startup script
COPY --chown=node:node start-n8n-latest.sh /home/node/
RUN chmod +x /home/node/start-n8n-latest.sh

CMD ["/home/node/start-n8n-latest.sh"]
