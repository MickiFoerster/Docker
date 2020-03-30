FROM ubuntu:latest

ENV \
LINUX_KERNEL_VERSION=5.4.15 \
LINUX_KERNEL_FOLDER=v5.x

WORKDIR /tmp

RUN \
apt-get update && apt-get upgrade -y && apt-get clean -y && \
apt-get install -y \
    apt-utils \
    bc \
    bison \
    build-essential \
    cpio  \
    curl \
    flex \
    git \
    vim \
    qemu \
    xz-utils

RUN \
curl -O https://cdn.kernel.org/pub/linux/kernel/${LINUX_KERNEL_FOLDER}/linux-${LINUX_KERNEL_VERSION}.tar.xz && \
tar xf linux-* && \
ls -l

RUN \
mkdir linux-bld && \
LINUX_BUILD=$PWD/linux-bld && \
cd linux-${LINUX_KERNEL_VERSION} && \
make O=${LINUX_BUILD} allnoconfig

COPY kernel.cfg /tmp/linux-bld/.config
RUN \
cd /tmp/linux-bld && \
make -j 12

ENV BUSYBOX_VERSION=1.31.1
RUN \
curl -O https://www.busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2 && \
tar xf busybox-${BUSYBOX_VERSION}.tar* 

ENV \
BUSYBOX_SRC=/tmp/busybox-${BUSYBOX_VERSION} \
BUSYBOX_BUILD=/tmp/busybox_build 

RUN \
mkdir -p ${BUSYBOX_BUILD} && \
cd ${BUSYBOX_SRC} && \
make O=${BUSYBOX_BUILD} defconfig && \
cd ${BUSYBOX_BUILD}  && \
sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" .config && \
make -j 12 && \
make install

ENV \
INITRAMFS_BUILD=/tmp/initramfs 

# Create an initramfs
RUN \
mkdir -p ${INITRAMFS_BUILD} && \
cd ${INITRAMFS_BUILD} && \
mkdir -p bin sbin etc proc sys usr/bin usr/sbin && \
cp -av ${BUSYBOX_BUILD}/_install/* .

# Create init script
RUN \
echo "#!/bin/sh" >> ${INITRAMFS_BUILD}/init && \
echo  >> ${INITRAMFS_BUILD}/init && \
echo "mount -t proc none /proc" >> ${INITRAMFS_BUILD}/init && \
echo "mount -t sysfs none /sys" >> ${INITRAMFS_BUILD}/init && \
echo  >> ${INITRAMFS_BUILD}/init && \
echo "cat<<EOM" >> ${INITRAMFS_BUILD}/init && \
echo "Hello from Linux" >> ${INITRAMFS_BUILD}/init && \
echo "EOM" >> ${INITRAMFS_BUILD}/init && \
echo "exec /bin/sh" >> ${INITRAMFS_BUILD}/init && \
chmod +x ${INITRAMFS_BUILD}/init

# Create initramfs archive
RUN cd ${INITRAMFS_BUILD} && \
find . -print0 | cpio --null -ov --format=newc | gzip -9 > /tmp/initramfs.cpio.gz

# Start Qemu
ENTRYPOINT ["/usr/bin/qemu-system-x86_64", "-kernel", "/tmp/linux-bld/arch/x86_64/boot/bzImage", "-initrd", "/tmp/initramfs.cpio.gz", "-nographic", "-append", "'console=ttyS0'"]
