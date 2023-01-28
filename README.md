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
TODO
```shell
docker run -p 3000:3000 --name "srs" --mount type=bind,source="$(pwd)/redirects.json",target=/app/redirects.json TODO
```

### Running
```shell
shards run (--release)
```
Will run at http://localhost:3000 by default.

### Building
```shell
shards build (--release)
```

Binary will be put in the bin folder as simple-redirect-service
