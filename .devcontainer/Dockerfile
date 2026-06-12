FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG DEBIAN_FRONTEND=noninteractive

# Dependências básicas
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# =====================
# Flutter
# =====================

ENV FLUTTER_HOME=/opt/flutter

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME

ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

RUN flutter config --no-analytics

# =====================
# Android SDK
# =====================

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d /tmp && \
    mv /tmp/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"

RUN yes | sdkmanager --licenses

RUN sdkmanager \
    "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0"

RUN flutter doctor

USER vscode