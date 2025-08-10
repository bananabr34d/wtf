{
  nixpkgs,
  unstable,
  darwin,
  disko,
  home-manager,
  hyprland,
  sops-nix,
  nixos-hardware,
  snapper,
}: {
  mkNixos = {
    system,
    modules,
    specialArgs ? {},
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = specialArgs // {inherit nixpkgs unstable disko hyprland sops-nix nixos-hardware snapper;};
      modules =
        modules
        ++ [
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
        ];
    };

  mkHome = {
    system,
    username,
    modules,
    extraSpecialArgs ? {},
  }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {inherit system;};
      inherit system;
      username = username;
      homeDirectory =
        if system == "aarch64-darwin"
        then "/Users/${username}"
        else "/home/${username}";
      extraSpecialArgs = extraSpecialArgs // {inherit nixpkgs unstable hyprland sops-nix;};
      modules =
        modules
        ++ [
          sops-nix.homeManagerModules.sops
        ];
    };

  mkDarwin = {
    system,
    modules,
    specialArgs ? {},
  }:
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = specialArgs // {inherit nixpkgs unstable;};
      modules =
        modules
        ++ [
          home-manager.darwinModules.home-manager
        ];
    };
}
