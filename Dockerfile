FROM schnicklbob/ubuntudesk:latest

ENV ANDROID_STUDIO_VERSION=2025.3.2.22
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/35.0.0

# Dependencies for Android Studio on 64-bit Linux
RUN apt-get update && apt-get install -y \
    lib32z1 \
    lib32stdc++6 \
    libc6-i386 \
    lib32ncurses6 \
    libxtst6 \
    libxi6 \
    libxrender1 \
    libfreetype6 \
    fontconfig \
    unzip \
    wget \
    curl \
  && rm -rf /var/lib/apt/lists/*

# Install Android Studio
RUN wget -q "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${ANDROID_STUDIO_VERSION}/android-studio-${ANDROID_STUDIO_VERSION}-linux.tar.gz" \
      -O /tmp/android-studio.tar.gz \
  && tar -xzf /tmp/android-studio.tar.gz -C /opt/ \
  && rm /tmp/android-studio.tar.gz \
  && ln -sf /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio

# Install Android SDK command-line tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
  && wget -q "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
      -O /tmp/cmdline-tools.zip \
  && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-extract \
  && mv /tmp/cmdline-tools-extract/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
  && rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools-extract

# Accept licenses and install SDK platforms + build tools
RUN yes | sdkmanager --licenses > /dev/null 2>&1 \
  && sdkmanager \
    "platform-tools" \
    "platforms;android-35" \
    "platforms;android-30" \
    "build-tools;35.0.0" \
    "sources;android-35"

# Tune Android Studio JVM for available RAM (8GB heap ceiling)
RUN cat > /opt/android-studio/bin/studio64.vmoptions <<'EOF'
-Xms1024m
-Xmx8192m
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+UseStringDeduplication
-XX:ReservedCodeCacheSize=512m
-Dfile.encoding=UTF-8
EOF

# Desktop shortcut for noVNC session
RUN mkdir -p /root/Desktop \
  && cat > /root/Desktop/android-studio.desktop <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Exec=/opt/android-studio/bin/studio.sh
Icon=/opt/android-studio/bin/studio.png
Terminal=false
Categories=Development;IDE;
EOF
RUN chmod +x /root/Desktop/android-studio.desktop

WORKDIR /root
