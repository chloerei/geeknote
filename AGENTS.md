# AGENTS.md

## Development Environment

- Runs on Docker Compose (`compose.yml`, `Dockerfile.dev`); never install runtimes or packages on the host.
- Start it once with `docker compose up -d`, then run commands inside the running container: `docker compose exec app <command>` (e.g. `bin/rails test`, `bin/rubocop`). Prefer this over `docker compose run` or re-running `up`.

## Package Sources

- Use only the official registries (`https://rubygems.org`, `https://registry.npmjs.org`); never switch sources, use mirrors/proxies, or change the `Gemfile` source — if one is unreachable, stop and report.
