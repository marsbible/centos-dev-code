FROM centos:7.6.1810

RUN  yum -y group install "Development Tools" \
        && localedef -c -f UTF-8 -i en_US en_US.UTF-8 \
        && yum -y install sudo openssl wget file unzip git vim curl \
        && yum -y clean all \
        && useradd --create-home --shell /bin/bash dev -G wheel \
        && echo "dev:dev" | chpasswd

#ENV CFLAGS="-march=sandybridge"
#ENV CXXFLAGS="-march=sandybridge"

ENV LC_ALL en_US.UTF-8

RUN cd /home/dev && curl -fsSL https://github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-x86_64.sh -o cmake_install.sh
RUN cd /home/dev && curl -fsSL https://ftp.gnu.org/gnu/glibc/glibc-2.20.tar.gz  | tar xzf - 
RUN cd /home/dev && curl -fsSL https://github.com/clangd/clangd/releases/download/11.0.0/clangd-linux-11.0.0.zip -o clangd-linux-11.0.0.zip 
RUN cd /home/dev && curl -fsSL https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/patchelf-0.12-1.el7.x86_64.rpm -o patchelf.rpm \
    && rpm -ivh patchelf.rpm


RUN cd /home/dev/glibc-2.20 && mkdir build && cd build && ../configure --prefix=/opt/glibc-2.20 && make && make install \
    && sh /home/dev/cmake_install.sh --skip-license  --prefix=/usr/local \
    && unzip /home/dev/clangd-linux-11.0.0.zip -d /usr/local \
    && ln -s /usr/local/clangd_11.0.0/bin/clangd  /usr/bin/clangd \
    && patchelf --set-interpreter /opt/glibc-2.20/lib/ld-linux-x86-64.so.2 --set-rpath /opt/glibc-2.20/lib:/usr/lib64 /usr/local/clangd_11.0.0/bin/clangd 

USER dev 
WORKDIR /home/dev
