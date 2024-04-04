default:
    just -l

pwd := `pwd`
runner := 'docker'

fmt:
    cargo +nightly fmt

mem:
    cargo build
    /usr/bin/time -l ./target/debug/kot

memr:
    cargo build --release
    /usr/bin/time -l ./target/release/kot

default_cargo_version := "stable"
check CARGO=default_cargo_version:
    cargo +nightly fmt --check
    cargo +{{CARGO}} clippy --all-targets --locked --workspace -- -D warnings
    cargo +{{CARGO}} clippy --all-targets --locked --workspace --release -- -D warnings
    cargo +{{CARGO}} deny check

default_log_level := 'INFO'
sup-lint LOG_LEVEL=default_log_level:
    {{runner}} run -t --rm --pull=always \
    --platform=linux/amd64 \
    -e LOG_LEVEL={{LOG_LEVEL}} \
    -e RUN_LOCAL=true \
    -e SHELL=/bin/bash \
    -e DEFAULT_BRANCH=main \
    -e VALIDATE_ALL_CODEBASE=true \
    -e VALIDATE_RUST_2015=false \
    -e VALIDATE_RUST_2018=false \
    -e VALIDATE_RUST_2021=false \
    -e VALIDATE_RUST_CLIPPY=false \
    --mount type=bind,source='{{pwd}}',target=/tmp/lint \
    ghcr.io/super-linter/super-linter:slim-latest

deb:
    {{runner}} run -it --rm --pull=always \
    -e CARGO_TARGET_DIR=/ptarget \
    --mount type=bind,source='{{pwd}}',target=/project \
    --mount type=bind,source="$HOME"/.cargo/registry,target=/usr/local/cargo/registry \
    -w /project \
    -p 3000:3000 \
    rust:latest \
    bash

alpine:
    {{runner}} run -it --rm --pull=always \
    -e CARGO_TARGET_DIR=/ptarget \
    --mount type=bind,source='{{pwd}}',target=/project \
    --mount type=bind,source="$HOME"/.cargo/registry,target=/usr/local/cargo/registry \
    -w /project \
    -p 3000:3000 \
    rust:alpine \
    sh
