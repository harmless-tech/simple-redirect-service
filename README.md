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

*SRS currently requires [bun](https://bun.sh/) 0.1.7 or greater.*

### Running
```shell
bun run start
```
Will run at http://localhost:3000 by default.

### Stats
To get stats just add /stats to the end of any redirect url.
