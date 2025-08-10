{
  config,
  pkgs,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."https://${config.networking.hostName}.${config.sops.secrets.tailnet_name.path}:443/syncthing/" = {
      extraConfig = ''
        reverse_proxy localhost:8384
      '';
    };
  };

  # Ensure Caddy can bind to ports 80 and 443
  networking.firewall.allowedTCPPorts = [80 443];
}
