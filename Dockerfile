FROM schnicklbob/ubuntudesk:latest

USER root

ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV STUDIO_HOME=/opt/android-studio
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/35.0.0

# Create developer user
RUN useradd -m -s /bin/bash developer \
  && mkdir -p ${ANDROID_HOME} \
  && chown -R developer:developer ${ANDROID_HOME}

# Ubuntu 24.04 (Noble): enable i386 multiarch then install deps
# libncurses5:i386 does not exist in Noble — use libncurses6:i386
RUN dpkg --add-architecture i386 \
  && apt-get update && apt-get install -y \
    libc6:i386 \
    libncurses6:i386 \
    libstdc++6:i386 \
    lib32z1 \
    libbz2-1.0:i386 \
    libxtst6 \
    libxi6 \
    libxrender1 \
    fontconfig \
    unzip \
    wget \
    curl \
  && rm -rf /var/lib/apt/lists/*

# Download Android Studio — URL confirmed from user + version confirmed 2025.3.2.6
# Get SHA256 from developer.android.com/studio downloads table before building
ARG AS_SHA256
RUN wget -q "https://edgedl.me.gvt1.com/android/studio/ide-zips/2025.3.2.6/android-studio-panda2-linux.tar.gz" \
      -O /tmp/android-studio.tar.gz \
  && if [ -n "${AS_SHA256}" ]; then \
       echo "${AS_SHA256}  /tmp/android-studio.tar.gz" | sha256sum -c - ; \
     fi \
  && tar -xzf /tmp/android-studio.tar.gz -C /opt/ \
  && rm /tmp/android-studio.tar.gz \
  && chown -R developer:developer ${STUDIO_HOME} \
  && ln -sf ${STUDIO_HOME}/bin/studio.sh /usr/local/bin/android-studio

# Install SDK command-line tools
RUN wget -q "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
      -O /tmp/cmdline-tools.zip \
  && unzip -q /tmp/cmdline-tools.zip -d /tmp/ct \
  && mkdir -p ${ANDROID_HOME}/cmdline-tools \
  && mv /tmp/ct/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
  && rm -rf /tmp/cmdline-tools.zip /tmp/ct \
  && chown -R developer:developer ${ANDROID_HOME}

# Everything below runs as developer
USER developer

RUN yes | sdkmanager --licenses > /dev/null 2>&1 \
  && sdkmanager \
    "platform-tools" \
    "platforms;android-35" \
    "platforms;android-30" \
    "build-tools;35.0.0" \
    "sources;android-35"

RUN cat > ${STUDIO_HOME}/bin/studio64.vmoptions <<'EOF'
-Xms1024m
-Xmx8192m
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+UseStringDeduplication
-XX:ReservedCodeCacheSize=512m
-Dfile.encoding=UTF-8
EOF

RUN mkdir -p /home/developer/Desktop \
  && cat > /home/developer/Desktop/android-studio.desktop <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Exec=/opt/android-studio/bin/studio.sh
Icon=/opt/android-studio/bin/studio.png
Terminal=false
Categories=Development;IDE;
EOF
RUN chmod +x /home/developer/Desktop/android-studio.desktop

WORKDIR /home/developer
