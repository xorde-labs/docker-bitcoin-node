FROM alpine:latest as builder

ENV BLOCKCHAIN_NAME=bitcoin

WORKDIR /workdir

RUN apk upgrade -U && \
    apk add curl git autoconf automake make gcc g++ clang libtool boost-dev miniupnpc-dev && \
    apk add protobuf-dev libqrencode-dev libevent-dev chrpath zeromq-dev

### checkout latest _RELEASE_ so we will build stable
### (we do not want to build working master for production)
RUN git -c advice.detachedHead=false clone -b $(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/bitcoin/bitcoin/releases/latest)) https://github.com/bitcoin/bitcoin.git ${BLOCKCHAIN_NAME}

### Save git commit sha of the repo to build dir
RUN cd ${BLOCKCHAIN_NAME} && mkdir -p /workdir/build && echo "${BLOCKCHAIN_NAME}:$(git rev-parse HEAD)" | tee /workdir/build/${BLOCKCHAIN_NAME}-commit-sha.txt

###
RUN cd ${BLOCKCHAIN_NAME} && ./autogen.sh && ./configure \
    --prefix=/usr \
    --enable-hardening \
    --enable-static \
    --disable-openssl-tests \
    --disable-ccache \
    --without-bdb \
    --disable-tests \
    --disable-bench \
    --disable-gui \
    --disable-util-tx \
    --disable-man

###
RUN cd ${BLOCKCHAIN_NAME} && make -j4

###
RUN cd ${BLOCKCHAIN_NAME} && make install DESTDIR=/workdir/build && find /workdir/build

### Output any missing library deps:
RUN { for i in $(find /workdir/build/usr/bin/ -type f -executable -print); \
    do readelf -d $i 2>/dev/null | grep NEEDED | awk '{print $5}' | sed "s/\[//g" | sed "s/\]//g"; done; } | sort -u

FROM alpine:latest

### https://specs.opencontainers.org/image-spec/annotations/
LABEL org.opencontainers.image.title="Bitcoin Node Docker Image"
LABEL org.opencontainers.image.vendor="Xorde Technologies"
LABEL org.opencontainers.image.source="https://github.com/xorde-nodes/bitcoin-node"

ENV BLOCKCHAIN_NAME=bitcoin
WORKDIR /home/${BLOCKCHAIN_NAME}

### Add packages
RUN apk upgrade -U \
    && apk add openssl ca-certificates boost miniupnpc libevent libzmq libstdc++ libgcc

### Add group
RUN addgroup -S ${BLOCKCHAIN_NAME}

### Add user
RUN adduser -S -D -H -h /home/${BLOCKCHAIN_NAME} \
    -s /sbin/nologin \
    -G ${BLOCKCHAIN_NAME} \
    -g "User of ${BLOCKCHAIN_NAME}" \
    ${BLOCKCHAIN_NAME}

### Copy script files (entrypoint, config, etc)
COPY ./scripts .
RUN chmod 755 ./*.sh && ls -adl ./*.sh

### Copy build result from builder context
COPY --from=builder /workdir/build /

### Output bitcoind library deps to check if bitcoind is compiled static:
RUN find . -type f -exec sha256sum {} \; \
    && ldd /usr/bin/bitcoind \
    && echo "Built version: $(./version.sh)"

RUN mkdir -p .bitcoin \
    && chown -R ${BLOCKCHAIN_NAME} .

USER ${BLOCKCHAIN_NAME}

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 8332 8333
