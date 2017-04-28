FROM phusion/baseimage:0.9.21

MAINTAINER et2010 <jianwang.academic@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Fix "Couldn't register with accessibility bus" error message
ENV NO_AT_BRIDGE=1

ENV DEBIAN_FRONTEND noninteractive

# Select the fastest apt mirror
RUN cp /etc/apt/sources.list /etc/apt/sources.list.old \
    && curl -s http://mirrors.ubuntu.com/mirrors.txt|xargs -n1 -I {} sh -c 'echo `curl -r 0-102400 -s -w %{speed_download} -o /dev/null {}/ls-lR.gz` {}'|sort -g -r |head -1|awk '{ print $2  }'|tr -d '\n'|xargs -0 -n 1 -I {} sed -i 's@http://archive.ubuntu.com/ubuntu/@{}@' /etc/apt/sources.list

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
RUN apt-add-repository ppa:adrozdoff/emacs \
    && apt-get update && apt-get install emacs25 \
# Cleanup
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /root/.cache/*

# Revert to default apt repo
RUN  mv -f /etc/apt/sources.list.old /etc/apt/sources.list

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
