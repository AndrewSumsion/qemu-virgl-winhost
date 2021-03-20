FROM fedora:latest

RUN dnf update -y && \
    dnf install -y mingw64-gcc \
                mingw64-glib2 \
                mingw64-pixman \
                git \
                make \
                flex \
                bison \
                python \
                autoconf \
                xorg-x11-util-macros \
                python3 \
                python3-pip \
                python3-setuptools \
                python3-wheel \
                ninja-build

RUN pip3 install meson && \
    ln -s /usr/local/bin/meson /usr/bin/meson

COPY angle/include/ /usr/x86_64-w64-mingw32/sys-root/mingw/include/
COPY angle/egl.pc /usr/x86_64-w64-mingw32/sys-root/mingw/lib/pkgconfig/
COPY angle/glesv2.pc /usr/x86_64-w64-mingw32/sys-root/mingw/lib/pkgconfig/
COPY WinHv*.h /usr/x86_64-w64-mingw32/sys-root/mingw/include/

RUN git clone https://github.com/anholt/libepoxy && \
    cd libepoxy && \
    mkdir _build && cd _build && \
    meson .. . --cross-file=../cross/fedora-mingw64.txt --prefix=/usr/x86_64-w64-mingw32/sys-root/mingw && \
    meson configure -Degl=yes && \
    ninja && \
    ninja install

RUN git clone https://github.com/AndrewSumsion/SDL-mirror/ && \
    cd SDL-mirror && \ 
    mingw64-configure && \
    make -j8 && \
    make install

RUN git clone https://github.com/AndrewSumsion/virglrenderer.git && \
    cd virglrenderer && \
    export NOCONFIGURE=1 && \
    ./autogen.sh && \
    mingw64-configure --disable-egl && \
    make -j8 && \
    make install

RUN git clone https://github.com/AndrewSumsion/qemu.git && \
    cd qemu && \
    export NOCONFIGURE=1 && \
    ./configure --target-list=x86_64-softmmu \
    --prefix=/qemu_win \
    --cross-prefix=x86_64-w64-mingw32- \
    --enable-hax \
    --enable-whpx \
    --enable-virglrenderer \
    --enable-opengl \
    --enable-debug \
    --enable-sdl \
    --disable-werror && \
    make -j8 && make install

RUN cd /usr/x86_64-w64-mingw32/sys-root/mingw/bin/ && \
    cp libgcc_s_seh-1.dll /qemu_win && \
    cp SDL2.dll /qemu_win && \
    cp libpixman-1-0.dll /qemu_win && \
    cp zlib1.dll /qemu_win && \
    cp libepoxy-0.dll /qemu_win && \
    cp libglib-2.0-0.dll /qemu_win && \
    cp libvirglrenderer-0.dll /qemu_win && \
    cp libssp-0.dll /qemu_win && \
    cp libwinpthread-1.dll /qemu_win && \
    cp iconv.dll /qemu_win && \
    cp libintl-8.dll /qemu_win && \
    cp libpcre-1.dll /qemu_win


COPY d3dcompiler_47.dll /qemu_win
COPY libEGL.dll /qemu_win
COPY libGLESv2.dll /qemu_win