# AGENTS.md

## Development Environment

- The development environment runs via Docker Compose (`compose.yml`, `Dockerfile.dev`); never install runtimes or packages on the host, and run dev commands inside the app container, e.g. `docker compose up -d` then `docker compose exec app <command>`.
