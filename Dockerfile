FROM amigadev/docker-base:latest

ENV CROSS_PFX=x86_64-w64-mingw32ucrt
ENV OS_NAME=Linux

# START COMMON
MAINTAINER Marlon Beijer "marlon@amigadev.com"

RUN apt update \
    && apt install -y \
        libtool \
        automake \
        autoconf \
        build-essential \
        ninja-build \
        libssl-dev \
        libzstd-dev \
        cmake \
        git \
        openjdk-21-jre \
        zstd \
        dos2unix \
        binutils-mingw-w64-ucrt64 \
        gcc-mingw-w64-ucrt64 \
        g++-mingw-w64-ucrt64 \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN echo "root:root" | chpasswd

RUN chmod 777 -R /usr/${CROSS_PFX}
RUN ln -s /usr/${CROSS_PFX} /tools

ENV CROSS_ROOT=/usr/${CROSS_PFX}
ENV CROSS_BIN_PATH=/usr

WORKDIR /work
ENTRYPOINT ["/entry/entrypoint.sh"]

ARG CACHE_DATE=2025-07-11

COPY imagefiles/cmake.sh /usr/local/bin/cmake
COPY imagefiles/ccmake.sh /usr/local/bin/ccmake
COPY imagefiles/entrypoint.sh /entry/

ENV AS=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-as
ENV LD=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ld
ENV AR=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ar
ENV CC=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-gcc
ENV CXX=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-g++
ENV RANLIB=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ranlib

RUN ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-as /usr/bin/as && \
    ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ar /usr/bin/ar && \
    ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ld /usr/bin/ld && \
    ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-gcc /usr/bin/gcc && \
    ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-g++ /usr/bin/g++ && \
    ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-gcc /usr/bin/${CROSS_PFX}-gcc && \
    ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-g++ /usr/bin/${CROSS_PFX}-g++ && \
    ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ranlib /usr/bin/ranlib

COPY imagefiles/${CROSS_PFX}.cmake ${CROSS_ROOT}/lib/

ENV CMAKE_TOOLCHAIN_FILE=${CROSS_ROOT}/lib/${CROSS_PFX}.cmake
ENV CMAKE_PREFIX_PATH=/usr/${CROSS_PFX}:/usr/${CROSS_PFX}/usr
ENV PATH=${PATH}:${CROSS_ROOT}/bin:${CROSS_BIN_PATH}/bin
# END COMMON
