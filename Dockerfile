# syntax=docker/dockerfile:1

FROM ghcr.io/astral-sh/uv:latest AS uv

FROM node:26-trixie-slim AS codexapp-builder

ARG CODEX_MOBILE_REPO=https://github.com/selim13/codex-mobile.git
ARG CODEX_MOBILE_REF=ru/translate
ARG CODEXUI_DEFAULT_UI_LANGUAGE=ru

ENV CI=true \
    VITE_DEFAULT_UI_LANGUAGE="${CODEXUI_DEFAULT_UI_LANGUAGE}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        pkg-config \
        python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/codex-mobile

RUN git clone --depth 1 --branch "$CODEX_MOBILE_REF" "$CODEX_MOBILE_REPO" . \
    && npm install --no-audit --no-fund \
    && npm run build:frontend \
    && npm run build:cli \
    && npm pack --pack-destination /tmp

FROM node:26-trixie-slim

ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_VERSION

LABEL org.opencontainers.image.title="codex-mobile" \
      org.opencontainers.image.description="Codex TUI and codex-mobile web UI container." \
      org.opencontainers.image.authors="Dmitry Seleznev <selim013@gmail.com>" \
      org.opencontainers.image.source="https://github.com/selim13/docker-codex-mobile" \
      org.opencontainers.image.url="https://github.com/selim13/docker-codex-mobile" \
      org.opencontainers.image.documentation="https://github.com/selim13/docker-codex-mobile#readme" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.version="${IMAGE_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        antiword \
        bash \
        build-essential \
        bzip2 \
        ca-certificates \
        catdoc \
        curl \
        file \
        git \
        imagemagick \
        jq \
        less \
        libarchive-tools \
        libimage-exiftool-perl \
        libxml2-utils \
        lz4 \
        odt2txt \
        openssh-client \
        p7zip-full \
        pkg-config \
        pandoc \
        poppler-utils \
        procps \
        python3 \
        python3-venv \
        ripgrep \
        rsync \
        sqlite3 \
        tidy \
        tini \
        tree \
        unar \
        unzip \
        wget \
        xlsx2csv \
        xmlstarlet \
        xz-utils \
        yq \
        zip \
        zstd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=uv /uv /uvx /usr/local/bin/
COPY --from=codexapp-builder /tmp/codexapp-*.tgz /tmp/codexapp.tgz
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY package.json package-lock.json /opt/codex-npm/

RUN npm ci --omit=dev --prefix /opt/codex-npm \
    && ln -s /opt/codex-npm/node_modules/.bin/codex /usr/local/bin/codex \
    && npm install -g /tmp/codexapp.tgz \
    && rm -f /tmp/codexapp.tgz \
    && npm cache clean --force

RUN groupmod --new-name codex node \
    && usermod --login codex --home /home/codex --move-home --shell /bin/bash node \
    && chown -R codex:codex /home/codex

ENV HOME=/home/codex \
    CODEX_HOME=/home/codex/.codex \
    SHELL=/bin/bash \
    NPM_CONFIG_PREFIX=/home/codex/.npm-global \
    PATH=/home/codex/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USER codex
WORKDIR /home/codex

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["--no-tunnel", "--no-open", "--port", "18923"]
