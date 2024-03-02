#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Set environment variables
export PYTHONUNBUFFERED=1
export DEBIAN_FRONTEND=noninteractive

# Update and install packages
apt-get update && \
apt-get install -y --no-install-recommends sudo tzdata locales ssh pulseaudio xvfb x11-xserver-utils gnome-screenshot && \
rm -rf /var/lib/apt/lists/*

# Generate locale
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8

# Run custom installation script for Ubuntu dependencies
/tmp/tools/install_ubuntu_dependencies.sh

# Clean up
rm -rf /var/lib/apt/lists/* && \
rm -rf /tmp/*

# Remove unused architectures from gcc for panda
rm -rf /usr/lib/gcc/arm-none-eabi/9.2.1/arm/ && \
rm -rf /usr/lib/gcc/arm-none-eabi/9.2.1/thumb/nofp thumb/v6* thumb/v8* thumb/v7+fp thumb/v7-r+fp.sp

# Install OpenCL and other dependencies
apt-get update && apt-get install -y --no-install-recommends \
apt-utils \
alien \
unzip \
tar \
curl \
xz-utils \
dbus \
gcc-arm-none-eabi \
tmux \
vim \
lsb-core \
libx11-6 \
&& rm -rf /var/lib/apt/lists/*

# Download and install Intel OpenCL drivers
mkdir -p /tmp/opencl-driver-intel
cd /tmp/opencl-driver-intel
INTEL_DRIVER=l_opencl_p_18.1.0.015.tgz
INTEL_DRIVER_URL=https://registrationcenter-download.intel.com/akdlm/irc_nas/vcp/15532
curl -O $INTEL_DRIVER_URL/$INTEL_DRIVER
tar -xzf $INTEL_DRIVER
for i in $(basename $INTEL_DRIVER .tgz)/rpm/*.rpm; do alien --to-deb $i; done
dpkg -i *.deb
rm -rf $INTEL_DRIVER $(basename $INTEL_DRIVER .tgz) *.deb
mkdir -p /etc/OpenCL/vendors
echo /opt/intel/opencl_compilers_and_libraries_18.1.0.015/linux/compiler/lib/intel64_lin/libintelocl.so > /etc/OpenCL/vendors/intel.icd
cd /
rm -rf /tmp/opencl-driver-intel

# Configure environment variables for NVIDIA and QtWebEngine
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute
export QTWEBENGINE_DISABLE_SANDBOX=1

# Generate D-Bus machine ID
dbus-uuidgen > /etc/machine-id

# Create a new user
USER=batman
USER_UID=1000
useradd -m -s /bin/bash -u $USER_UID $USER
usermod -aG sudo $USER
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Configure Python environment for the user
export POETRY_VIRTUALENVS_CREATE=false
export PYENV_VERSION=3.11.4
export PYENV_ROOT="/home/$USER/pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# Install Python dependencies
sudo -u $USER /tmp/tools/install_python_dependencies.sh

# Clean up
rm -rf /tmp/* && \
rm -rf /home/$USER/.cache && \
find /home/$USER/pyenv -type d -name ".git" | xargs rm -rf && \
rm -rf /home/$USER/pyenv/versions/3.11.4/lib/python3.11/test

# Git configuration
sudo -u $USER git config --global --add safe.directory /tmp/openpilot
