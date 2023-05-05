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
                  url = "https://archive.org/download/raycast/raycast-1.50.2.dmg";
                  sha256 = "sha256-wwg6CodI431S2KjIIqRKTDB2veF9pZHcdq1HWpMP0YA=";
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
