# Simple Redirect Service

## Getting Started
Add your redirects into a redirects.json file in the root directory with the format:
```json
{
  "redirects": {
    "ID1": "FULL_URL",
    "ID2": "FULL_URL",
    "ID3": "FULL_URL"
  }
}
```

### Using the docker container
```shell
docker run -p 3000:3000 --name "srs" --rm \
--mount type=bind,source="$(pwd)/redirects.json",target=/app/redirects.json \
quay.io/harmless-tech/simple-redirect-service:latest
```

### Running
```shell
cargo run (--release)
```
Will run at http://localhost:3000 by default.

### Building
```shell
cargo build (--release)
```
