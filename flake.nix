{
  description = "Raycast releases and overlay";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let forAllSystems = (nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ]); in
    {
      packages = forAllSystems (system: rec{
        raycast = { };
      });
      defaultPackage = forAllSystems (system: self.packages.${system}.default);
      overlay = final: prev: {
        raycast = self.packages.${prev.system}.raycast;
      };
    };
}
