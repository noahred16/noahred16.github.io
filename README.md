# noahred16.github.io
Personal GitHub Page to showcase some open source projects, host a blog, or even share your résumé.  

## Link to GitHub Page
[noahred16.github.io](https://noahred16.github.io/)

## Server Setup
```bash
mkdir -p ~/repos && cd ~/repos && git clone git@github.com:noahred16/noahred16.github.io.git
cd noahred16.github.io && ./setup.sh
```

## Run Locally
No build step and no Docker needed. Any static file server works:
```bash
python3 -m http.server 8000
```
Open [http://localhost:8000](http://localhost:8000). Use a server rather than opening `index.html` directly: as a `file://` page, the Processing sketches can't load their `.pde` files.

## Event Cards
Birthday, anniversary, and other event cards are configured in `js/events-data.js` and show up only while today's date is inside their `start_date`–`end_date` window.

To preview the site on a different date, add `?date=YYYY-MM-DD`:
- [localhost:8000/?date=2026-10-26](http://localhost:8000/?date=2026-10-26)
- [localhost:8000/?date=2026-11-22](http://localhost:8000/?date=2026-11-22)

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
