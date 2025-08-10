{
  config,
  pkgs,
  ...
}: {
  home-manager.users.joe = {
    home.packages = with pkgs; [
      bat # Modern cat alternative with syntax highlighting
      bottom # Interactive process viewer
      broot # Interactive directory navigation tool
      direnv # Per-directory shell configuration
      eza # Modern ls alternative
      fd # User-friendly find alternative
      fzf # Fuzzy finder
      gh # GitHub CLI
      htop # Interactive process viewer
      lazygit # Git TUI
      neovim # Text editor
      ripgrep # Fast grep alternative
      starship # Shell prompt
      tealdeer # Simplified man pages
      tmux # Terminal multiplexer
      trayscale # Tailscale GUI
      zsh # Z shell
    ];

    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      initExtra = ''
        source ${pkgs.zsh}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zoxide}/share/zoxide/zoxide.zsh
        eval "$(starship init zsh)"
        alias cat='bat'
      '';
    };

    imports = [
      ./services.nix
      ./fonts.nix
      ./desktops/hyprland/hyprland.nix
      ./programs/yazi/yazi.nix
      ./programs/broot/broot.nix
      ./programs/bottom/bottom.nix
      ./programs/thunar/thunar.nix
      ./programs/starship/starship.nix
      ./programs/brew/brew.nix
    ];

    programs.nixvim = {
      enable = true;
      plugins = {
        nvim-orgmode.enable = true;
        org-bullets.enable = true;
        nvim-cmp.enable = true;
        telescope.enable = true;
        treesitter.enable = true;
        zettelkasten.enable = true;
      };
    };

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      publicShare = "$HOME/Public";
      templates = "$HOME/Templates";
      videos = "$HOME/Videos";
    };

    services.syncthing.enable = true;

    home.file.".ssh/id_ed25519".source = config.sops.secrets.joe_ssh_key.path;
    sops = {
      age.keyFile = "/home/joe/.config/sops/age/keys.txt";
      defaultSopsFile = ./secrets.yaml;
      secrets = {
        joe_ssh_key = {};
        tailnet_name = {
          path = "/home/joe/.config/tailscale/tailnet_name";
        };
      };
    };

    home.stateVersion = "25.05";
  };
}
