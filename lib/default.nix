{ nixpkgs, unstable, darwin, disko, home-manager, hyprland, sops-nix, nixos-hardware, snapper }:
{
  inherit (import ./helper.nix { inherit nixpkgs unstable darwin disko home-manager hyprland sops-nix nixos-hardware snapper; })
    mkNixos mkHome mkDarwin;
}
