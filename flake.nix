{
  description = "biene configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";


    # Partitioning
    disko.url = "github:nix-community/disko";

    # Secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Use `nix flake show` to view outputs
  outputs = { self, nixpkgs, disko, sops-nix }@inputs: {

    # Output all modules in ./modules to flake. Modules should be in
    # individual subdirectories and contain a default.nix file
    nixosModules = builtins.listToAttrs (map
      (x: {
        name = x;
        value = import (./modules + "/${x}");
      })
      (builtins.attrNames (builtins.readDir ./modules)));
    # Define system configurations

    nixosConfigurations = {
      biene = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          { imports = builtins.attrValues self.nixosModules; }
        ];
      };
    };
  };
}
