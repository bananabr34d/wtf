{ inputs, ... }:
{
  imports = [
    ./home.nix
    ./services.nix
    ./fonts.nix
    ./desktops/hyprland/hyprland.nix
    ./programs/yazi/yazi.nix
    ./programs/broot/broot.nix
    ./programs/bottom/bottom.nix
  ];
}
