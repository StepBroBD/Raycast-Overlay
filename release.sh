#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

set -eo pipefail

url=$(curl --silent --location --head --output /dev/null --write-out "%{url_effective}" "https://api.raycast.app/v2/download")
version=$(echo "$url" | sed -n "s/.*Raycast_v\([^_]*\)_.*\.dmg.*/\1/p")
sha256=$(nix --extra-experimental-features nix-command store prefetch-file --json --name raycast-$version --hash-type sha256 $url | jq ".hash")

curl --silent --output "raycast-$version.dmg" $url

echo "raycast-$version.dmg: $sha256"
