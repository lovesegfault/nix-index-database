{
  description = "nix-index database";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/master";

  outputs = { self, nixpkgs, ... }: with nixpkgs.lib;
    let
      systems = attrNames self.legacyPackages;

      packages = genAttrs systems
        (system: {
          default = self.packages.${system}.nix-index-with-db;
          nix-index-with-db =
            nixpkgs.legacyPackages.${system}.callPackage ./nix-index-wrapper.nix {
              nix-index-database = self.legacyPackages.${system}.database;
            };
        });
    in
    {
      inherit packages;

      legacyPackages = import ./packages.nix;

      hmModules.nix-index = import ./home-manager-module.nix {
        inherit (self) packages legacyPackages;
      };

      nixosModules.nix-index = import ./nixos-module.nix {
        inherit packages;
      };
    };
}
