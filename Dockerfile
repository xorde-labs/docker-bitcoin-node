FROM alpine:latest as builder

WORKDIR /workdir

RUN apk upgrade -U && \
    apk add curl git autoconf automake make gcc g++ clang libtool boost-dev miniupnpc-dev && \
    apk add protobuf-dev libqrencode-dev libevent-dev chrpath zeromq-dev

### checkout latest _RELEASE_ so we will build stable
### (we do not want to build working master for production)
RUN git -c advice.detachedHead=false clone -b $(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/bitcoin/bitcoin/releases/latest)) https://github.com/bitcoin/bitcoin.git

###
RUN cd bitcoin && mkdir -p /workdir/build && echo "$(git rev-parse HEAD)" | tee /workdir/build/git-commit.txt

###
RUN cd bitcoin && ./autogen.sh && ./configure \
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
RUN cd bitcoin && make -j4

###
RUN cd bitcoin && make install DESTDIR=/workdir/build && find /workdir/build

### Output any missing library deps:
RUN { for i in $(find /workdir/build/usr/bin/ -type f -executable -print); do readelf -d $i 2>/dev/null | grep NEEDED | awk '{print $5}' | sed "s/\[//g" | sed "s/\]//g"; done; } | sort -u

FROM alpine:latest

WORKDIR /root

# Add packages
RUN apk upgrade -U && \
    apk add openssl ca-certificates boost miniupnpc libevent libzmq libstdc++ libgcc

RUN mkdir -p /root/.bitcoin/

###
COPY ./scripts /root
RUN chmod 777 /root/*.sh && ls -la /root/*.sh

###
COPY --from=builder /workdir/build /
RUN addgroup -S bitcoin 2>/dev/null && adduser -S -D -H -h /var/lib/bitcoin -s /sbin/nologin -G bitcoin -g bitcoin bitcoin 2>/dev/null

### Output bitcoind library deps to check if bitcoind is compiled static:
RUN ldd /usr/bin/bitcoind

RUN ls -la /root
CMD ["/root/entrypoint.sh"]

EXPOSE 8332 8333
