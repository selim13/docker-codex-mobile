# Codexapp Docker Container

Docker image for running OpenAI Codex TUI together with the [codexapp](https://github.com/friuns2/codex-mobile)
web UI and a minimal runtime environment for generic agent usage.

## codexapp changes

codexapp is built from [fork repository](https://github.com/selim13/codex-mobile). Changes against upstream so far:

- Added Russian translation
- Added build time default language selection via `CODEXUI_DEFAULT_UI_LANGUAGE` ARG

## Usage

```yaml
services:
  codex:
    image: ghcr.io/selim13/codex-mobile:latest
    ports:
      - "18923:18923"
    volumes:
      - ./codex-home:/home/codex
```

Use the Codex TUI login flow to populate `auth.json`:

```sh
docker compose run --rm -it codex codex
```

Run codexapp:

```sh
docker compose up -d
```

Access via HTTP at port 18923.

The native web UI password is created on first start and reused from
`./codex-home/.codex/codexui-password` on later restarts. To change it, edit that file and restart
the container. Delete `./codex-home/.codex/webui-auth-sessions.json` as well to force existing
browsers to sign in again.

Probably put it behind reverse proxy like traefik with proper TLS termination.

## AI usage scale

🤖🧑‍💻💩 4/5 - human-assisted AI slop.

## License

MIT
