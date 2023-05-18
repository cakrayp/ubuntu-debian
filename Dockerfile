FROM ubuntu:latest

# install packages
RUN apt-get update && apt upgrade -y \
    && apt-get install -q -y \
    && apt-get install git -y \
    && apt-get install build-essential libssl-dev -y \
    && apt-get install curl -y \
    && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash \
    && nvm install 16.14.2 \
    && nvm use 16.14.2 \
    dirmngr \
    gnupg2 \
    lsb-release \
    build-essential \
    gcc \
    g++ \
    ssh \
    tmux \
    screen

# Getting supervisorD to look after ssh
RUN echo "[program:sshd]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/supervisord.conf

## -------- Pulled from  https://github.com/osrf/docker_images/blob/master/ros/melodic/ubuntu/bionic/ros-core/Dockerfile
# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list for ROS
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# setup environment vars
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV ROS_DISTRO=melodic

# install ros packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    ros-${ROS_DISTRO}-desktop-full=1.4.1-0* \
    ros-${ROS_DISTRO}-ros-control \
    ros-${ROS_DISTRO}-ros-controllers \
    ros-${ROS_DISTRO}-gazebo-msgs \
    ros-${ROS_DISTRO}-gazebo-ros \
    && rm -rf /var/lib/apt/lists/*

# -------- My Stuff

# Define variables
ARG USERNAME=ubuntu
ARG WORKDIR=/home/ubuntu

ENV USERNAME=${USERNAME}
ENV WORKDIR=${WORKDIR}


# Forces this user :D
ENV USER=${USERNAME}

# Create user and give it sudo
RUN useradd -ms /bin/bash $USERNAME
RUN usermod -aG sudo ${USERNAME}

# Working dir
WORKDIR ${WORKDIR}

# Get SSH running
RUN service ssh restart
RUN update-rc.d ssh defaults
RUN update-rc.d ssh enable 2 3 4

# Copy files across
ARG WORKSPACE=/home/ubuntu/catkin_ws
ENV WORKSPACE=${WORKSPACE}


ENV VNC_PASSWORD=ubuntu342
ENV PASSWORD=${VNC_PASSWORD}
ENV RESOLUTION=1920x1080

# FROM ubuntu:20.04 as ubuntu-base

# ENV DEBIAN_FRONTEND=noninteractive \
#     DEBCONF_NONINTERACTIVE_SEEN=true

# RUN apt-get -qqy update \
#     && apt-get -qqy --no-install-recommends install \
#         sudo \
#         supervisor \
#         xvfb x11vnc novnc websockify \
#     && apt-get autoclean \
#     && apt-get autoremove \
#     && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# RUN cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# COPY scripts/* /opt/bin/

# # Add Supervisor configuration file
# COPY supervisord.conf /etc/supervisor/

# # Relaxing permissions for other non-sudo environments
# RUN  mkdir -p /var/run/supervisor /var/log/supervisor \
#     && chmod -R 777 /opt/bin/ /var/run/supervisor /var/log/supervisor /etc/passwd \
#     && chgrp -R 0 /opt/bin/ /var/run/supervisor /var/log/supervisor \
#     && chmod -R g=u /opt/bin/ /var/run/supervisor /var/log/supervisor

# # Creating base directory for Xvfb
# RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# CMD ["/opt/bin/entry_point.sh"]

# #============================
# # Utilities
# #============================
# FROM ubuntu-base as ubuntu-utilities
# RUN apt-get update
# RUN apt-get install ffmpeg -y
# RUN apt-get -qqy update \
#     && apt-get -qqy --no-install-recommends install \
#         firefox htop terminator gnupg2 software-properties-common \
#     && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
#     && apt install -qqy --no-install-recommends ./google-chrome-stable_current_amd64.deb \
#     && apt-add-repository ppa:remmina-ppa-team/remmina-next \
#     && apt update \
#     && apt install -qqy --no-install-recommends remmina remmina-plugin-rdp remmina-plugin-secret \
#     && apt-add-repository ppa:obsproject/obs-studio \
#     && apt update \
#     && apt install -qqy --no-install-recommends obs-studio \
#     && apt install unzip \
#     && apt-get autoclean \
#     && apt-get autoremove \
#     && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# # COPY conf.d/* /etc/supervisor/conf.d/


# #============================
# # GUI
# #============================
# FROM ubuntu-utilities as ubuntu-ui

# ENV SCREEN_WIDTH=1280 \
#     SCREEN_HEIGHT=720 \
#     SCREEN_DEPTH=24 \
#     SCREEN_DPI=96 \
#     DISPLAY=:99 \
#     DISPLAY_NUM=99 \
#     UI_COMMAND=/usr/bin/startxfce4

# # RUN apt-get update -qqy \
# #     && apt-get -qqy install \
# #         xserver-xorg xserver-xorg-video-fbdev xinit pciutils xinput xfonts-100dpi xfonts-75dpi xfonts-scalable kde-plasma-desktop

# RUN apt-get update -qqy \
#     && apt-get -qqy install --no-install-recommends \
#         dbus-x11 xfce4 \
#     && apt-get autoclean \
#     && apt-get autoremove \
#     && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
