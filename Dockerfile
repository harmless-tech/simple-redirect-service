# syntax=docker/dockerfile:1.4
FROM rust:alpine as builder
ARG TARGETARCH
ARG BUILD_PROFILE=release

WORKDIR /app-build
RUN mkdir -p /app-bin

RUN --mount=type=cache,id=apk,target=/etc/apk/cache,sharing=shared \
    apk update && apk add alpine-sdk perl bash

RUN --mount=type=cache,target=/prebuilt,sharing=locked <<EOT
    set -e
    export PATH=$PATH:/prebuilt/bin
    if [ ! -f /prebuilt/bin/cargo-prebuilt ]; then
        curl --proto '=https' --tlsv1.2 -sSf \
            https://raw.githubusercontent.com/cargo-prebuilt/cargo-prebuilt/main/scripts/install-cargo-prebuilt.sh \
            | LIBC=musl INSTALL_PATH=/prebuilt/bin FORCE=true bash;
    fi
    cargo prebuilt --path=/prebuilt/bin cargo-auditable
EOT

COPY LICENSE .
COPY Cargo.toml .
COPY Cargo.lock .
COPY src src

RUN --mount=type=cache,target=/app-build/target,sharing=locked --mount=type=cache,id=cargo,target=$CARGO_HOME/registry --mount=type=cache,target=/prebuilt,sharing=locked <<EOT
    set -e
    export ARCH="$(uname -m)"
    if [ $ARCH == 'aarch64' ]; then export CFLAGS=-mno-outline-atomics; fi
    if [ $BUILD_PROFILE == 'dev' ]; then BUILD_DIR=debug; else BUILD_DIR=$BUILD_PROFILE; fi
    export PATH=$PATH:/prebuilt/bin
    cargo auditable build --profile="$BUILD_PROFILE" --target=$ARCH-unknown-linux-musl

    mv target/$ARCH-unknown-linux-musl/$BUILD_DIR/simple-redirect-service /app-bin/
    mv LICENSE /app-bin/
EOT

FROM scratch

WORKDIR /app

COPY --from=builder /app-bin/simple-redirect-service .
COPY --from=builder /app-bin/LICENSE .

EXPOSE 3000
ENTRYPOINT ["/app/simple-redirect-service"]
