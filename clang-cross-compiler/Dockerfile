FROM mickifoerster/powerpc-linux-gcc

ENV LLVM_VERSION=9.0.0
ENV LLVM_PATH=/opt/cross/llvm
ENV OPENSSL_ROOT_DIR=/tmp/openssl-1.1.1d/bld
ENV LLVM_SRC=${LLVM_PATH}/llvm-${LLVM_VERSION}.src
ENV LLVM_BUILD=${LLVM_PATH}/llvm-${LLVM_VERSION}.bld

RUN apt-get install -y ninja-build zlib1g-dev subversion swig python2.7-dev libedit-dev libncurses5-dev ccache && \
    ln -sf /usr/local/lib64/libstdc++.so.6.0.27 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 && \
    apt-get autoremove -y && \
    apt-get clean

WORKDIR /tmp

RUN wget https://www.openssl.org/source/openssl-1.1.1d.tar.gz
RUN  tar xfz openssl-1.1.1d.tar.gz && \
     cd openssl-1.1.1d && \
    ./config shared --prefix=`pwd`/bld --openssldir=`pwd`/bld no-ssl2 no-ssl3 no-comp no-idea && \
    make depend && \
    make && \
    make test && \
    make install && \
    echo OK;

RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.2/cmake-3.16.2.tar.gz 
RUN tar xfz cmake-3.16.2.tar.gz  && \
    cd cmake-3.16.2 && \
    mkdir bld && cd bld && \
    ../configure && make && make install && \
    echo "cmake installation successful" && \
    cd - && rm -rf cmake* 

WORKDIR ${LLVM_PATH}

RUN mkdir -p ${LLVM_PATH} && \
    wget http://releases.llvm.org/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/cfe-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/compiler-rt-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/libcxx-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/libcxxabi-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/libunwind-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/openmp-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/polly-${LLVM_VERSION}.src.tar.xz && \
    wget http://releases.llvm.org/${LLVM_VERSION}/clang-tools-extra-${LLVM_VERSION}.src.tar.xz 
RUN for i in *.xz;do tar xf $i;done && \
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

RUN wget https://github.com/Z3Prover/z3/archive/z3-4.8.7.tar.gz && \
    tar xfz z3-4.8.7.tar.gz && \
    cd z3-z3-4.8.7/ && \
    ./configure && \
    cd build/ && \
    ${MAKE} && \
    ${MAKE} install && \
    echo "Z3 solver installed"

ENV LLVM_CROSS_BUILD=${LLVM_PATH}/clang-cross-bld
ENV LLVM_CROSS_INSTALL=/opt/powerpc-linux-gnu-clang 
RUN mkdir ${LLVM_CROSS_BUILD} && \ 
    cd ${LLVM_CROSS_BUILD} && \
    cmake -GNinja \
          -DLLVM_TARGETS_TO_BUILD=PowerPC \
          -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=x86_64-linux-gnu \
          -DLLVM_TARGET_ARCH=powerpc-linux-gnu \
          -DLLDB_TEST_ARCH=powerpc-linux-gnu \
          -DLLVM_DEFAULT_TARGET_TRIPLE=powerpc-linux-gnu \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${LLVM_CROSS_INSTALL} \
          -DCMAKE_EXE_LINKER_FLAGS="-Xlinker -R/usr/local/lib64 -L/usr/local/lib64" \
          ${LLVM_SRC} && \
    ninja && \
    echo "clang cross compiler build successfully" && \
    cd bin && \
    ln -s ${LLVM_CROSS_INSTALL}/bin/clang /usr/local/bin/powerpc-linux-gnu-clang && \
    ln -s ${LLVM_CROSS_INSTALL}/bin/clang++ /usr/local/bin/powerpc-linux-gnu-clang++ && \
    cd ${LLVM_CROSS_BUILD} && ninja install  && \
    rm -rf /tmp/*
