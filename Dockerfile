FROM ghcr.io/crow-rest/crystal:alpine as builder

WORKDIR /app
COPY . .

RUN shards install --production
RUN shards build --production --release --verbose

FROM alpine:latest

RUN apk add --no-cache \
    libevent-dev \
    pcre-dev \
    gc-dev

WORKDIR /app

COPY --from=builder /app/bin/simple-redirect-service .
COPY --from=builder /app/LICENSE .

ENTRYPOINT [ "/app/simple-redirect-service" ]
