FROM phusion/baseimage:0.9.22

MAINTAINER et2010 <jianwang.academic@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Fix "Couldn't register with accessibility bus" error message
ENV NO_AT_BRIDGE=1

ENV DEBIAN_FRONTEND noninteractive

RUN echo 'APT::Get::Assume-Yes "true";' >> /etc/apt/apt.conf \
    && apt-get update && apt-get install \
    dbus-x11 \
    fontconfig \
    git \
    libgl1-mesa-glx \
    make \
    sudo \
    unzip \
# Cleanup
    && apt-get autoremove \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /root/.cache/*

COPY asEnvUser /usr/local/sbin/

# Only for sudoers
RUN chown root /usr/local/sbin/asEnvUser \
    && chmod 700  /usr/local/sbin/asEnvUser

# ^^^^^^^ Those layers are shared ^^^^^^^

# Emacs
RUN apt-add-repository ppa:kelleyk/emacs \
    && apt-get update && apt-get install emacs25 \
# Cleanup
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /root/.cache/*

ENV UNAME="emacser" \
    GNAME="emacs" \
    UHOME="/home/emacs" \
    UID="1000" \
    GID="1000" \
    WORKSPACE="/mnt/workspace" \
    SHELL="/bin/bash"

WORKDIR "${WORKSPACE}"

ENTRYPOINT ["asEnvUser"]
CMD ["bash", "-c", "emacs; /bin/bash"]
