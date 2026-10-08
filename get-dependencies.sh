#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm cmake sdl3

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

echo "Building Chocolate Stunts..."
echo "---------------------------------------------------------------"
REPO="https://github.com/CommonLoon102/restunts-bb11"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of Chocolate Stunts..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --depth 1 "$REPO" ./restunts-bb11
else
	echo "Making stable build of Chocolate Stunts..."
	VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//; s/^v//')"
	git clone --branch v"$VERSION" --single-branch --depth 1 "$REPO" ./restunts-bb11
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cmake -S ./restunts-bb11 -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
mv -v build/restunts build/libnuked-opl2.so ./AppDir/bin
mv -v ./restunts-bb11/assets/* ./AppDir/bin
