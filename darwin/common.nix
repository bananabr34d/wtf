{ config, pkgs, ... }:
{
  users.users.joe = {
    shell = pkgs.zsh;
  };
  environment.systemPackages = with pkgs; [ caddy git tailscale vim ];
  services.tailscale.enable = true;
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 4;
}
