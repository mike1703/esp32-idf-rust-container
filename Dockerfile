
FROM espressif/idf-rust:esp32_1.85.0.0
ARG GDB_VERSION=15.2_20241112
ARG QEMU_VERSION=9.2.2
ARG QEMU_DATE=20250228
USER root
# this is for qemu (+slirp) support and downloading gdb
RUN \ 
  apt update && \
  apt install -y \
    # downloading gdb and qemu
    wget \
    # for running gdb
    libpixman-1-0 \
    libslirp-dev \
    # for running qemu
    libsdl2-dev \
    # for use in the container during development
    jq \
    sccache
# Install qemu into /usr/local
ARG QEMU_FILENAME=qemu-xtensa-softmmu-esp_develop_${QEMU_VERSION}_${QEMU_DATE}-x86_64-linux-gnu.tar.xz
RUN wget https://github.com/espressif/qemu/releases/download/esp-develop-${QEMU_VERSION}-${QEMU_DATE}/${QEMU_FILENAME} && \
    tar --strip-components=1 -C /usr/local/ -xJpf ${QEMU_FILENAME} && \
    rm ${QEMU_FILENAME}
USER esp
# Install gdb as this is not included anymore https://github.com/esp-rs/espup/issues/257
# Update if new release at https://github.com/espressif/binutils-gdb/releases is available
ARG GDB_FILENAME=xtensa-esp-elf-gdb-${GDB_VERSION}-x86_64-linux-gnu.tar.gz
RUN wget https://github.com/espressif/binutils-gdb/releases/download/esp-gdb-v${GDB_VERSION}/${GDB_FILENAME} && \
    tar --strip-components=1 -C /home/esp/.rustup/toolchains/esp/xtensa-esp-elf/esp-*/xtensa-esp-elf/ -xzpf ${GDB_FILENAME} && \
    rm ${GDB_FILENAME}
# Install some additional tools that need some time to compile
RUN cargo install --force --locked \
    cargo-edit \
    espflash \
    espmonitor
USER esp
