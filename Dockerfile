FROM schnicklbob/ubuntudesk:latest

ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nano \
        netcat-openbsd \
        wget \
        unzip \
        git \
        openjdk-17-jdk \
        android-tools-adb \
        curl \
        iproute2 \
        net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Let base entrypoint handle VNC user creation and startup
RUN mkdir -p /workspace/android-projects && chmod 777 /workspace/android-projects

WORKDIR /home/abc
