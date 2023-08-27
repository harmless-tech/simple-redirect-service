FROM alpine:edge as builder

RUN apk add --no-cache crystal shards openssl-dev
RUN crystal --version

WORKDIR /app
COPY . .

RUN shards install --production
RUN shards build --production --release --verbose

FROM alpine:edge

RUN apk add --no-cache \
    libevent-dev \
    pcre2-dev \
    gc-dev

WORKDIR /app

COPY --from=builder /app/bin/simple-redirect-service .
COPY --from=builder /app/LICENSE .

ENTRYPOINT [ "/app/simple-redirect-service" ]
