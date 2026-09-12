FROM ghcr.io/containerpak/wine@sha256:349a09eac549c9cddd5b6b40d892d72b4a5b92b25bd210a8e20075072969a97a

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        cabextract \
        curl \
        desktop-file-utils \
        file \
        fontconfig \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-tools \
        libfreetype6 \
        libfreetype6:i386 \
        tar \
        wget \
        wmctrl \
        x11-utils \
        xz-utils \
        zstd \
    && rm -rf /var/lib/apt/lists/*

COPY install.sh /opt/cspenguin/install.sh
COPY cpak-launcher.sh /usr/local/bin/cspenguin-cpak
COPY cpak-launcher.sh /usr/local/bin/cspenguin-studio-cpak
COPY cspenguin.desktop /usr/share/applications/com.cspenguin.ClipStudioPaint.desktop
COPY cspenguin-studio.desktop /usr/share/applications/com.cspenguin.ClipStudio.desktop

RUN chmod 0755 /opt/cspenguin/install.sh /usr/local/bin/cspenguin-cpak /usr/local/bin/cspenguin-studio-cpak
