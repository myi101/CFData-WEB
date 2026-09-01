FROM golang:1.22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache ca-certificates git curl

COPY combined_refactor/ ./combined_refactor/

WORKDIR /app/combined_refactor

RUN CGO_ENABLED=0 go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /cfdata-web .

FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=builder /cfdata-web /app/cfdata-web

EXPOSE 13335

CMD ["/app/cfdata-web"]
