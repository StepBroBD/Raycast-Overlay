{
  description = "Raycast releases and overlay";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
    utils.url = "flake:flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , utils
    , ...
    }: utils.lib.eachSystem [
      "aarch64-darwin"
      "x86_64-darwin"
    ]
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (self: super: {
              raycast = super.raycast.overrideAttrs (old: {
                name = "raycast-1.54.0";
                src = super.fetchurl {
                  name = "Raycast.dmg";
                  url = "https://releases.raycast.com/releases/1.54.0/download?build=universal";
                  sha256 = "sha256-Fv7iL9nc6qB+rHf2yoEEZB2aczkOmzju0aN5im1yxR4=";
                };
              });
            })
          ];
        };
      in
      {
        packages = utils.lib.flattenTree ({
          raycast = pkgs.raycast;
        });
        defaultPackage = self.packages.${system}.raycast;
      }
      );
}
