FROM alpine:latest
ARG VERSION

RUN apk add --update --no-cache ca-certificates g++ tar xz jq
RUN set -ex; \ 
    VERSION=${VERSION:=$(wget -q -O - "https://api.github.com/repos/nim-lang/Nim/tags" | jq -r '.[0].name' | cut -c 2-)}; \
    NIM_SRC="nim-${VERSION}.tar.xz"; \
    cd /tmp; \
    wget "https://nim-lang.org/download/${NIM_SRC}.sha256" "https://nim-lang.org/download/${NIM_SRC}"; \
    cat ${NIM_SRC}.sha256 | sha256sum -c; \
    mkdir /nim; \
    tar --strip-components=1 -xJf $NIM_SRC -C /nim; \
    cd /nim; \
    sh build.sh; \
    bin/nim c -d:release koch; \
    ./koch nimble; \
    rm -r c_code tests doc

ENTRYPOINT [ "/bin/sh" ]
