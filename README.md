# Website

This website is built using [Docusaurus](https://docusaurus.io/), a modern static website generator.

## Installation

```bash
yarn
```

## Local Development

```bash
yarn start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

If you want the Wi-Fi card to appear on the homepage, define both `WIFI_SSID` and `WIFI_PASSWORD` before starting the app. If `WIFI_SSID` is not set, the card stays hidden. If only `WIFI_SSID` is set, the card shows the SSID only.

Examples:

```bash
WIFI_SSID="Git Workshop" WIFI_PASSWORD="12345678" yarn start
```

```bash
WIFI_SSID="Git Workshop" yarn start
```

## Build

```bash
yarn build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

## Deployment

Using SSH:

```bash
USE_SSH=true yarn deploy
```

Not using SSH:

```bash
GIT_USER=<Your GitHub username> yarn deploy
```

If you are using GitHub pages for hosting, this command is a convenient way to build the website and push to the `gh-pages` branch.
