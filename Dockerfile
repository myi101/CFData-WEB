FROM alpine:3.22

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY cfdata-linux-arm64 /app/cfdata

RUN chmod +x /app/cfdata

EXPOSE 13335

CMD ["/app/cfdata"]
