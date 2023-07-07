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
                name = "raycast-1.55.0";
                src = super.fetchurl {
                  name = "Raycast.dmg";
                  url = "https://releases.raycast.com/releases/1.55.0/download?build=universal";
                  sha256 = "sha256-dtKCiHciuIzROseBjz8YFHfhSZ+N/ePKfLysyfm8HSM=";
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
