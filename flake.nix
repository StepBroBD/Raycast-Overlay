{
  description = "Raycast releases and overlay";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake:flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }: flake-utils.lib.eachSystem [
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
                pname = "raycast";
                src = builtins.fetchurl {
                  url = "https://archive.org/download/raycast/raycast-1.49.3.dmg";
                  sha256 = "sha256-Irn99/49fRQg73cX8aKZ72D1o+mDPg44Q1pXAMdXrb0=";
                };
              });
            })
          ];
        };
      in
      {
        packages = flake-utils.lib.flattenTree ({
          raycast = pkgs.raycast;
        });
        defaultPackage = self.packages.${system}.raycast;
      }
      );
}
