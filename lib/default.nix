{
  nixpkgs,
  unstable,
  darwin,
  disko,
  home-manager,
  hyprland,
  sops-nix,
  nixos-hardware,
}: {
  inherit
    (import ./helper.nix {inherit nixpkgs unstable darwin disko home-manager hyprland sops-nix nixos-hardware;})
    mkNixos
    mkHome
    mkDarwin
    ;
}
