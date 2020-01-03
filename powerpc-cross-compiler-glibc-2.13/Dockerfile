# building a cross compiler
# Documentation followed by https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
# 
FROM ubuntu:14.04

WORKDIR /tmp

ENV \
 ARCH=powerpc  \
 TARGET=powerpc-linux \
 PATH=/opt/cross/bin:$PATH \
 MAKE="make -j1"  \
 GLIBC=glibc-2.13 \
 GCCVERSION=gcc-4.5.4 \
 BINUTILS=binutils-2.22

RUN cd /bin && ln -sf bash sh && echo "redirect sh to bash"  && cd - && \
apt-get update && \
apt-get upgrade -y && \
apt-get install \
  wget \
  xz-utils \
  gcc \
  g++ \
  make \
  gawk \
  vim \
  gettext \
  git \
  texinfo \
  -y && \
  apt-get clean && \
wget http://ftpmirror.gnu.org/binutils/${BINUTILS}.tar.gz && \
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.17.2.tar.xz && \
wget http://ftpmirror.gnu.org/glibc/${GLIBC}.tar.xz && \
wget http://ftpmirror.gnu.org/gcc/${GCCVERSION}/${GCCVERSION}.tar.gz  && \
wget http://ftpmirror.gnu.org/mpfr/mpfr-3.1.2.tar.xz && \
wget http://ftpmirror.gnu.org/gmp/gmp-6.0.0a.tar.xz && \
wget http://ftpmirror.gnu.org/mpc/mpc-1.0.2.tar.gz && \
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.12.2.tar.bz2 && \
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.1.tar.gz && \
echo "source code downloaded successful"

RUN \
for f in *.tar*; do tar xf $f; done && \
cd ${GCCVERSION} && \
ln -s ../mpfr-3.1.2 mpfr && \
ln -s ../gmp-6.0.0 gmp && \
ln -s ../mpc-1.0.2 mpc && \
ln -s ../isl-0.12.2 isl && \
ln -s ../cloog-0.18.1 cloog && \
cd .. && \
mkdir -p /opt/cross 

# 1. binutils
RUN \
mkdir build-binutils && \
cd build-binutils && \
env CFLAGS="${CFLAGS}" ../${BINUTILS}/configure --prefix=/opt/cross --target=${TARGET} --disable-multilib  && \
${MAKE} && \
make install && \
cd ..

# 2. linux kernel headers
RUN cd linux-3.17.2 && \
${MAKE} ARCH=${ARCH} INSTALL_HDR_PATH=/opt/cross/${TARGET} headers_install && \
cd ..

# 3. C/C++ compiler
#RUN mkdir -p build-gcc && \
#  cd build-gcc && \
#  env CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" ../${GCCVERSION}/configure --prefix=/opt/cross --target=${TARGET} --enable-languages=c,c++ --disable-multilib --disable-libsanitizer && \
#  ${MAKE} all-gcc && \
#  make install-gcc && \
#  cd ..
#
## 4. Standard C Library Headers and Startup Files
#RUN  mkdir -p build-glibc && \
#  cd build-glibc  && \
#  ../${GLIBC}/configure --prefix=/opt/cross/${ARCH}-linux --build=$MACHTYPE --host=${ARCH}-linux --target=${ARCH}-linux --with-headers=/opt/cross/${ARCH}-linux/include --disable-multilib libc_cv_forced_unwind=yes libc_cv_ssp=no  && \
#  make install-bootstrap-headers=yes install-headers  && \
#  ${MAKE} csu/subdir_lib  && \
#  install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross/${ARCH}-linux/lib  && \
#  ${ARCH}-linux-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross/${ARCH}-linux/lib/libc.so  && \
#  touch /opt/cross/${ARCH}-linux/include/gnu/stubs.h  && \
#  cd ..  && \
#  echo "standard C library headers and libc.so and stubs.h are successfully built"
#
## 5. Compiler Support Library
#
#RUN cd build-gcc && \
#${MAKE} all-target-libgcc  &&\
#make install-target-libgcc  &&\
#cd ..
#
## 6. Standard C Library
#
#RUN cd build-glibc  &&\
#${MAKE}  &&\
#make install &&\
#cd ..
#
## 7. Standard C++ Library
#
#RUN cd build-gcc && \
#  ${MAKE}  && \
#  make install && \
#  cd ..
