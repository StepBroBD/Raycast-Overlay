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
                pname = "raycast";
                src = builtins.fetchurl {
                  url = "https://archive.org/download/raycast/raycast-1.53.2.dmg";
                  sha256 = "sha256-e2UGS1LSBj0xZu0gWlb8SiXhx1sZzcZDOGPhg6ziI9c=";
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
