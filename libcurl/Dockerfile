From debian:jessie

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install perl vim wget gcc cmake python3 openssh-client -y && \
    apt-get clean

WORKDIR /tmp

RUN OPENSSL_VERSION=openssl-1.0.2q && \
    wget https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz && \
    tar xfz ${OPENSSL_VERSION}.tar.gz  && \
    cd ${OPENSSL_VERSION} && \
    ./config shared && \
    make -j 8 && \
    make install


RUN wget https://tls.mbed.org/download/mbedtls-2.16.0-apache.tgz && \
    tar xfz mbedtls-2.16.0-apache.tgz  && \
    cd mbedtls-2.16.0 && \
    mkdir bld && cd bld && \
    cmake -DUSE_SHARED_MBEDTLS_LIBRARY=ON .. && \
    make -j 8 && \ 
    make install 

# Edit FindmbedTLS.cmake
#SET(MBEDTLS_INCLUDE_DIR "/tmp/mbedtls-2.16.0/bld/include")
#SET(MBEDTLS_LIBRARY "/tmp/mbedtls-2.16.0/bld/library/libmbedtls.a")
#SET(MBEDX509_LIBRARY "/tmp/mbedtls-2.16.0/bld/library/libmbedx509.a")
#SET(MBEDCRYPTO_LIBRARY "/tmp/mbedtls-2.16.0/bld/library/libmbedcrypto.a")
#IF(MBEDTLS_INCLUDE_DIR AND MBEDTLS_LIBRARY AND MBEDX509_LIBRARY AND MBEDCRYPTO_LIBRARY)
#     SET(MBEDTLS_FOUND TRUE)
#ENDIF()
RUN wget https://www.libssh2.org/download/libssh2-1.8.0.tar.gz && \
    tar xfz libssh2-1.8.0.tar.gz &&\
    cd libssh2-1.8.0 && \
    mkdir bld && cd bld && \
    cmake -DBUILD_SHARED_LIBS=ON \
          -DCRYPTO_BACKEND=mbedTLS  \
          -DENABLE_ZLIB_COMPRESSION=OFF \
          -DENABLE_CRYPT_NONE=OFF \
          -DENABLE_MAC_NONE=OFF \
          -DENABLE_GEX_NEW=ON \
          -DCLEAR_MEMORY=ON  \
          .. && \
    make -j 8 && \
    make install 

RUN wget https://curl.haxx.se/download/curl-7.63.0.tar.gz && \
    tar xfz curl-7.63.0.tar.gz && \
    cd curl-7.63.0 && \
    mkdir bld && cd bld && \
    ../configure --with-default-ssl-backend=mbedtls \
                 --disable-openssl-auto-load-config \
                 --enable-pthreads \
                 --without-zlib \
                 --without-ssl \
                 --with-mbedtls=/usr/local  \
                 --with-libssh2=/usr/local &&\
    make -j 8 &&\
    make install 

RUN dd if=/dev/urandom of=/tmp/data.bin bs=4096 count=1

RUN printf "\nmysecret\nmysecret\n" | ssh-keygen -t rsa 

RUN echo "curl -v --pass mysecret --pubkey /root/.ssh/id_rsa.pub --key /root/.ssh/id_rsa --insecure -u micki: --upload-file data.bin sftp://192.168.0.15:2222/home/micki/ablage/data.bin" > todo.sh && chmod 700 /tmp/todo.sh

