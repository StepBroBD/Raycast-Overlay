#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq internetarchive

set -eo pipefail

old_version="1.49.0"

origin_url=$(curl --silent --location --head --output /dev/null --write-out "%{url_effective}" "https://api.raycast.app/v2/download")
new_version=$(echo "$origin_url" | sed -n "s/.*Raycast_v\([^_]*\)_.*\.dmg.*/\1/p")

curl --silent --output "raycast-$new_version.dmg" $origin_url

if [[ "$new_version" == "$old_version" ]]; then
	echo "Already up to date"
	exit 0
else
	echo "Update available: $old_version -> $new_version"
fi

ia configure --username="$USERNAME" --password="$PASSWORD"
ia upload raycast "raycast-$new_version.dmg" --metadata="mediatype:software"
rm -f "raycast-$new_version.dmg"

sed -Ei.bak '6s/( *old_version=")[^"]+/\1'"$new_version"'/' update.sh
rm update.sh.bak

echo "PUSH=true" >>$GITHUB_ENV
