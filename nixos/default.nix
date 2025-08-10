{ inputs, ... }:
{
  imports = [
    ./common.nix
    ./hosts/carbon/configuration.nix
    ./hosts/hydrogen/configuration.nix
    ./hosts/ether/configuration.nix
    ./hosts/relic/configuration.nix
  ];
}
