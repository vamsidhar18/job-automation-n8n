# ✅ Base n8n image
FROM n8nio/n8n:1.68.0

USER root

# ✅ Install Playwright and dependencies
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

# ✅ Install Node.js packages for browser automation
RUN npm install -g \
    playwright \
    puppeteer \
    puppeteer-extra \
    puppeteer-extra-plugin-stealth \
    @playwright/test

# ✅ Install Playwright browsers
RUN npx playwright install chromium firefox webkit

# ✅ Set Playwright environment
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

USER node

# ✅ Create n8n config folders
RUN mkdir -p /home/node/.n8n/nodes \
    && mkdir -p /home/node/.n8n/custom \
    && mkdir -p /home/node/.n8n/workflows \
    && mkdir -p /home/node/.n8n/credentials \
    && chown -R node:node /home/node/.n8n

# ✅ Copy n8n config and fallback job data
COPY --chown=node:node n8n-config.json /home/node/.n8n/config/
COPY --chown=node:node fallback-jobs.json /home/node/.n8n/

# ✅ Healthcheck for Railway (runs on /healthz)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD curl -f http://localhost:5678/healthz || exit 1

# ✅ Volume for persistence
VOLUME ["/home/node/.n8n"]

EXPOSE $PORT

# ✅ Copy startup script
COPY --chown=node:node start-n8n-latest.sh /home/node/
RUN chmod +x /home/node/start-n8n-latest.sh

# ✅ Run the custom startup script
CMD ["/bin/bash", "/home/node/start-n8n-latest.sh"]
