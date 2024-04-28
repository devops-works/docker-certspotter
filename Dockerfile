ARG GO_VERSION=1.22.2

# Go builder

FROM golang:${GO_VERSION} AS builder

RUN go install software.sslmate.com/src/certspotter/cmd/certspotter@latest

# Final image

FROM debian:bookworm

ENV TINI_VERSION v0.19.0

RUN apt-get update && \
  apt-get install -y curl && \
  rm -rf /var/lib/apt/lists/*

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

RUN mkdir /certspotter/ && \
  cd /certspotter && \
  mkdir -p .certspotter .certspotter/hooks.d bin  && \
  chown -R 65534:65534 /certspotter && \
  usermod --home /certspotter nobody

COPY --from=builder /go/bin/certspotter /certspotter/bin/certspotter

ADD docker-entrypoint.sh /certspotter/bin/docker-entrypoint.sh
ADD base-hooks.d/* /certspotter/.certspotter/hooks.d/
ADD utils.bash /certspotter/
ADD notify.sh /certspotter/bin/notify.sh
RUN chmod +x /tini /certspotter/bin/docker-entrypoint.sh /certspotter/bin/notify.sh /certspotter/bin/certspotter /certspotter/.certspotter/hooks.d/*

USER nobody:nogroup

ENTRYPOINT ["/tini", "--", "/certspotter/bin/docker-entrypoint.sh"]

