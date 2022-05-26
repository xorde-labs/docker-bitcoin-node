FROM alpine:latest as builder

ENV BLOCKCHAIN_NAME=bitcoin

WORKDIR /workdir

ARG SOURCE_VERSION
ARG SOURCE_REPO=https://github.com/bitcoin/bitcoin
ARG DOCKER_GIT_SHA

### Install required dependencies
RUN apk upgrade -U && \
    apk add curl git autoconf automake make gcc g++ clang libtool && \
    apk add protobuf-dev libqrencode-dev libevent-dev chrpath zeromq-dev sqlite-dev boost-dev miniupnpc-dev

RUN mkdir -p build_info && printenv | tee build_info/build_envs.txt

### checkout latest _RELEASE_ so we will build stable
### (we do not want to build working master for production)
RUN git clone --depth 1 -c advice.detachedHead=false \
    -b ${SOURCE_VERSION:-$(basename $(curl -Ls -o /dev/null -w %{url_effective} ${SOURCE_REPO}/releases/latest))} \
    ${SOURCE_REPO}.git ${BLOCKCHAIN_NAME}

### Save git commit sha of the repo to build_info dir
RUN cd ${BLOCKCHAIN_NAME} && echo "SOURCE_SHA=$(git rev-parse HEAD)" | tee -a ../build_info/build_envs.txt

### Configure sources
RUN cd ${BLOCKCHAIN_NAME} \
    && ./autogen.sh \
    && ./configure \
    --prefix=/usr \
    --enable-hardening \
    --enable-static \
    --disable-openssl-tests \
    --disable-tests \
    --disable-bench \
    --without-bdb \
    --disable-gui \
    --disable-man

### Make build
RUN cd ${BLOCKCHAIN_NAME} \
    && make -j4

### Install build
RUN cd ${BLOCKCHAIN_NAME} \
    && mkdir -p /workdir/build \
    && make install DESTDIR=/workdir/build \
    && find /workdir/build

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
COPY --from=builder /workdir/build_info/ .

### Output build binary deps to check if it is compiled static (or else missing some libraries):
RUN find . -type f -exec sha256sum {} \; \
    && ldd /usr/bin/bitcoind \
    && echo "Built version: $(./version.sh)"

RUN mkdir -p .bitcoin \
    && chown -R ${BLOCKCHAIN_NAME} .

USER ${BLOCKCHAIN_NAME}

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 8332 8333
