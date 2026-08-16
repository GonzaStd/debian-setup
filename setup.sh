#!/bin/bash

echo "-- Installing and configuring repositories --"
echo "   Installing extrepo"
sudo apt update && sudo apt install extrepo -y
echo

echo "  Setup librewolf extrepo"
sudo extrepo enable librewolf && sudo extrepo update librewolf

echo 
echo "-- Updating packages from repositories to the system --"
sudo apt update

echo
echo "-- Installing general programs --"
sudo apt install librewolf python3 python3-pip python3-venv pipx imagemagick -y

mkdir -p ~/.config/custom/librewolf/profiles

echo
echo "-- Installing toolbox --"

toolbox_dir='/opt/jetbrains-toolbox'
sudo rm -rf $toolbox_dir
curl -fsSL "https://data.services.jetbrains.com/products/download?code=TBA&platform=linux" | sudo tar -xzf - -C /opt/ 
sudo mv /opt/jetbrains-toolbox* "${toolbox_dir}"
ln -sfn /opt/jetbrains-toolbox/bin/jetbrains-toolbox ~/.local/bin/jetbrains-toolbox

echo "[Desktop Entry]
Icon=jetbrains-toolbox
Exec=${HOME}/.local/bin/jetbrains-toolbox %u
Version=1.0
Type=Application
Categories=Development
Name=JetBrains Toolbox
StartupWMClass=jetbrains-toolbox
Terminal=false
MimeType=
X-GNOME-Autostart-enabled=true
X-Icon-Path=${HOME}/.local/share/icons/hicolor/scalable/apps/jetbrains-toolbox.svg
X-Installed-Icon-Cache-Path=,~/.local/share/icons/hicolor
StartupNotify=false
X-GNOME-Autostart-Delay=10
X-MATE-Autostart-Delay=10
X-KDE-autostart-after=panel" > ~/.local/share/applications/jetbrains-toolbox.desktop
echo
echo "-- Installing programs for game developing --"
# -- TILED --
tiled_app="${HOME}/.local/bin/tiled.AppImage"
# Resolve latest download url for Tiled
tiled_digest=$(curl -fsSL https://api.github.com/repos/mapeditor/tiled/releases/latest | jq -r '.assets[] | 
select(
        (.name | endswith(".AppImage")) 
        and 
        (.name | contains("x86_64"))
) | 
  .digest'
)
tiled_hash=$(echo "$digest" | cut -d':' -f2) # SHA256

tiled_url=$(curl -fsSL https://api.github.com/repos/mapeditor/tiled/releases/latest | jq -r '.assets[] | 
select(
	(.name | endswith(".AppImage")) 
	and 
	(.name | contains("x86_64"))
) | 
.browser_download_url'
)
function check_integrity() {
  file=$1
  expected_hash=$2
  existent_hash=$(sha256sum "${file}")
  if ! cmp <("${existent_hash}") <("${expected_hash}"); then
    return 1
  fi
  echo "File ${file} is okay"
  return 0
}

function download() {
  url=$1
  path=$2
  expected_hash=$3
  wget $url -O $path
  retries=0
  while ! check_integrity $path $expected_hash && [ retries<=2  ]; do
    echo "Retry ${retries}"
    rm -f $path
    download $1 $2 $3
  done
  if [ retries == 3 ]; then
    echo "Integrity check failed. Integrity of the file is wrong or expected hash provided is wrong."
    return 1
  fi
  return 0
}

if [ -f "${tiled_app}" ]; then
  if ! check_integrity $tiled_app $tiled_hash; then
    rm -f $tiled_app
    download $tiled_url $tiled_app $tiled_hash
  fi
  echo "You already have latest version of tiled! Download skipped."
else
  wget "${tiled_url}" -O "${tiled_app}"
fi
sudo chmod +x $tiled_app
tiled_icon_dir="${HOME}/.local/share/icons/hicolor/64x64/apps"
tiled_icon="${tiled_icon_dir}/tiled.png"
if [ ! -f tiled_icon ]; then # get icon
    mkdir -p ~/.local/share/icons/hicolor/64x64/apps/
    wget -qO- "https://github.com/mapeditor/tiled/raw/refs/heads/master/src/tiled/resources/images/tiled-icon.ico" |
    magick ico:-[0] $tiled_icon
fi

echo "[Desktop Entry]
Name=Tiled
Exec=${HOME}/.local/bin/tiled.AppImage
Icon=${tiled_icon}
Type=Application
Categories=Development,Graphics" > ~/.local/share/applications/tiled.desktop
# -- TILED END --
