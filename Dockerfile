FROM alpine:latest

RUN apk add --no-cache bats bind bind-tools dnsmasq unbound
