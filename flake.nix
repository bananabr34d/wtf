{
  description = "NixOS, Nix-Darwin, and Home Manager configurations for multiple systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    snapper.url = "github:openSUSE/snapper";
  };

  outputs = {
    self,
    nixpkgs,
    unstable,
    darwin,
    disko,
    home-manager,
    hyprland,
    sops-nix,
    nixos-hardware,
    snapper,
    ...
  }: let
    lib = import ./lib {inherit nixpkgs unstable darwin disko home-manager hyprland sops-nix nixos-hardware snapper;};
  in {
    nixosConfigurations = {
      carbon = lib.mkNixos {
        system = "x86_64-linux";
        modules = [
          ./nixos/hosts/carbon/configuration.nix
          ./nixos/common.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x1
        ];
      };
      hydrogen = lib.mkNixos {
        system = "x86_64-linux";
        modules = [
          ./nixos/hosts/hydrogen/configuration.nix
          ./nixos/common.nix
        ];
      };
      ether = lib.mkNixos {
        system = "x86_64-linux";
        modules = [
          ./nixos/hosts/ether/configuration.nix
          ./nixos/common.nix
          {
            virtualisation.vmVariant = {
              virtualisation = {
                memorySize = 2048; # MB
                cores = 2;
                diskSize = 10240; # MB
                graphics = true;
              };
            };
          }
        ];
      };
      relic = lib.mkNixos {
        system = "x86_64-linux";
        modules = [
          ./nixos/hosts/relic/configuration.nix
          ./nixos/common.nix
          nixos-hardware.nixosModules.dell-xps-13-9350
        ];
      };
    };

    darwinConfigurations.silicon = lib.mkDarwin {
      system = "aarch64-darwin";
      modules = [
        ./darwin/hosts/silicon/configuration.nix
        ./darwin/common.nix
      ];
    };

    homeConfigurations = {
      "joe@carbon" = lib.mkHome {
        system = "x86_64-linux";
        username = "joe";
        modules = [./home];
        extraSpecialArgs = {hostName = "carbon";};
      };
      "joe@hydrogen" = lib.mkHome {
        system = "x86_64-linux";
        username = "joe";
        modules = [./home];
        extraSpecialArgs = {hostName = "hydrogen";};
      };
      "joe@ether" = lib.mkHome {
        system = "x86_64-linux";
        username = "joe";
        modules = [./home];
        extraSpecialArgs = {hostName = "ether";};
      };
      "joe@relic" = lib.mkHome {
        system = "x86_64-linux";
        username = "joe";
        modules = [./home];
        extraSpecialArgs = {hostName = "relic";};
      };
      "joe@silicon" = lib.mkHome {
        system = "aarch64-darwin";
        username = "joe";
        modules = [./home];
        extraSpecialArgs = {hostName = "silicon";};
      };
    };
  };
}
