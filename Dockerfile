# Latest n8n Dockerfile optimized for job automation (Railway Compatible)
FROM n8nio/n8n:1.68.0

USER root

# Install Playwright and dependencies for job scraping
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
    && rm -rf /var/cache/apk/*

# Install Node.js packages for advanced automation
RUN npm install -g \
    playwright \
    puppeteer \
    puppeteer-extra \
    puppeteer-extra-plugin-stealth \
    @playwright/test

# Install Playwright browsers
RUN npx playwright install chromium firefox webkit

# Set environment for browsers
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

USER node

# Create n8n directories with proper permissions
RUN mkdir -p /home/node/.n8n/nodes \
    && mkdir -p /home/node/.n8n/custom \
    && mkdir -p /home/node/.n8n/workflows \
    && mkdir -p /home/node/.n8n/credentials \
    && chown -R node:node /home/node/.n8n

# Copy optimized n8n configuration
COPY --chown=node:node n8n-config.json /home/node/.n8n/config/

# Copy fallback test data
COPY --chown=node:node fallback-jobs.json /home/node/.n8n/

# Health check for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:${PORT:-5678}/healthz || exit 1

# Railway handles persistence automatically - no VOLUME needed
EXPOSE $PORT

# Custom startup script
COPY --chown=node:node start-n8n-latest.sh /home/node/
RUN chmod +x /home/node/start-n8n-latest.sh

CMD ["/home/node/start-n8n-latest.sh"]
