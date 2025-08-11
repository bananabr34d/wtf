{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  tsExitNodes = ["hydrogen"]; # Define hydrogen as an exit node
  commonSnapperConfig = {
    ALLOW_USERS = ["joe"];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_MIN_AGE = 1800;
    TIMELINE_LIMIT_HOURLY = 10;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 2;
  };
in {
  imports = [
    ./services/caddy.nix
  ];

  # Enable experimental features for flakes and nix-command
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # SOPS configuration
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/joe/.config/sops/age/keys.txt";
    secrets.joe_password = {
      neededForUsers = true;
      owner = "joe";
    };
    secrets.cifs-credentials = {
      path = "/etc/samba/credentials";
      mode = "0400";
      owner = "root";
    };
    secrets.tailscale_auth_key = {
      path = "/etc/tailscale/auth.key";
      mode = "0400";
      owner = "root";
    };
    secrets.tailnet_name = {
      path = "/etc/tailscale/tailnet_name";
      mode = "0400";
      owner = "root";
    };
  };

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    openFirewall = true; # Opens UDP port 41641 for Tailscale
    package = pkgs.tailscale; # Use stable nixos-unstable channel
    permitCertUid = "caddy"; # Allow Caddy to access Tailscale certificates
    extraUpFlags =
      [
        "--auth-key=file:/etc/tailscale/auth.key"
        "--accept-routes"
        "--operator=joe"
        "--ssh"
      ]
      ++ lib.optional (lib.elem config.networking.hostName tsExitNodes) "--advertise-exit-node";
    useRoutingFeatures =
      if (lib.elem config.networking.hostName tsExitNodes)
      then "server"
      else "client";
  };

  # Enable Snapper
  services.snapper = {
    enable = true;
    snapshotInterval = "hourly";
    cleanupInterval = "1d";
    configs = lib.mapAttrs (name: subvolume:
      {
        SUBVOLUME = subvolume;
      }
      // commonSnapperConfig
      // (
        if name == "tmp"
        then {
          TIMELINE_LIMIT_WEEKLY = 0;
          TIMELINE_LIMIT_MONTHLY = 0;
        }
        else {}
      )) {
      root = "/";
      home = "/home";
      var-log = "/var/log";
      var-lib = "/var/lib";
      tmp = "/tmp";
      local-share = "/home/joe/.local/share";
    };
  };

  # Enable systemd-boot entries
  boot.loader.systemd-boot.enable = true;

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us"; # Set US keyboard layout for X
  programs.hyprland.enable = true;

  # Enable OpenSSH server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Enable CUPS for printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [gutenprint hplip];
  };

  # Enable Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable mDNS for IPv4
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
  };

  # Open firewall ports for CUPS, Avahi, Tailscale, and Syncthing
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [631 8384]; # CUPS, Syncthing
    allowedUDPPorts = [5353]; # Avahi mDNS
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.joe = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "lp"]; # Add lp for printer management
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.joe_password.path;
  };

  environment.systemPackages = with pkgs; [
    bemoji # Emoji picker for additional emoji selection
    brave # Web browser with privacy focus
    caddy # Web server for Syncthing reverse proxy
    curl # Command-line tool for transferring data with URLs
    fastfetch # System information tool for CLI
    fuzzel # Wayland-native application launcher
    git # Version control system
    hyprland # Wayland compositor for desktop environment
    hyprlock # Screen lock for Hyprland
    hyprpaper # Wallpaper daemon for Hyprland
    hyprpicker # Color picker for Hyprland
    hyprshot # Screenshot tool for Hyprland
    kitty # Fast, feature-rich terminal emulator
    nh # NH is a modern helper utility that aims to consolidate NixOS commands
    nix-index-database # Added for command-not-found
    nixos-needtoreboot # Added for reboot checks
    openssh # SSH client and server for secure remote access
    snapper # BTRFS snapshot management tool
    spotify # Music streaming client
    swaync # Notification center for Wayland
    system-config-printer # GUI for managing printers
    tailscale # WireGuard-based VPN for secure networking
    thunar # Lightweight file manager for Hyprland
    thunar-archive-plugin # Archive support for Thunar
    tlp # Power management tool for laptops
    vim # Highly configurable text editor
    waybar # Customizable status bar for Hyprland
    wget # Command-line tool for downloading files
    yazi # Terminal-based file manager
    zen-browser # Privacy-focused web browser based on Firefox
  ];

  # Programs configuration
  programs = {
    zsh.enable = true;
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "/home/joe/wtf";
    };
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    nix-index-database.comma.enable = true;
  };

  fileSystems."/mnt/NAS" = {
    device = "//${config.sops.secrets.tailnet_name.path}/data";
    fsType = "cifs";
    options = ["credentials=/etc/samba/credentials" "uid=joe" "gid=users" "dir_mode=0775" "file_mode=0664" "vers=3.0" "x-systemd.automount" "nofail"];
  };

  fileSystems."/mnt/NAS-joe" = {
    device = "//${config.sops.secrets.tailnet_name.path}/joe";
    fsType = "cifs";
    options = ["credentials=/etc/samba/credentials" "uid=joe" "gid=users" "dir_mode=0775" "file_mode=0664" "vers=3.0" "x-systemd.automount" "nofail"];
  };

  system.stateVersion = "25.05"; # Align with latest stable release
}
