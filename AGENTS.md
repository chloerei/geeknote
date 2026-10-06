# AGENTS.md

## Development Environment (devcontainer)

- Manage development environment dependencies through the devcontainer in `.devcontainer/`; do not install runtimes, system libraries, or packages on the host.
- Before running any dev-dependent command, check whether the current environment is already the devcontainer: `/.dockerenv` exists (Docker) or `/workspaces/chatbot` exists (the configured `workspaceFolder`). If not, run the command inside it via `devcontainer exec --workspace-folder . <command>`.
