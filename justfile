set dotenv-load := true

@default:
    just --list

build:
    docker compose build

lint:
    docker compose config --quiet
    hadolint --failure-threshold error Dockerfile

up:
    docker compose up

down:
    docker compose down

codex:
    docker compose run --rm -it codexapp codex

shell:
    docker compose run --rm -it codexapp bash
