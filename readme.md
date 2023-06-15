# Raycast Overlay

> ⚠️ Do not use unless you know what you are doing!

> ⚠️ Deprecated. This repo is only intended to be used as overlay.

After some communications with Raycast team (thanks Sorin), they added:

1. API for getting the latest version of Raycasat via `curl --silent https://releases.raycast.com/releases/latest | jq -r '.version'`.
2. Versioned download endpoint in the format of `https://releases.raycast.com/releases/<version>/download`.

```markdown
This repo is intended for providing a "stable" URL for Raycast to be used on [nixpkgs](https://github.com/nixos/nixpkgs), it can be also used as an Overlay for getting the latest release.

For all other use cases, please refer to [Raycast official website](https://www.raycast.com).

Disclaimer: No copyright infringement intended, softwares and source codes belong to the rightful owners.

## Setup

To run the GitHub Action, you'll need Internet Archive's username and password.

Set `USERNAME` and `PASSWORD` in your repo settings.

The GitHub Action will use your username and password to call `ia configure --username="$USERNAME" --password="PASSWORD"`.

## Why Bother?

Raycast's official download API (https://api.raycast.app/v2/download) returns an AWS CloudFront signed URL with a expiration timestamp and signature [^1].
This means we cannot use <https://api.raycast.app/v2/download> as `nixpkgs#raycast`'s source url since it will return a different URL everytime on request and it will always return a latest version artifact (does not guarantee a static SHA-256).

[^1]: The URL looks like this: https://d3jdrrl94b667u.cloudfront.net/Raycast_v1.48.9_9175190e05d819bce9b0a750813cb92014dba689_universal.dmg?response-content-disposition=attachment%3B%20filename%3DRaycast.dmg&Expires=1679977644&Signature=PMNYoqtn8RLcFVhGapgZiHTFT5Hn6tyipJwp5yXFqklbler~wdlKKnf4QIq3RBztwvPsjUI88g3HNaDXfd6vm1oyPXlVMoLq8DjDSC-4qXFpZ52y5nKqrkkZg6b5pJSQ1-WKmBq8108WT46LjIbWUjU3SeM-xCIE41elQKhySTaqE7RNslIH3RTWW2Hx9XznnPvifXvJUR9A~vJG-aYvtm3q3Ri3Mi4axUEJCm4lrDkS1Cu3jrPGdMA3aQKW2uXsJrSR~lwGp90j7xebYz9mddOoU8XJPPvJxEqm0ZnY3uay7PR3A~Vf8W3NTj68BQOBZmu0IlwEsXXAa8foIqm4Zw__&Key-Pair-Id=K69CUC23G592W

❌:

src = fetchurl {

# returns a different URL on every request

url = "https://api.raycast.app/v2/download";

# does not guarantee a static SHA-256

sha256 = "sha256-PSK/PLIOLUrqHAvEfOVMuGojLjwrCR4Vm9okE9d/5dE=";
};

So, based on this [PR](https://github.com/NixOS/nixpkgs/pull/223495#issuecomment-1486800799), we're making this repo to host a GitHub Action that periodically checks the latest version of Raycast and pushing it to [Internet Archive](https://web.archive.org).

✅:

src = fetchurl {
url = "https://archive.org/download/raycast/raycast-1.48.9.dmg";
sha256 = "sha256-PSK/PLIOLUrqHAvEfOVMuGojLjwrCR4Vm9okE9d/5dE=";
};

## Overlay

For those who uses Nix Flake:

1. Add `raycast-overlay.url = "github:stepbrobd/raycast-overlay";` to `inputs`.

inputs = {
nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
...
raycast-overlay.url = "github:stepbrobd/raycast-overlay";
...
};

2. Then add to `overlays`:

overlays = [
...
(self: super: {
raycast = inputs.raycast-overlay.packages.${super.system}.raycast;
})
...
];
```
