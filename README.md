# noahred16.github.io
Personal GitHub Page to showcase some open source projects, host a blog, or even share your résumé.  

## Link to GitHub Page
[noahred16.github.io](https://noahred16.github.io/)

## Server Setup
```bash
mkdir -p ~/repos && cd ~/repos && git clone git@github.com:noahred16/noahred16.github.io.git
cd noahred16.github.io && ./setup.sh
```

## Run over Tailscale
```bash
docker compose up -d
docker compose down
```
Live at [http://100.108.225.5:8081](http://100.108.225.5:8081) from any device on the tailnet.

Override the bind address or port with `TAILSCALE_IP` / `SITE_PORT` in a `.env` file.

## Tools
```bash
./tools.sh
curl -fsSL https://claude.ai/install.sh | bash
curl -LsSf https://hf.co/cli/install.sh | bash
```
