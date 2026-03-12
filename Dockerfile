FROM schnicklbob/ubuntudesk:latest

ENV DEBIAN_FRONTEND=noninteractive

USER root

# Your existing packages + Tesseract OCR
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nano \
        netcat-openbsd \
        wget \
        unzip \
        git \
        curl \
        iproute2 \
        net-tools \
        tesseract-ocr \
        tesseract-ocr-eng \
        libtesseract-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create fritz user (your preference, tested working)
RUN useradd -m -u 1002 -G sudo,dialout,plugdev,video,audio,ubuntu,headless fritz && \
    echo "fritz:qwerty" | chpasswd

# Desktop launcher for Android Studio
RUN echo '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Android Studio\nIcon=/opt/android-studio/bin/studio.png\nExec="/opt/android-studio/bin/studio.sh" %f\nComment=IRS Gambling Compliance Logger\nCategories=Development;IDE;' > \
    /usr/share/applications/android-studio.desktop

# Workspace (safer than 777)
RUN mkdir -p /workspace/android-projects && \
    chown fritz:fritz /workspace/android-projects

# Copy working PATH
RUN cp /home/headless/.bashrc /home/fritz/ && \
    chown fritz:fritz /home/fritz/.bashrc

# Pre-accept SDK licenses
RUN yes | sdkmanager --licenses || true

USER fritz
WORKDIR /home/fritz
