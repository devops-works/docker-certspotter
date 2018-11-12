# certspotter Docker image

This is an (unofficial) image for
[SSLMate/certspotter](https://github.com/SSLMate/certspotter), a Certificate
Transparency Log Monitor.

It will warn you in slack when a new certificate is found in the [CT
logs](https://www.certificate-transparency.org/).

## Usage

### Using this image

```bash
docker run -d --name certspotter \
    -e CS_DELAY=43200 \
    -e CS_DOMAINS=".everything.org www.specific.org" \
    -e CS_SLACK_URL=https://hooks.slack.com/services/SOME/SLACK/TOKEN \
    -e CS_DEBUG=1 \
    devopsworks/certspotter
```

#### Environment variables

| Variable     | Description                                  | Default           |
| ------------ | -------------------------------------------- | ----------------- |
| CS_DELAY     | Interval between `certspotter` runs          | 86400 (1 day)     |
| CS_DOMAINS   | Domains to watch for                         | none (compulsory) |
| CS_SLACK_URL | Slack URL for notifications                  | none              |
| CS_DEBUG     | Sets `certspotter` & scripts in verbose mode | ""                |

### Additionnal notification hooks

The image will execute any script present in `/certspotter/hooks.d/` and passes
a message as the first argument.

Hooks will be called:

- when the container starts
- when a new certificate is found for the watched domains

#### Example

```bash
mkdir hooks.d/
cat > hooks.d/url.sh<<EOF
#!/bin/bash

echo -e "${1}\n" | curl -sXPOST http://some.url/seen --data @-
EOF
chmod +x hooks.d/url.sh
docker run -d --name certspotter \
    -v $(pwd)/hooks.d/:/certspotter/hooks.d/ \
    -e CS_DELAY=43200 \
    -e CS_DOMAINS=".everything.org www.specific.org" \
    -e CS_SLACK_URL=https://hooks.slack.com/services/SOME/SLACK/TOKEN \
    -e CS_DEBUG=1 \
    devopsworks/certspotter
```

### Building your own

```bash
docker build . -t some/tag
```

## Caveats

`DNS_DOMAINS` and `-script` are not used since I could not make them work.
Debugging required...

