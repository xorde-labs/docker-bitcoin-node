FROM alpine:edge

WORKDIR /root
# Add packages
RUN apk upgrade -U && \
    apk --update --repository=http://dl-4.alpinelinux.org/alpine/edge/testing add \
    openssl wget ca-certificates bitcoin bitcoin-cli \

RUN mkdir /root/.bitcoin/

EXPOSE 8332 8333

COPY ./scripts /root

CMD ["entrypoint.sh"]
