FROM python3.8-slim-buster
# TODO: собрать свой образ nodejs+python+java+sdk

LABEL maintainer="denischernikovaz@gmail.com"

# Install Java
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /usr/share/man/man1 /usr/share/man/man2

ARG JDK_VERSION=11
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get --quiet update --yes && \
    apt-get install -yq --no-install-recommends libncurses5:i386 libc6:i386 libpulse0:i386 pulseaudio libstdc++6:i386 lib32gcc1 lib32ncurses6 lib32z1 zlib1g:i386 && \
    apt-get install -yq --no-install-recommends \ 
     libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \ 
     libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \ 
     libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \ 
     libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 libnss3

RUN apt-get install -y --no-install-recommends openjdk-${JDK_VERSION}-jdk && \
    apt-get install -yq --no-install-recommends git wget curl unzip && \
    apt-get install -yq --no-install-recommends qt5-default

RUN java --version

# Install Android SDK
ARG ANDROID_SDK_VERSION=6858069
ENV ANDROID_SDK_ROOT /opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip && \
    unzip *tools*linux*.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/tools && \
    rm *tools*linux*.zip
ENV JAVA_HOME /usr/lib/jvm/java-${JDK_VERSION}-openjdk-amd64
ENV GRADLE_HOME /opt/gradle
ENV KOTLIN_HOME /opt/kotlinc
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator
RUN export PATH=${ANDROID_SDK_ROOT}/tools:$PATH
RUN export PATH=${ANDROID_SDK_ROOT}/platform-tools:$PATH

# setup adb server
EXPOSE 5037
EXPOSE 4723

# Install emulator
RUN echo "y" | sdkmanager "platform-tools" "build-tools;29.0.3" "platforms;android-30" "emulator" && \
    sdkmanager --install "system-images;android-30;google_apis;x86_64" && \
    avdmanager create avd -n VitrinaEmulator --device "pixel" -k "system-images;android-30;google_apis;x86_64"

# Install nodejs and appium
RUN apt-get install -y nodejs && \
    curl https://www.npmjs.com/install.sh | sh && \
    npm install -g appium
