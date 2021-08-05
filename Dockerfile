FROM amigadev/docker-base:latest

ENV CROSS_PFX aarch64-linux-gnu
ENV OS_NAME Linux

# Temporary fix
#COPY --from=build-env /opt/amiga /opt/${CROSS_PFX}
#RUN ln -s /opt/${CROSS_PFX} /opt/amiga 

# START COMMON
MAINTAINER Marlon Beijer "marlon@amigadev.com"
RUN apt update \
	&& apt install -y libtool automake autoconf build-essential ninja-build \
        && apt install -y gcc-10-aarch64-linux-gnu g++-10-aarch64-linux-gnu \
        && cp /usr/aarch64-linux-gnu/include/gnu/stubs-lp64.h /usr/aarch64-linux-gnu/include/gnu/stubs-lp64_be.h \
	&& apt autoremove -y

RUN echo "root:root" | chpasswd
RUN chmod 777 -R /usr/${CROSS_PFX}
RUN ln -s /usr/${CROSS_PFX} /tools
ENV CROSS_ROOT /usr/${CROSS_PFX}
ENV CROSS_BIN_PATH /usr

WORKDIR /work
ENTRYPOINT ["/entry/entrypoint.sh"]

#COPY imagefiles/cmake.sh /usr/local/bin/cmake
#COPY imagefiles/ccmake.sh /usr/local/bin/ccmake
COPY imagefiles/entrypoint.sh /entry/

ENV AS=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-as \
	LD=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ld \
	AR=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ar \
	CC=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-gcc-10 \
	CXX=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-g++-10 \
	RANLIB=${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ranlib

RUN ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-as /usr/bin/as && \
	ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ar /usr/bin/ar && \
	ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ld /usr/bin/ld && \
	ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-gcc-10 /usr/bin/gcc && \
	ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-g++-10 /usr/bin/g++ && \
	ln -sf ${CROSS_BIN_PATH}/bin/${CROSS_PFX}-ranlib /usr/bin/ranlib

#COPY dependencies/toolchains/${CROSS_PFX}.cmake ${CROSS_ROOT}/lib/
#COPY dependencies/toolchains/Modules/${CROSS_PFX} /CMakeModules
#RUN mv -fv /CMakeModules/* /usr/share/cmake-`cmake --version|awk '{ print $3;exit }'|awk -F. '{print $1"."$2}'`/Modules/
#RUN ln -s /usr/share/cmake-`cmake --version|awk '{ print $3;exit }'|awk -F. '{print $1"."$2}'`/Modules/Platform/Generic.cmake /usr/share/cmake-`cmake --version|awk '{ print $3;exit }'|awk -F. '{print $1"."$2}'`/Modules/Platform/${OS_NAME}.cmake
ENV CMAKE_TOOLCHAIN_FILE ${CROSS_ROOT}/lib/${CROSS_PFX}.cmake
ENV CMAKE_PREFIX_PATH /usr/${CROSS_PFX}:/usr/${CROSS_PFX}/usr
ENV PATH ${PATH}:${CROSS_ROOT}/bin:${CROSS_BIN_PATH}/bin
# END COMMON
