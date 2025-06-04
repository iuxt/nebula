FROM docker.io/golang:1.23-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod init xtemp-app && \
    go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build -o xtemp-app .

FROM docker.io/alpine:latest

ENV XTEMP_STORAGE_PATH=/var/lib/xtemp-store

WORKDIR /root/

RUN mkdir -p ${XTEMP_STORAGE_PATH} && chmod 700 ${XTEMP_STORAGE_PATH}

COPY --from=builder /app/static ./static

COPY --from=builder /app/xtemp-app .

EXPOSE 5000

CMD ["./xtemp-app"]
