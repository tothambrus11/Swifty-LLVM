ARG SWIFT_VERSION=6.1
# Other ARG declarations must follow FROM
FROM swift:${SWIFT_VERSION}

ARG HYLO_LLVM_BUILD_TYPE=MinSizeRel
ARG HYLO_LLVM_BUILD_RELEASE=20240303-215025
ARG HYLO_LLVM_VERSION=17.0.6
ARG CMAKE_VERSION=3.29.1

ENV HYLO_LLVM_DOWNLOAD_URL="https://github.com/hylo-lang/llvm-build/releases/download"

RUN apt install -y gnupg
RUN apt update
RUN apt install -y curl libzstd-dev libzstd1 lsb-release make ninja-build tar wget zstd software-properties-common python3-pip

# Remove system cmake if installed
RUN apt purge --auto-remove -y cmake || true

# Install a recent version of CMake from official binaries
RUN mkdir -p /opt/cmake && \
    wget -q -O /tmp/cmake.sh https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh && \
    sh /tmp/cmake.sh --skip-license --prefix=/opt/cmake && \
    ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake && \
    ln -s /opt/cmake/bin/ctest /usr/local/bin/ctest && \
    ln -s /opt/cmake/bin/cpack /usr/local/bin/cpack && \
    ln -s /opt/cmake/bin/cmake-gui /usr/local/bin/cmake-gui || true && \
    rm /tmp/cmake.sh && \
    cmake --version

# Get the LLVM builds for the host architecture
RUN <<EOT bash -ex -o pipefail

    file_prefix="llvm-\${HYLO_LLVM_VERSION}-\$(uname -m)-unknown-linux-gnu"
    url_prefix="\${HYLO_LLVM_DOWNLOAD_URL}/\${HYLO_LLVM_BUILD_RELEASE}/\$file_prefix"

    for build_type in Debug MinSizeRel; do
        curl --no-progress-meter -L "\${url_prefix}-\${build_type}.tar.zst" | tar -x --zstd -C /opt
        ln -s /opt/\${file_prefix}-\${build_type} /opt/llvm-\${build_type}
    done

EOT

# Make and install the llvm.pc file.
ADD make-pkgconfig.sh /tmp
RUN <<EOT bash -ex -o pipefail

    export PATH="/opt/llvm-${HYLO_LLVM_BUILD_TYPE}/bin:\$PATH"
    /tmp/make-pkgconfig.sh /usr/local/lib/pkgconfig/llvm.pc > /dev/null
    rm /tmp/make-pkgconfig.sh

EOT
