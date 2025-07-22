# n8n Job Automation System

Advanced job application automation using n8n + Playwright + AI scoring.

## Features
- 🤖 Automated job discovery from multiple platforms
- 🧠 AI-powered job scoring via FastAPI
- 🎭 Browser automation with Playwright
- 🔄 Fallback scoring when API is down
- 📊 Mass application capabilities

## Deployment
Deploy to Railway with one click from this repository.

## Configuration
Set these environment variables in Railway:
- `N8N_OWNER_EMAIL`
- `N8N_ENCRYPTION_KEY`
- `EXECUTIONS_DATA_PRUNE=true`

## URLs
- n8n Interface: `https://your-app.up.railway.app`
- Health Check: `https://your-app.up.railway.app/healthz`
- Test Webhook: `https://your-app.up.railway.app/webhook/test-webhook`

