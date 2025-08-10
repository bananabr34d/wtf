{ config, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    folders = [ "$HOME/Documents" "$HOME/Pictures" ];
  };
}
