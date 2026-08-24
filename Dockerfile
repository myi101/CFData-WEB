FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN go env -w GOPROXY=https://goproxy.cn,direct && go build -o cfdata-web .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/cfdata-web .
EXPOSE 8080
CMD ["./cfdata-web"]
