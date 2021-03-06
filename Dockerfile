# based on https://registry.hub.docker.com/u/samtstern/android-sdk/dockerfile/ with openjdk-8
FROM tim03/jdk:8

LABEL MAINTAINER Chen, Wenli <chenwenli@chenwenli.com>

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -yq libstdc++6:i386 zlib1g:i386 libncurses5:i386 --no-install-recommends && \
    apt-get -y install --reinstall locales && \
    dpkg-reconfigure locales && \
    echo 'zh_CN.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    localedef --list-archive && locale -a &&  \
    update-locale &&  \
    apt-get clean

# Download and untar SDK
ENV ANDROID_SDK_URL http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN curl -L "${ANDROID_SDK_URL}" | tar --no-same-owner -xz -C /usr/local
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_SDK /usr/local/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$PATH

# Download and untar NDK
ENV ANDROID_NDK_HOME /usr/local/android-ndk-linux
ENV ANDROID_NDK_URL http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
RUN mkdir ~/tmp && cd ~/tmp && \
    wget -q "${ANDROID_NDK_URL}" && \
    chmod a+x ./android-ndk-r10e-linux-x86_64.bin && \
    ./android-ndk-r10e-linux-x86_64.bin && \
    mv ./android-ndk-r10e ${ANDROID_NDK_HOME} && \
    rm -rf ~/tmp
ENV PATH ${PATH}:${ANDROID_NDK_HOME}

# Install Android SDK components

ONBUILD COPY android_sdk_components.env /android_sdk_components.env
ONBUILD RUN (while :; do echo 'y'; sleep 3; done) | android update sdk --no-ui --all --filter "$(cat /android_sdk_components.env)"

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS -Xms256m -Xmx512m

