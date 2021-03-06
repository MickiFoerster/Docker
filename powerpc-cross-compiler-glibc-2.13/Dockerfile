# building a cross compiler
# Documentation followed by https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
# 
FROM ubuntu:14.04

WORKDIR /tmp

ENV \
 ARCH=powerpc  \
 KERNEL=3.18.55 \
 TARGET=powerpc-linux-gnu \
 PATH=/opt/cross/bin:$PATH \
 MAKE="make -j1"  \
 GLIBC=glibc-2.13 \
 GCCVERSION=gcc-9.2.0  \
 BINUTILS=binutils-2.22 \
 GMP_VERSION=gmp-5.0.5 \
 MPFR_VERSION=mpfr-3.1.0 \
 MPC_VERSION=mpc-1.0.1

COPY libitm.patch /tmp/
COPY ${GLIBC}.patch /tmp/
RUN \
wget http://ftpmirror.gnu.org/binutils/${BINUTILS}.tar.gz && \
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-${KERNEL}.tar.gz && \
wget http://ftpmirror.gnu.org/glibc/${GLIBC}.tar.xz && \
wget http://ftpmirror.gnu.org/gcc/${GCCVERSION}/${GCCVERSION}.tar.gz  && \
for f in *.tar*; do tar xf $f; done && \
cd ${GCCVERSION} && \
./contrib/download_prerequisites && \
cd .. && \
mkdir -p /opt/cross  && \
mkdir build-binutils && \
cd build-binutils && \
env CFLAGS="${CFLAGS}" ../${BINUTILS}/configure --prefix=/opt/cross --target=${TARGET} --disable-multilib  && \
${MAKE} && \
make install && \
cd .. && \
cd linux-${KERNEL} && \
${MAKE} ARCH=${ARCH} INSTALL_HDR_PATH=/opt/cross/${TARGET} headers_install && \
cd /tmp && \
mkdir -p build-${GCCVERSION} && \
cd ${GCCVERSION}/libitm && \
patch configure.tgt /tmp/libitm.patch && \
cd /tmp/build-${GCCVERSION} && \
env CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" ../${GCCVERSION}/configure --prefix=/opt/cross --target=${TARGET} --enable-languages=c,c++ --disable-multilib --disable-libsanitizer && \
${MAKE} all-gcc && \
make install-gcc && \
cd /tmp/${GLIBC} && \
patch -p1 < /tmp/${GLIBC}.patch  && \
cd /tmp && \
export CC=/opt/cross/bin/powerpc-linux-gnu-gcc-9.2.0 CXX=/opt/cross/bin/powerpc-linux-gnu-g++ && \
mkdir -p /tmp/build-glibc-${GCCVERSION} && \
cd /tmp/build-glibc-${GCCVERSION}  && \
../${GLIBC}/configure --prefix=/opt/cross/${TARGET} --build=$MACHTYPE --host=${TARGET} --target=${TARGET} --with-headers=/opt/cross/${TARGET}/include --disable-multilib libc_cv_forced_unwind=yes libc_cv_ssp=no libc_cv_c_cleanup=yes  && \
make install-bootstrap-headers=yes install-headers && \
cd /tmp/build-glibc-${GCCVERSION}  && \
${MAKE} csu/subdir_lib  && \
install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross/${TARGET}/lib && \
${TARGET}-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross/${TARGET}/lib/libc.so  && \
touch /opt/cross/${TARGET}/include/gnu/stubs.h  && \
cd /tmp  && \
ln -sf /tmp/build-glibc-gcc-9.2.0/bits /tmp/gcc-9.2.0/libgcc/bits && \
cd /tmp/build-${GCCVERSION} && \
${MAKE} all-target-libgcc  &&\
make install-target-libgcc && \
cd /tmp/build-glibc-${GCCVERSION}  && \
${MAKE}  &&\
make install  && \
cd /tmp/build-${GCCVERSION} && \
${MAKE} && \
cd /tmp/build-${GCCVERSION} && \
make install && \
rm -rf /tmp/* && \
echo "cross compiler successfully built"

