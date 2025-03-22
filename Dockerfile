FROM ghcr.io/mike1703/esp32-qemu:main AS qemu_builder

FROM espressif/idf-rust:esp32_1.85.0.0
ARG GDB_VERSION=15.2_20241112
USER root
# this is for qemu (+slirp) support and downloading gdb
RUN \ 
  apt update && \
  apt install -y \
    # downloading gdb
    wget \
    # for running gdb
    libpixman-1-0 \
    libslirp-dev \
    # for use in the container during development
    jq \
    sccache
USER esp
COPY --from=qemu_builder /qemu /home/esp/qemu
# Install gdb as this is not included anymore https://github.com/esp-rs/espup/issues/257
# Update if new release at https://github.com/espressif/binutils-gdb/releases is available
RUN wget https://github.com/espressif/binutils-gdb/releases/download/esp-gdb-v${GDB_VERSION}/xtensa-esp-elf-gdb-${GDB_VERSION}-x86_64-linux-gnu.tar.gz && \
    tar --strip-components=1 \
        -C /home/esp/.rustup/toolchains/esp/xtensa-esp-elf/esp-*/xtensa-esp-elf/ \
        -xzpf \
        /home/esp/xtensa-esp-elf-gdb-${GDB_VERSION}-x86_64-linux-gnu.tar.gz xtensa-esp-elf-gdb && \
    rm xtensa-esp-elf-gdb-${GDB_VERSION}-x86_64-linux-gnu.tar.gz
# Install some additional tools that need some time to compile
RUN cargo install --force --locked \
    cargo-edit \
    espflash \
    espmonitor
USER esp
