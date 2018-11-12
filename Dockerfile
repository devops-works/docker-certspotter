ARG GO_VERSION=1.11

# Go builder

FROM golang:${GO_VERSION} AS builder

RUN go get software.sslmate.com/src/certspotter/cmd/certspotter

# Final image

FROM debian:stretch

ENV TINI_VERSION v0.18.0

RUN apt-get update && \
  apt-get install -y curl && \
  rm -rf /var/lib/apt/lists/*

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

RUN mkdir /certspotter/ && \
  cd /certspotter && \
  mkdir .certspotter bin base-hooks.d && \
  chown -R 65534:65534 /certspotter && \
  usermod --home /certspotter nobody

COPY --from=builder /go/bin/certspotter /certspotter/bin/certspotter

ADD docker-entrypoint.sh /certspotter/bin/docker-entrypoint.sh
ADD base-hooks.d/* /certspotter/base-hooks.d/
ADD utils.bash /certspotter/
ADD notify.sh /certspotter/bin/notify.sh
RUN chmod +x /tini /certspotter/bin/docker-entrypoint.sh /certspotter/bin/notify.sh /certspotter/bin/certspotter /certspotter/base-hooks.d/*

USER nobody:nogroup

ENTRYPOINT ["/tini", "--", "/certspotter/bin/docker-entrypoint.sh"]

