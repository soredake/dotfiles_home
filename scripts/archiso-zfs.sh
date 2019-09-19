#!/bin/bash
# http://www.michaelabrahamsen.com/posts/arch-linux-iso-zfs/
if [[ "${2}" == "docker" ]]; then
  sudo docker pull base/devel

  sudo docker run --privileged -it -v "${1}"/archiso:/archiso base/devel
fi
#pacman -Syyu
#pacman -S archiso

[[ ! -d "${1}/archiso" ]] && mkdir -p "${1}/archiso"
cd "${1}/archiso" || exit 1
cp -rf /usr/share/archiso/configs/releng/* .

sed -i "s|systemctl set-default multi-user.target|systemctl set-default graphical.target|g" airootfs/root/customize_airootfs.sh

ln -sfv /usr/lib/systemd/system/sddm.service airootfs/etc/systemd/system/display-manager.service

mkdir -p airootfs/etc/sddm.conf.d
sed -e "s/MinimumUid=1000/MinimumUid=0/g" -e "s/MaximumUid=60000/MaximumUid=0/g" /usr/lib/sddm/sddm.conf.d/default.conf > airootfs/etc/sddm.conf.d/default.conf

tee -a pacman.conf >/dev/null <<END
[archzfs]
SigLevel = Optional TrustAll
Server = http://archzfs.com/\$repo/x86_64
END

tee -a packages.x86_64 >/dev/null <<END
archzfs-dkms
cpupower
firefox
gedit
gparted
htop
linux-headers
keepassxc
lsof
mpv
p7zip
packagekit-qt5
pavucontrol
plasma-meta
plasma-nm
plasma-wayland-session
pulseaudio
pulseaudio-alsa
kdeaccessibility-meta
kdeadmin-meta
kdebase-meta
kdegraphics-meta
kdenetwork-meta
kdepim-meta
kdeutils-meta
kdewebdev-meta
ranger
sddm
sddm-kcm
ttf-dejavu
ttf-hack
unrar
xfce4
xorg-server
youtube-dl
zip
END

sudo ./build.sh -v