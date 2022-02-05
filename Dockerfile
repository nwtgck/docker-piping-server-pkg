FROM --platform=linux/amd64 alpine:3.15.0 as download

ARG TARGETPLATFORM

ENV TINI_STATIC_VERSION=0.19.0
ENV PIPING_SERVER_PKG_VERSION=1.11.1

RUN apk add --no-cache curl

RUN case $TARGETPLATFORM in\
      linux/amd64)  pkg_target="linuxstatic-x64";\
                    tini_static_arch="amd64";;\
      linux/arm/v7) pkg_target="linuxstatic-armv7";\
                    tini_static_arch="armel";;\
      linux/arm64)  pkg_target="linuxstatic-arm64";\
                    tini_static_arch="arm64";;\
      *)            exit 1;;\
    esac &&\
    curl -L https://github.com/krallin/tini/releases/download/v${TINI_STATIC_VERSION}/tini-static-${tini_static_arch} > /tini-static &&\
    chmod +x /tini-static &&\
    curl -L https://github.com/nwtgck/piping-server-pkg/releases/download/v${PIPING_SERVER_PKG_VERSION}/piping-server-pkg-${pkg_target}.tar.gz | tar xzf - &&\
    cp ./piping-server-pkg-${pkg_target}/piping-server /piping-server

FROM scratch

COPY --from=download /tini-static /tini-static
COPY --from=download /piping-server /piping-server

ENTRYPOINT [ "/tini-static", "--", "/piping-server" ]
