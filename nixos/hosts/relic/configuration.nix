{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "relic";

  # Enable TLP for power management with XPS-specific settings
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Tailscale configuration
  services.tailscale = {
    enable = true;
    extraUpFlags = ["--ssh"];
  };

  # SOPS secrets for system-level configuration
  sops = {
    defaultSopsFile = ../../../secrets.yaml;
    age.keyFile = "/var/lib/sops/age/keys.txt";
    secrets = {
      joe_password = {
        neededForUsers = true;
      };
      cifs-credentials = {
        path = "/etc/cifs-credentials";
      };
      tailscale_auth_key = {
        path = "/etc/tailscale/auth_key";
      };
      tailnet_name = {
        path = "/etc/tailscale/tailnet_name";
      };
    };
  };

  # Samba mounts
  fileSystems = {
    "/mnt/NAS" = {
      device = "//<tailnet>/data";
      fsType = "cifs";
      options = [
        "credentials=/etc/cifs-credentials"
        "uid=joe"
        "gid=users"
        "vers=3.0"
        "iocharset=utf8"
        "noauto"
      ];
    };
    "/mnt/NAS-joe" = {
      device = "//<tailnet>/joe";
      fsType = "cifs";
      options = [
        "credentials=/etc/cifs-credentials"
        "uid=joe"
        "gid=users"
        "vers=3.0"
        "iocharset=utf8"
        "noauto"
      ];
    };
  };

  # Ensure user joe is configured
  users.users.joe = {
    isNormalUser = true;
    extraGroups = ["wheel" "lp"];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.joe_password.path;
  };

  # System state version
  system.stateVersion = "25.05";
}
