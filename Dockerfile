FROM crystallang/crystal:latest-alpine as builder

RUN crystal --version

WORKDIR /app

COPY spec/ ./spec
COPY shard.yml .
COPY shard.lock .

RUN shards install --production

COPY src/ ./src
COPY LICENSE .

RUN shards build --production --release --static --verbose

FROM scratch

WORKDIR /app

COPY --from=builder /app/bin/simple-redirect-service .
COPY --from=builder /app/LICENSE .

ENTRYPOINT [ "/app/simple-redirect-service" ]
