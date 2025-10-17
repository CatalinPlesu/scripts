#!/bin/sh -e


# Install packages for Android Studio.
sudo zypper -n in patterns-openSUSE-kvm_server \
     libstdc++6-32bit zlib-devel-32bit wget

# Install Android Studio.
# URL=https://dl.google.com/dl/android/studio/ide-zips/3.1.3.0
# wget -q ${URL}/android-studio-ide-173.4819257-linux.zip
# sudo unzip -q android-studio-ide-173.4819257-linux.zip -d /opt/
# rm -f android-studio-ide-173.4819257-linux.zip
# actually i used this
# tar xvf Downloads/android-studio-2024.3.1.13-linux.tar.gz -C ./dev/

# Create desktop file for Android Studio.
cat <<EOF | tee /home/catalin/.local/share/applications/android-studio.desktop
[Desktop Entry]
Type=Application
Name=Android Studio
Icon=/home/catalin/dev/android-studio/bin/studio.png
Exec=/home/catalin/dev/android-studio/bin/studio.sh
Terminal=false
Categories=Development;IDE;
EOF

# Add user to kvm group.
sudo gpasswd -a "${USER}" kvm

# Reboot for kvm.
sudo reboot
