# building a cross compiler
# Documentation followed by https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
# 
FROM ubuntu:20.04

WORKDIR /tmp

ENV \
 ARCH=powerpc  \
 TARGET=powerpc-linux-gnu \
 KERNEL=3.18.55 \
 PATH=/opt/cross/bin:$PATH \
 MAKE="make -j1"  \
 GLIBC=glibc-2.19 \
 GCCVERSION=gcc-10.1.0 \
 BINUTILS=binutils-2.25.1

RUN \
	wget -N ftp://ftp.gwdg.de/pub/misc/gcc/releases/gcc-10.1.0/gcc-10.1.0.tar.xz && \
	&& if [ ! -d gcc-10.1.0 ];then tar xfJ gcc-10.1.0.tar.xz ;fi \
	&& cd gcc-10.1.0 \
	&& ./contrib/download_prerequisites \
	&& rm -rf bld && mkdir bld \
&& cd bld \
  && ../configure $(ENABLE_LANGS) --prefix=`pwd` --program-suffix=-10.1.0 --disable-multilib --disable-libgcj \
	&& nice -n 19 env CC=gcc CXX=g++ make -j $(NPROC) all install \
&& echo gcc build ready inside `pwd`



RUN apt-get install -y wget && \
    wget http://ftpmirror.gnu.org/binutils/${BINUTILS}.tar.gz && \
    wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-${KERNEL}.tar.gz && \
    wget http://ftpmirror.gnu.org/glibc/${GLIBC}.tar.gz && \
    wget http://ftpmirror.gnu.org/gcc/${GCCVERSION}/${GCCVERSION}.tar.gz  
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      gcc \
      g++ \
      wget \
      make \
    && \
    apt-get clean -y 
RUN \
    for f in *.tar*; do tar xf $f; done && \
    cd ${GCCVERSION} && \
    ./contrib/download_prerequisites && \
    cd .. && \
    mkdir -p /opt/cross  && \
    cd /tmp && \
    mkdir build-native-gcc && \
    cd  build-native-gcc && \
    ../${GCCVERSION}/configure --disable-multilib --disable-libgcj && \
    ${MAKE} all install && \
    cd /tmp && \
    mkdir build-binutils && \
    cd build-binutils && \
    env CFLAGS="${CFLAGS}" ../${BINUTILS}/configure --prefix=/opt/cross --target=${TARGET} --disable-multilib  && \
    ${MAKE} && \
    make install && \
    cd /tmp && \
    cd linux-${KERNEL} && \
    ${MAKE} ARCH=${ARCH} INSTALL_HDR_PATH=/opt/cross/${TARGET} headers_install && \
    cd /tmp  && \
    mkdir -p build-gcc && \
    cd build-gcc && \
    env CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" ../${GCCVERSION}/configure --prefix=/opt/cross --target=${TARGET} --enable-languages=c,c++ --disable-multilib --disable-libsanitizer && \
    ${MAKE} all-gcc && \
    make install-gcc && \
    cd /tmp  && \
    CC=powerpc-linux-gnu-${GCCVERSION} CXX=powerpc-linux-gnu-$(echo ${GCCVERSION} | sed "s/gcc/g++/") && \
    mkdir -p build-glibc && \
    cd build-glibc  && \
    ../${GLIBC}/configure --prefix=/opt/cross/${ARCH}-linux-gnu --build=$MACHTYPE --host=${ARCH}-linux-gnu --target=${ARCH}-linux-gnu --with-headers=/opt/cross/${ARCH}-linux-gnu/include --disable-multilib libc_cv_forced_unwind=yes libc_cv_ssp=no  && \
    make install-bootstrap-headers=yes install-headers  && \
    ${MAKE} csu/subdir_lib  && \
    install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross/${ARCH}-linux-gnu/lib  && \
    ${ARCH}-linux-gnu-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross/${ARCH}-linux-gnu/lib/libc.so  && \
    touch /opt/cross/${ARCH}-linux-gnu/include/gnu/stubs.h  && \
    cd /tmp  && \
    cd build-gcc && \
    ${MAKE} all-target-libgcc  &&\
    make install-target-libgcc  &&\
    cd /tmp  && \
    cd build-glibc  &&\
    ${MAKE}  &&\
    make install &&\
    cd /tmp  && \
    cd build-gcc && \
    ${MAKE}  && \
    make install && \
    rm -rf /tmp/*
