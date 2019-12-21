# building a cross compiler
# Documentation followed by https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
# 
FROM ubuntu:18.04

WORKDIR /tmp

RUN apt-get update && \
apt-get upgrade -y && \
apt-get install -y wget && \
apt-get clean && \
wget http://ftpmirror.gnu.org/binutils/binutils-2.24.tar.gz && \
wget http://ftpmirror.gnu.org/gcc/gcc-4.9.2/gcc-4.9.2.tar.gz && \
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.17.2.tar.xz && \
wget http://ftpmirror.gnu.org/glibc/glibc-2.20.tar.xz && \
wget http://ftpmirror.gnu.org/mpfr/mpfr-3.1.2.tar.xz && \
wget http://ftpmirror.gnu.org/gmp/gmp-6.0.0a.tar.xz && \
wget http://ftpmirror.gnu.org/mpc/mpc-1.0.2.tar.gz && \
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.12.2.tar.bz2 && \
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.1.tar.gz && \
echo "source code downloaded successful"

RUN apt-get install \
  xz-utils \
  gcc \
  g++ \
  make \
  gawk \
  vim \
  git \
  -y 

RUN \
for f in *.tar*; do tar xf $f; done && \
cd gcc-4.9.2 && \
ln -s ../mpfr-3.1.2 mpfr && \
ln -s ../gmp-6.0.0 gmp && \
ln -s ../mpc-1.0.2 mpc && \
ln -s ../isl-0.12.2 isl && \
ln -s ../cloog-0.18.1 cloog && \
cd .. && \
mkdir -p /opt/cross 

RUN apt-get install -y texinfo 

ENV \
 TARGET=aarch64-linux \
 ARCH=arm64  \
 MAKE="make -j24" \
 CFLAGS="-Wimplicit-fallthrough=0 -Wno-unused-value -Wno-pointer-compare -Wno-unused-const-variable -Wno-int-in-bool-context -Wno-shift-negative-value "

COPY 001-binutils.patch /tmp/

# binutils
RUN \
patch -p0 < 001-binutils.patch  && \
mkdir build-binutils && \
cd build-binutils && \
env CFLAGS="${CFLAGS}" ../binutils-2.24/configure --prefix=/opt/cross --target=${TARGET} --disable-multilib  && \
${MAKE} && \
make install && \
cd ..

# linux kernel headers
RUN cd linux-3.17.2 && \
make ARCH=${ARCH} INSTALL_HDR_PATH=/opt/cross/${TARGET} headers_install && \
cd ..

ENV CFLAGS="${CFLAGS} -Wno-nonull"
# C/C++ compiler
RUN mkdir -p build-gcc && \
cd build-gcc && \
env CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" ../gcc-4.9.2/configure --prefix=/opt/cross --target=${TARGET} --enable-languages=c,c++ --disable-multilib && \
${MAKE} all-gcc && \
make install-gcc 
