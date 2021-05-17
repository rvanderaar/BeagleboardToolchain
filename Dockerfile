
# Ubuntu 18.04 preferred by TI 
# https://software-dl.ti.com/processor-sdk-linux/esd/docs/06_03_00_106/linux/Overview_Getting_Started_Guide.html
FROM ubuntu:18.04

# Install some tools + clean up
RUN apt-get update && \
    apt-get install -y rsync git wget cmake bzip2 sudo gdb-multiarch && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Need i386 libraries for installing the TI PRU (the installer is 32bit and installs 
# 64bit compilers)
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Add a user called `develop`
RUN useradd -ms /bin/bash develop
RUN echo 'develop:develop' | chpasswd
RUN echo "develop   ALL=(ALL:ALL) ALL" >> /etc/sudoers

RUN cd /tmp && \
    wget https://software-dl.ti.com/codegen/esd/cgt_public_sw/PRU/2.3.3/ti_cgt_pru_2.3.3_linux_installer_x86.bin && \
    chmod +x ti_cgt_pru_2.3.3_linux_installer_x86.bin && \
    ./ti_cgt_pru_2.3.3_linux_installer_x86.bin --mode unattended --prefix /opt && \
    rm ti_cgt_pru_2.3.3_linux_installer_x86.bin

# Need xz utils for unpacking the SDK
RUN apt-get update && \
    apt-get install -y xz-utils && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Installing the toolchain
RUN cd /tmp && \
    wget https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz && \
    tar xf gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz -C /opt && \
    rm gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz

# Installing the processor SDK
# RUN cd /tmp && \
#     wget https://software-dl.ti.com/processor-sdk-linux/esd/AM57X/latest/exports/am57xx-evm-linux-sdk-bin-06.03.00.106.tar.xz && \
#     tar xf am57xx-evm-linux-sdk-bin-06.03.00.106.tar.xz -C /opt && \
#     rm am57xx-evm-linux-sdk-bin-06.03.00.106.tar.xz


WORKDIR /home/develop

ENV PRU_CGT="/opt/ti-cgt-pru_2.3.3"
ENV PATH="/opt/ti-cgt-pru_2.3.3/bin:/opt/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf/bin:${PATH}"

USER develop
