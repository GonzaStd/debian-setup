#!/bin/bash

echo Installing and configuring repositories
sudo apt update && sudo apt install extrepo -y
sudo extrepo enable librewolf && sudo extrepo update librewolf


echo Updating packages from repositories to our system
sudo apt update

echo Installing general programs
sudo apt install librewolf python3 python3-pip python3-venv pipx imagemagick -y

mkdir -p ~/.config/custom/librewolf/profiles

curl -fsSL "https://data.services.jetbrains.com/products/download?code=TBA&platform=linux" | sudo tar -xf - -C /opt/jetbrains-toolbox
sudo ln -s /opt/jetbrains-toolbox/bin/jetbrains-toolbox ~/.local/bin/jetbrains-toolbox
echo '[Desktop Entry]
Icon=jetbrains-toolbox
Exec=~/.local/bin/jetbrains-toolbox %u
Version=1.0
Type=Application
Categories=Development
Name=JetBrains Toolbox
StartupWMClass=jetbrains-toolbox
Terminal=false
MimeType=
X-GNOME-Autostart-enabled=true
X-Icon-Path=~/.local/share/icons/hicolor/scalable/apps/jetbrains-toolbox.svg
X-Installed-Icon-Cache-Path=,~/.local/share/icons/hicolor
StartupNotify=false
X-GNOME-Autostart-Delay=10
X-MATE-Autostart-Delay=10
X-KDE-autostart-after=panel' > ~/.local/share/applications/jetbrains-toolbox.desktop

echo Installing programs for game developing
# Resolve latest download url for Tiled
tiled_url=$(curl -fsSL https://api.github.com/repos/mapeditor/tiled/releases/latest | jq -r '.assets[] | 
select(
	(.name | endswith(".AppImage")) 
	and 
	(.name | contains("x86_64"))
) | 
.browser_download_url'
)
wget ${tiled_url} -O ~/.local/bin/tiled.AppImage
mkdir -p ~/.local/share/icons/hicolor/64x64/apps
wget -qO- "https://github.com/mapeditor/tiled/raw/refs/heads/master/src/tiled/resources/images/tiled-icon.ico" |
magick ico:- ~/.local/share/icons/hicolor/64x64/apps/tiled.png
echo '[Desktop Entry
Name=Tiled
Exec=~/.local/bin/tiled.AppImage
Icon=tiled
Type=Application
Categories=Development;Graphics;' > ~/.local/share/applications/tiled.desktop

