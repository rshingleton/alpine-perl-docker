FROM alpine:latest AS BUILD-IMAGE

ARG PERL_VERSION="perl-5.36.0"
## alpine curl and wget aren't fully compatible, so we install them
## here. gnupg is needed for Module::Signature.
RUN apk update && apk upgrade && apk add --no-cache \
        build-base \
        curl \
        gcc \
        gnupg \
        make \
        openssl \
        openssl-dev \
        tar \
        zlib \
        zlib-dev \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /usr/src/perl
WORKDIR /usr/src/perl

## from perl; `true make test_harness` because 3 tests fail
## some flags from http://git.alpinelinux.org/cgit/aports/tree/main/perl/APKBUILD?id=19b23f225d6e4f25330e13144c7bf6c01e624656
RUN curl -SLO https://www.cpan.org/src/5.0/$PERL_VERSION.tar.gz \
    && tar --strip-components=1 -xzf $PERL_VERSION.tar.gz -C /usr/src/perl \
    && rm $PERL_VERSION.tar.gz \
    && ./Configure -des \
        -Duse64bitall \
        -Dcccdlflags='-fPIC' \
        -Dccdlflags='-rdynamic' \
        -Dlocincpth=' ' \
        -Duselargefiles \
        -Duseshrplib \
        -Dd_semctl_semun \
        -Dusenm \
        -Dprefix='/opt/perl' \
    && make libperl.so \
    && make -j$(nproc) \
    && make install \
    && rm -rf /usr/src/perl

WORKDIR /opt/perl
ENV PATH="/opt/perl/bin:${PATH}"

RUN curl -o /tmp/cpm -sL --compressed https://raw.githubusercontent.com/skaji/cpm/main/cpm \
    && chmod 755 /tmp/cpm \
    && /tmp/cpm install --show-build-log-on-failure -g App::cpm App::cpanminus IO::Socket::SSL \
    && rm -rf /root/.perl-cpm /tmp/cpm


FROM alpine:latest AS RUNTIME-IMAGE

# Copy the base Perl installation from the build-image
COPY --from=build-image /opt/perl /opt/perl

ENV PATH="/opt/perl/bin:${PATH}"

