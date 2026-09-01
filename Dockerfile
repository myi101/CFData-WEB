FROM golang:1.25.4-alpine AS builder

WORKDIR /src

RUN apk add --no-cache ca-certificates curl

COPY combined_refactor/ ./combined_refactor/

WORKDIR /src/combined_refactor

RUN curl -fsSL --retry 3 --connect-timeout 10 \
    https://curl.se/ca/cacert.pem \
    -o ca-certificates.crt

ARG VERSION=dev

RUN CGO_ENABLED=0 \
    go build \
    -trimpath \
    -ldflags="-s -w -X main.appVersion=${VERSION}" \
    -o /cfdata-web .

FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=builder /cfdata-web /app/cfdata-web

EXPOSE 13335

CMD ["/app/cfdata-web"]
