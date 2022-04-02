FROM alpine:edge

# Add packages
RUN apk upgrade -U && \
    apk --update --repository=http://dl-4.alpinelinux.org/alpine/edge/testing add \
    openssl wget ca-certificates bitcoin bitcoin-cli

RUN \
	mkdir ~/.bitcoin/

EXPOSE 8332 8333

COPY ./bin /usr/local/bin

CMD ["entrypoint.sh"]
