# Original n8n + Playwright architecture for massive job automation
# Requires Railway Pro (32GB limit) for full features
FROM n8nio/n8n:1.68.0

USER root

# Install all browsers and dependencies for maximum compatibility
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    firefox \
    webkit2gtk \
    python3 \
    py3-pip \
    curl \
    jq \
    git \
    bash \
    dbus \
    xvfb \
    && rm -rf /var/cache/apk/*

# Install full Node.js automation stack
RUN npm install -g \
    playwright \
    puppeteer \
    puppeteer-extra \
    puppeteer-extra-plugin-stealth \
    puppeteer-extra-plugin-anonymize-ua \
    puppeteer-extra-plugin-block-resources \
    @playwright/test \
    && npm cache clean --force

# Install all Playwright browsers with dependencies
RUN npx playwright install --with-deps chromium firefox webkit

# Set up comprehensive browser environment
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV FIREFOX_BIN=/usr/bin/firefox

# Advanced browser flags for stealth and compatibility
ENV CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --disable-web-security --disable-features=VizDisplayCompositor --disable-blink-features=AutomationControlled"

# Stealth mode environment variables
ENV PLAYWRIGHT_STEALTH=true
ENV PUPPETEER_STEALTH=true

USER node

# Create comprehensive n8n directory structure
RUN mkdir -p /home/node/.n8n/nodes \
    && mkdir -p /home/node/.n8n/custom \
    && mkdir -p /home/node/.n8n/workflows \
    && mkdir -p /home/node/.n8n/credentials \
    && mkdir -p /home/node/.n8n/logs \
    && chown -R node:node /home/node/.n8n

# Copy all configuration files
COPY --chown=node:node n8n-config.json /home/node/.n8n/config/
COPY --chown=node:node fallback-jobs.json /home/node/.n8n/

# Health check for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:${PORT:-5678}/healthz || exit 1

EXPOSE $PORT

# Full-featured startup script
COPY --chown=node:node start-n8n-latest.sh /home/node/
RUN chmod +x /home/node/start-n8n-latest.sh

CMD ["/home/node/start-n8n-latest.sh"]
