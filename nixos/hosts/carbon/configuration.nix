{ config, pkgs, ... }:
{
  # Host-specific configuration for carbon
  networking.hostName = "carbon";
  # Add hardware-specific settings here (e.g., from hardware-configuration.nix)
}
