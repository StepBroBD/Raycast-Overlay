#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

set -eo pipefail

old_version="1.48.9"
new_version=$(curl -s "https://api.github.com/repos/stepbrobd/raycast-overlay/releases?per_page=1" | jq -r ".[0].name")
if [[ "$new_version" == "$old_version" ]]; then
	echo "Already up to date"
	export RELEASE=false
	exit 0
fi

url=$(curl --silent --location --head --output /dev/null --write-out "%{url_effective}" "https://api.raycast.app/v2/download")
version=$(echo "$url" | sed -n "s/.*Raycast_v\([^_]*\)_.*\.dmg.*/\1/p")
sha256=$(nix --extra-experimental-features nix-command store prefetch-file --json --name "raycast-$version" --hash-type sha256 "$url" | jq -r ".hash")

curl --silent --output "raycast-$version.dmg" $url

export RELEASE=true
export RAYCAST_URL="$url"
export RAYCAST_TAG="$version"
export RAYCAST_FILE="raycast-$version.dmg"
export RAYCAST_NOTE="\`raycast-$version.dmg -> $sha256\`"

sed -Ei.bak '6s/()[^"]+/\1'"$new_version"'/' release.sh
rm release.sh.bak
