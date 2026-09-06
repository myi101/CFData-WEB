FROM alpine:latest

WORKDIR /app

# CA 证书 + 时区
RUN apk add --no-cache ca-certificates tzdata

# Workflow 会根据目标架构，把官方 Release 二进制复制为 cfdata
COPY cfdata /app/cfdata

RUN chmod +x /app/cfdata

EXPOSE 13335

CMD ["/app/cfdata"]
