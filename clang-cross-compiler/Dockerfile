FROM debian:jessie

ENV LLVM_VERSION=8.0.0
ENV LLVM_PATH=/opt/llvm

RUN apt-get install subversion swig python2.7-dev libedit-dev libncurses5-dev ccache -y && \
    apt-get clean

RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.5/cmake-3.13.5.tar.gz  && \
    tar xfz cmake-3.13.5.tar.gz && \
    cd cmake-3.13.5 && \
    mkdir bld && cd bld && \
    ../configure && make && make install && \
    echo "cmake installation successful" && \
    cd - && rm -rf cmake* 

WORKDIR ${LLVM_PATH}
ENV LLVM_SRC=${LLVM_PATH}/llvm-${LLVM_VERSION}.src
ENV LLVM_BUILD=${LLVM_PATH}/llvm-${LLVM_VERSION}.bld

RUN mkdir -p ${LLVM_PATH} && \
    wget http://releases.llvm.org/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/cfe-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/compiler-rt-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/libcxx-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/libcxxabi-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/libunwind-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/openmp-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/polly-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/clang-tools-extra-${LLVM_VERSION}.src.tar.xz && \
    for i in *.xz;do tar xf $i;done && \
    rm *.tar.xz && \
    mv -v cfe-${LLVM_VERSION}.src ${LLVM_SRC}/tools/clang && \
    mv -v clang-tools-extra-${LLVM_VERSION}.src ${LLVM_SRC}/tools/clang/tools/extra && \
    mv -v compiler-rt-${LLVM_VERSION}.src ${LLVM_SRC}/projects/compiler-rt && \
    mv -v libcxx-${LLVM_VERSION}.src ${LLVM_SRC}/projects/libcxx && \
    mv -v libcxxabi-${LLVM_VERSION}.src ${LLVM_SRC}/projects/libcxxabi && \
    mv -v openmp-${LLVM_VERSION}.src ${LLVM_SRC}/projects/openmp && \
    mv -v polly-${LLVM_VERSION}.src ${LLVM_SRC}/tools/polly && \
    mv -v libunwind-${LLVM_VERSION}.src ${LLVM_SRC}/projects/libunwind && \
    echo "Download clang ${LLVM_VERSION} successfully"

ENV LLVM_CROSS_BUILD=${LLVM_PATH}/clang-cross-bld
ENV LLVM_CROSS_INSTALL=/opt/powerpc-unknown-linux-gnu-clang 
RUN mkdir ${LLVM_CROSS_BUILD} && \ 
    cd ${LLVM_CROSS_BUILD} && \
    cmake -GNinja \
          -DLLVM_TARGETS_TO_BUILD=PowerPC \
          -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=x86_64-unknown-linux-gnu \
          -DLLVM_TARGET_ARCH=powerpc-linux-gnu \
          -DLLDB_TEST_ARCH=powerpc-linux-gnu \
          -DLLVM_DEFAULT_TARGET_TRIPLE=powerpc-unknown-linux-gnu \
          -DCMAKE_BUILD_TYPE=Release \
          -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=True \
          -DLLVM_ENABLE_THREADS=ON \
          -DCMAKE_INSTALL_PREFIX=${LLVM_CROSS_INSTALL} \
          ${LLVM_SRC} && \
    ninja && \
    echo "clang cross compiler build successfully" && \
    cd bin && \
    ln -s ${LLVM_CROSS_INSTALL}/bin/clang /usr/local/bin/powerpc-linux-gnu-clang && \
    ln -s ${LLVM_CROSS_INSTALL}/bin/clang++ /usr/local/bin/powerpc-linux-gnu-clang++
         
RUN  cd ${LLVM_CROSS_BUILD} && ninja install 

WORKDIR /tmp

RUN rm -rf ${LLVM_CROSS_BUILD} && \
    rm -rf ${LLVM_SRC} && \
    rm -rf ${LLVM_PATH} && \
    rm -rf /tmp/cmake* && \
    rm /tmp/v3.1.0.tar.gz

RUN awk "\
BEGIN { \
  found = 0; \
} \
 \
/^\[binaries\]/ { \
  found = 1; \
} \
 \
/^\[$/ { \
  found = 0; \
} \
 \
/^c\ =\ / { \
  if (found) { \
    print \"c = '/usr/local/bin/powerpc-linux-gnu-clang'\"; \
    skip = 1; \
  } \
} \
/^cpp\ =\ / { \
  if (found) { \
    print \"cpp = '/usr/local/bin/powerpc-linux-gnu-clang++'\"; \
    skip = 1; \
  } \
} \
\
/.*/ { \
  if (skip) \
    skip = 0; \
  else \
    print; \
} \
 \
" /etc/meson/meson-ppc-l06-build.ini > /tmp/out && \
  mv /tmp/out /etc/meson/meson-ppc-l06-build.ini 

ENV LLVM_VERSION=
ENV LLVM_PATH=
ENV LLVM_SRC=
ENV LLVM_BUILD=
ENV LLVM_CROSS_BUILD=
