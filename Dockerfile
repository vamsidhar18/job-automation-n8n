# n8n + Playwright on Ubuntu base for Railway Pro compatibility
FROM ubuntu:22.04

# Install Node.js and system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install n8n
RUN npm install -g n8n@1.68.0

# Install Playwright and browsers (Ubuntu native support)
RUN npm install -g \
    playwright \
    puppeteer \
    puppeteer-extra \
    puppeteer-extra-plugin-stealth \
    @playwright/test

# Install Playwright browsers with dependencies (this works on Ubuntu!)
RUN npx playwright install --with-deps chromium firefox webkit

# Create n8n user
RUN useradd -m -s /bin/bash n8n

# Set up n8n directories
USER n8n
WORKDIR /home/n8n

RUN mkdir -p /home/n8n/.n8n/nodes \
    && mkdir -p /home/n8n/.n8n/custom \
    && mkdir -p /home/n8n/.n8n/workflows \
    && mkdir -p /home/n8n/.n8n/credentials

# Copy configuration files
COPY --chown=n8n:n8n n8n-config.json /home/n8n/.n8n/config/
COPY --chown=n8n:n8n fallback-jobs.json /home/n8n/.n8n/
COPY --chown=n8n:n8n start-n8n-latest.sh /home/n8n/
RUN chmod +x /home/n8n/start-n8n-latest.sh

# Environment variables for browsers
ENV PLAYWRIGHT_BROWSERS_PATH=/home/n8n/.cache/ms-playwright
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PLAYWRIGHT_STEALTH=true
ENV PUPPETEER_STEALTH=true

# Health check
USER root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
USER n8n

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD curl -f http://localhost:${PORT:-5678}/healthz || exit 1

EXPOSE $PORT

CMD ["/home/n8n/start-n8n-latest.sh"]
