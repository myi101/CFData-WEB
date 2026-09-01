FROM alpine:latest

WORKDIR /app

# 额外添加 tzdata 以防止部分 Go 程序的时区报错
RUN apk add --no-cache ca-certificates tzdata

COPY cfdata-linux-arm64 /app/cfdata

RUN chmod +x /app/cfdata

EXPOSE 13335

CMD ["/app/cfdata"]
