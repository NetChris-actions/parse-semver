# Container image that runs your code
FROM alpine:3.10

RUN apk add pcre2-tools

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
