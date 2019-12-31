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
 GLIBC=glibc-2.19 \
 GCCVERSION=gcc-9.2.0 \
 BINUTILS=binutils-2.25.1

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
echo "source code downloaded successful"

RUN \
for f in *.tar*; do tar xf $f; done && \
cd ${GCCVERSION} && \
./contrib/download_prerequisites && \
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
RUN mkdir -p build-gcc && \
  cd build-gcc && \
  env CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" ../${GCCVERSION}/configure --prefix=/opt/cross --target=${TARGET} --enable-languages=c,c++ --disable-multilib --disable-libsanitizer && \
  make -j24 all-gcc && \
  make install-gcc && \
  cd ..

# 4. Standard C Library Headers and Startup Files
RUN  mkdir -p build-glibc && \
  cd build-glibc  && \
  ../${GLIBC}/configure --prefix=/opt/cross/${ARCH}-linux --build=$MACHTYPE --host=${ARCH}-linux --target=${ARCH}-linux --with-headers=/opt/cross/${ARCH}-linux/include --disable-multilib libc_cv_forced_unwind=yes libc_cv_ssp=no  && \
  make install-bootstrap-headers=yes install-headers  && \
  ${MAKE} csu/subdir_lib  && \
  install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross/${ARCH}-linux/lib  && \
  ${ARCH}-linux-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross/${ARCH}-linux/lib/libc.so  && \
  touch /opt/cross/${ARCH}-linux/include/gnu/stubs.h  && \
  cd ..  && \
  echo "standard C library headers and libc.so and stubs.h are successfully built"

# 5. Compiler Support Library

RUN cd build-gcc && \
${MAKE} all-target-libgcc  &&\
make install-target-libgcc  &&\
cd ..

# 6. Standard C Library

RUN cd build-glibc  &&\
${MAKE}  &&\
make install &&\
cd ..

# 7. Standard C++ Library

RUN cd build-gcc && \
  ${MAKE}  && \
  make install && \
  cd ..
