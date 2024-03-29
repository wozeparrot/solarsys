#!/usr/bin/env bash
# script to generate ./default.nix

set -e
exec >"${BASH_SOURCE%/*}/default.nix"

cat <<EOF
{ branch ? "stable", pkgs }:
# Generated by ./update-discord.sh
let
  inherit (pkgs) callPackage fetchurl;
in {
EOF

for branch in "" ptb canary; do
    url=$(curl -sI "https://discordapp.com/api/download${branch:+/}${branch}?platform=linux&format=tar.gz" | grep -oP 'location: \K\S+')
    version=${url##https://dl*.discordapp.net/apps/linux/}
    version=${version%%/*.tar.gz}
    echo "  ${branch:-stable} = callPackage ./base.nix rec {"
    echo "    pname = \"discord${branch:+-}${branch}\";"
    case $branch in
        "") suffix="" ;;
        ptb) suffix="PTB" ;;
        canary) suffix="Canary" ;;
    esac
    echo "    binaryName = \"Discord${suffix}\";"
    echo "    desktopName = \"Discord${suffix:+ }${suffix}\";"
    echo "    version = \"${version}\";"
    echo "    src = fetchurl {"
    echo "      url = \"${url//${version}/\$\{version\}}\";"
    echo "      sha256 = \"$(nix-prefetch-url "$url")\";"
    echo "    };"
    echo "  };"
done

echo "}.\${branch}"

