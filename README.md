# Moltbot on Primis

Deploy [Moltbot](https://github.com/moltbot/moltbot) with one click using Primis.

## Quick Deploy to Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https://github.com/primisprotocol/moltbot-template)

## What is Moltbot?

Moltbot is a powerful AI assistant that lives in your chat apps. It can:

- 💬 Chat via Telegram, Discord, Slack, and more
- 🤖 Use Claude (Anthropic) or GPT (OpenAI) as the AI brain
- 📁 Read and create files
- 🔧 Execute commands and automate tasks
- 🌐 Browse the web and fetch information
- 🎨 Generate images
- 🔗 Connect to your other apps via plugins

## Setup

### 1. Get Your API Keys

#### AI Provider (Required - choose one)

**Claude (Anthropic)** - Recommended
1. Go to [console.anthropic.com](https://console.anthropic.com/)
2. Create an API key
3. Copy it

**GPT (OpenAI)**
1. Go to [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Create an API key
3. Copy it

#### Chat Channels (At least one recommended)

**Telegram** - Easiest
1. Message [@BotFather](https://t.me/BotFather) on Telegram
2. Send `/newbot`
3. Follow the prompts
4. Copy the bot token

**Discord**
1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Create a new application
3. Go to "Bot" section, click "Add Bot"
4. Copy the token
5. Enable "Message Content Intent" under Privileged Gateway Intents
6. Go to OAuth2 → URL Generator
7. Select `bot` and `applications.commands` scopes
8. Select required permissions
9. Use the generated URL to invite the bot to your server

### 2. Deploy

#### Option A: Railway (Recommended)

1. Click the "Deploy on Railway" button above
2. Set environment variables:
   - `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`
   - `TELEGRAM_BOT_TOKEN` or `DISCORD_BOT_TOKEN`
3. Deploy!
4. Wait 5-10 minutes for the first build

#### Option B: Docker

```bash
# Clone the template
git clone https://github.com/primisprotocol/moltbot-template.git
cd moltbot-template

# Copy and edit environment variables
cp .env.example .env
nano .env  # Add your API keys

# Run with Docker Compose
docker-compose up --build -d

# Check logs
docker-compose logs -f
```

#### Option C: Local Development

```bash
# Clone Moltbot directly
git clone https://github.com/moltbot/moltbot.git
cd moltbot

# Requires Node.js 22+
pnpm install
pnpm build

# Set environment variables
export ANTHROPIC_API_KEY=sk-ant-xxx
export TELEGRAM_BOT_TOKEN=123:abc

# Run gateway
pnpm moltbot gateway
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes* | Claude API key |
| `OPENAI_API_KEY` | Yes* | OpenAI API key (alternative) |
| `TELEGRAM_BOT_TOKEN` | No | Telegram bot token |
| `DISCORD_BOT_TOKEN` | No | Discord bot token |
| `SLACK_BOT_TOKEN` | No | Slack bot token |
| `PORT` | No | Gateway port (default: 3000) |

*At least one AI provider key is required.

## Troubleshooting

### Build takes too long
First build clones and compiles Moltbot from source (~5-10 minutes). Subsequent deploys use cached layers and are faster.

### Bot not responding
1. Check that your API keys are correct
2. Verify bot token is from the right platform
3. Check Railway logs for errors
4. For Discord, ensure "Message Content Intent" is enabled

### Out of memory
Increase the Railway instance size or set `NODE_OPTIONS=--max-old-space-size=2048`

### Health check failing
First deploy needs up to 5 minutes to build. If it keeps failing:
1. Check Railway logs
2. Verify environment variables are set
3. Try redeploying

## Resources

- [Moltbot Documentation](https://docs.molt.bot)
- [Moltbot GitHub](https://github.com/moltbot/moltbot)
- [Railway Documentation](https://docs.railway.app)
- [Primis Protocol](https://primisprotocol.ai)

## Support

- **Moltbot issues**: [github.com/moltbot/moltbot/issues](https://github.com/moltbot/moltbot/issues)
- **Primis support**: [Discord](https://discord.gg/primis)

---

*Powered by [Primis Protocol](https://primisprotocol.ai) - Deploy AI cheaper*
