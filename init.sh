#!/usr/bin/env sh

rootdir=$(pwd)
username=

pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm openssh git

printf "\n\rNew username:"
read -p " " username < /dev/tty

useradd -m -G wheel -s /bin/bash $username
passwd $username

sed -i 's/^#\s*\(%wheel ALL=(ALL:ALL) ALL\)/\1/' /etc/sudoers
sed -i "/^\[user\]/,/^$/ {/^default=/d}; \$a [user]\ndefault=${username}" /etc/wsl.conf

usershell=$(getent passwd $username | cut -d: -f7)
shellname=$(basename $usershell)
shellrc="/home/$username/.$shellname"rc

cat << 'EOF' >> "$shellrc"

if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
  ssh-add ~/.ssh/id_ed25519 2> /dev/null
fi

cd ~/
EOF

printf "\n\rGenerating new ssh key..."
printf "\n\rSet your email:"
read -p " " useremail < /dev/tty
[ ! -d /home/$username/.ssh ] && mkdir /home/$username/.ssh
ssh-keygen -t ed25519 -f /home/$username/.ssh/id_ed25519 -C "$useremail"

chown -R $username:$username /home/$username/.ssh

su - $username
