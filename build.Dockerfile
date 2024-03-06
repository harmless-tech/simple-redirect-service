FROM crystallang/crystal:latest-alpine

RUN crystal --version

WORKDIR /app

COPY spec/ ./spec
COPY shard.yml .
COPY shard.lock .

RUN shards install --production

COPY src/ ./src
COPY LICENSE .

RUN shards build --production --release --static --verbose
RUN strip --strip-all ./bin/simple-redirect-service
