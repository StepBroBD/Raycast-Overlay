#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

set -eo pipefail

old_version=$(grep -Eo 'name = "raycast-[^;"]+' ./flake.nix | cut -d- -f2-)
new_version=$(curl --silent https://releases.raycast.com/releases/latest | jq -r '.version')

if [[ $new_version == $old_version ]]; then
	echo 'Already up to date'
	exit 0
else
	echo "raycast: $old_version -> $new_version"
fi

url="https://releases.raycast.com/releases/$new_version/download?build=universal"
hash=$(nix --extra-experimental-features nix-command store prefetch-file --json --hash-type sha256 $url | jq -r '.hash')
sed -Ei.bak '/ *name = /{N;N; s@("raycast-)[^;"]+@"'"raycast-$new_version"'@}' ./flake.nix
sed -Ei.bak '/ *url = /{N;N; s@("https://)[^;"]+@"'"$url"'@}' ./flake.nix
sed -Ei.bak '/ *sha256 = /{N;N; s@("sha256-)[^;"]+@"'"$hash"'@}' ./flake.nix
rm ./flake.nix.bak

echo "TAG=$new_version" >>$GITHUB_ENV
echo "PUSH=true" >>$GITHUB_ENV
