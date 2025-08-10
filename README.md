# NixOS Flake Configuration for Multiple Systems

This flake defines NixOS, Nix-Darwin, and Home Manager configurations for multiple systems, including a Lenovo Carbon X1 laptop (`carbon`), a Beelink GTR5 mini desktop (`hydrogen`), a Mac Mini M4 (`silicon`), and test machines for a VM (`ether`) and a Dell XPS 13 9350 laptop (`relic`). It uses LUKS-encrypted BTRFS with subvolumes, Hyprland as the desktop environment on NixOS, and SOPS for secrets management. The configuration includes a minimal set of packages, SSH for remote access, power management for laptops, printing support, Tailscale for secure networking, Caddy for Syncthing access, Samba for network share mounts, Snapper for BTRFS snapshots, and Thunar/Yazi for file management with dark theming. The flake is located in `~/wtf`. See `CHANGELOG.md` for the project change history.

## System Overview

| Hostname   | Board                     | CPU                    | RAM   | GPU                     | OS    | Role          | Desktop  |
|------------|---------------------------|------------------------|-------|-------------------------|-------|---------------|----------|
| carbon     | ThinkPad X1               | Intel Core i7-1165G7   | 16GB  | Intel Iris Xe Graphics  | NixOS | Laptop        | Hyprland |
| hydrogen   | Beelink GTR5              | AMD Ryzen 9 5900HX     | 32GB  | Radeon Graphics (integrated) | NixOS | Desktop       | Hyprland |
| silicon    | Mac Mini M4               | Apple M4               | 16GB  | 10-core GPU             | Darwin | Desktop       | macOS    |
| ether      | Virtual Machine (QEMU)    | Virtual (2 cores)      | 2GB   | VirtIO (QEMU)           | NixOS | Test VM       | Hyprland |
| relic      | Dell XPS 13 9350          | Intel Core i5-6200U / i7-6500U | 4GB / 8GB | Intel HD Graphics 520 / Iris Graphics 540 | NixOS | Test Laptop   | Hyprland |

### Common Settings
- **Disk Layout** (NixOS only):
  - 1GB EFI boot partition (`/boot`, FAT32)
  - LUKS-encrypted BTRFS partition with subvolumes: `/` (root), `/home`, `/nix`, `/var/log`, `/var/lib`, `/tmp`, `/home/joe/.local/share`
- **Snapshots** (NixOS only): Snapper enabled for subvolumes with hourly snapshots, cleanup (10 hourly, 7 daily, 4 weekly, 2 monthly for most; 10 hourly, 7 daily for `/tmp`), and bootable snapshot entries via systemd-boot.
- **Desktop Environment** (NixOS only): Hyprland with Waybar, SwayNC, Fuzzel, Kitty, Hyprpaper (wallpaper), Hyprlock (screen lock), Hyprpicker (color picker), and Hyprshot (screenshot). Keybindings: `brave` (`SUPER+F`), SwayNC toggle (`SUPER+N`), lock screen (`SUPER+L`), color picker (`SUPER+P`), screenshot (`Print`), Thunar (`SUPER+E`), Yazi (`SUPER+Y`), emoji picker (`SUPER+I`) in `home/desktops/hyprland/hyprland.nix`. Waybar configured for auto-detected monitors with semi-transparent background (`#1e1e2ecc`) via `home/desktops/hyprland/waybar/config.jsonc` and `style.css` (dark theme, `#1e1e2e` base, `#cba6f7` accents). SwayNC configured for notifications via `home/desktops/hyprland/swaync/config.json` and `style.css`. Hyprpaper, Hyprlock, Fuzzel, and Kitty configured via `home/desktops/hyprland/hyprpaper.conf`, `hyprlock.conf`, `fuzzel.ini`, and `kitty.conf`.
- **File Managers** (NixOS only): Thunar (GUI, `Adwaita-dark` theme, configured in `home/programs/thunar/thunar.nix`) and Yazi (terminal-based, Catppuccin Mocha theme with emoji icons for filetypes).
- **Music** (NixOS only): Spotify desktop app for full-featured music streaming.
- **Music** (Darwin): Spotify desktop app installed via Homebrew (`home/programs/brew/brew.nix`).
- **Editor** (all hosts): Neovim with `nixvim`, including plugins `nvim-orgmode` (Org Mode support), `org-bullets.nvim` (visual bullets), `nvim-cmp` (autocompletion), `telescope.nvim` (fuzzy finding), `nvim-treesitter` (syntax highlighting), and `zettelkasten.nvim` (Zettelkasten note-taking).
- **Fonts** (all hosts): Hack Nerd Font used for Fuzzel, Waybar, Kitty, and Starship, with DejaVu fonts as fallbacks, configured in `home/fonts.nix`. Font cache refreshed via `home.activation`.
- **Emoji Support** (NixOS only): Curated emoji list (`home/desktops/emojis.txt`) and Fuzzel-based emoji picker (`home/desktops/emoji-picker.sh`) with `bemoji` for additional emoji selection, integrated via `SUPER+I` keybinding. Yazi uses emoji icons for filetypes in `home/programs/yazi/theme.toml`.
- **User**: `joe` (Zsh shell, `lp` group for printing on NixOS)
- **Standard Directories**: Created via `xdg.userDirs` for `Desktop`, `Documents`, `Downloads`, `Music`, `Pictures`, `Public`, `Templates`, `Videos` on all hosts.
- **Packages**:
  - **NixOS**: `bemoji`, `brave`, `caddy`, `curl`, `fastfetch`, `fuzzel`, `git`, `hyprland`, `hyprlock`, `hyprpaper`, `hyprpicker`, `hyprshot`, `kitty`, `openssh`, `snapper`, `spotify`, `swaync`, `system-config-printer`, `tailscale`, `thunar`, `thunar-archive-plugin`, `tlp`, `vim`, `waybar`, `wget`, `yazi`, `zen-browser` (alphabetically listed in `nixos/common.nix`)
  - **Darwin**: `caddy`, `git`, `tailscale`, `vim` (in `darwin/common.nix`)
  - **User**: `bat`, `bottom`, `broot`, `direnv`, `eza`, `fd`, `fzf`, `gh`, `htop`, `lazygit`, `neovim`, `ripgrep`, `starship`, `tealdeer`, `tmux`, `trayscale`, `zsh` (in `home.nix`)
- **Secrets Management**:
  - **System**: SOPS with age encryption for `joe_password`, `cifs-credentials` (NixOS), `tailscale_auth_key`, and `tailnet_name` (in `/etc/tailscale/` for NixOS, `~/.config/tailscale/` for Darwin)
  - **Home Manager**: SOPS for `joe_ssh_key` (`~/.ssh/id_ed25519`) and `tailnet_name` (`~/.config/tailscale/`)
- **Services**: OpenSSH (key-based, NixOS only), NetworkManager, PipeWire, CUPS (printing), Avahi (printer discovery), Tailscale (VPN with SSH, `hydrogen` as exit node), Caddy (Syncthing reverse proxy), Syncthing (user service, syncs `Documents`, `Pictures`)
- **Timezone**: America/Chicago
- **Locale** (NixOS only): `en_US.UTF-8` with additional locale settings
- **Keyboard** (NixOS only): XKB with US layout for X and Hyprland
- **Power Management** (NixOS only): TLP with ThinkPad/XPS-specific charge thresholds on `carbon`, `relic`
- **State Version**: `25.05` (NixOS), `4` (Darwin)
- **Helper Functions**: `lib/default.nix` imports `lib/helper.nix` with `mkNixos`, `mkHome`, `mkDarwin`
- **SSH Client**: Configured in `home/home.nix` with aliases for `carbon`, `hydrogen` using Tailscale MagicDNS
- **Zsh**: Integrated with `zoxide`, `starship`, `fzf`, `direnv`, `tealdeer`, `ripgrep`, `fd`, `broot`, `bottom`; dotfiles in `~/.config/zsh`
- **Git Tools**: `gh`, `lazygit`
- **Tailscale**: MagicDNS, SSH, `hydrogen` as exit node, TrayScale GUI (NixOS only), stable `nixos-unstable` channel
- **Caddy**: Syncthing reverse proxy at `https://<hostname>.<tailnet>/syncthing/` (all hosts)
- **Samba Mounts** (NixOS only): Automounted CIFS shares from `<tailnet>/data` and `<tailnet>/joe` at `/mnt/NAS` and `/mnt/NAS-joe`
- **Flake Note**: The `flake.nix` file is local to the `~/wtf` directory and defines the configuration for all hosts. It is not hosted on the Grok website (`x.ai/grok`), which focuses on AI services and API documentation (`https://x.ai/api`).

## Installation
For detailed instructions on installing this configuration on the Dell XPS 13 9350 (`relic`), see [INSTALL.md](./INSTALL.md).

## Files
All files are located in `~/wtf`.

```
~/wtf
├── CHANGELOG.md
├── flake.nix
├── INSTALL.md
├── .sops.yaml
├── secrets.yaml
├── nixos/
│   ├── default.nix
│   ├── common.nix
│   ├── services/
│   │   └── caddy.nix
│   ├── hosts/
│   │   ├── carbon/
│   │   │   ├── configuration.nix
│   │   │   ├── disko-config.nix
│   │   │   └── hardware-configuration.nix
│   │   ├── hydrogen/
│   │   │   ├── configuration.nix
│   │   │   ├── disko-config.nix
│   │   │   └── hardware-configuration.nix
│   │   ├── ether/
│   │   │   ├── configuration.nix
│   │   │   ├── disko-config.nix
│   │   │   └── hardware-configuration.nix
│   │   ├── relic/
│   │   │   ├── configuration.nix
│   │   │   ├── disko-config.nix
│   │   │   └── hardware-configuration.nix
├── darwin/
│   ├── common.nix
│   ├── hosts/
│   │   ├── silicon/
│   │   │   └── configuration.nix
├── home/
│   ├── default.nix
│   ├── home.nix
│   ├── services.nix
│   ├── fonts.nix
│   ├── desktops/
│   │   ├── hyprland/
│   │   │   ├── hyprland.nix
│   │   │   ├── waybar/
│   │   │   │   ├── config.jsonc
│   │   │   │   ├── style.css
│   │   │   ├── swaync/
│   │   │   │   ├── config.json
│   │   │   │   ├── style.css
│   │   │   ├── hyprpaper.conf
│   │   │   ├── hyprlock.conf
│   │   │   ├── fuzzel.ini
│   │   │   ├── kitty.conf
│   │   │   ├── emoji-picker.sh
│   │   │   ├── emojis.txt
│   ├── programs/
│   │   ├── yazi/
│   │   │   ├── yazi.nix
│   │   │   ├── yazi.toml
│   │   │   ├── theme.toml
│   │   ├── broot/
│   │   │   ├── broot.nix
│   │   │   ├── conf.toml
│   │   ├── bottom/
│   │   │   ├── bottom.nix
│   │   │   ├── bottom.toml
│   │   ├── thunar/
│   │   │   ├── thunar.nix
│   │   │   ├── thunarrc
│   │   ├── starship/
│   │   │   ├── starship.nix
│   │   ├── brew/
│   │   │   ├── brew.nix
├── lib/
│   ├── default.nix
│   ├── helper.nix
```

- `flake.nix`: Defines inputs (`nixpkgs`, `unstable`, `darwin`, `disko`, `home-manager`, `hyprland`, `sops-nix`, `nixos-hardware`, `snapper`) and outputs (`nixosConfigurations`, `darwinConfigurations`, `homeConfigurations`) using `lib/default.nix`. Enables `allowUnfree` for Spotify.
- `INSTALL.md`: Detailed installation instructions for setting up the configuration on `relic`.
- `nixos/default.nix`: Imports host configurations.
- `nixos/common.nix`: Shared settings for NixOS (user, SOPS, locale, SSH, Hyprland, printing, keyboard, packages including `bemoji`, Fuzzel, Tailscale, Caddy, Samba, Snapper with simplified subvolume configs).
- `nixos/services/caddy.nix`: Caddy configuration for Syncthing reverse proxy.
- `nixos/hosts/*/configuration.nix`: Host-specific settings for `carbon`, `hydrogen`, `ether`, `relic`.
- `nixos/hosts/*/disko-config.nix`: Disk configurations with LUKS-encrypted BTRFS subvolumes.
- `nixos/hosts/*/hardware-configuration.nix`: Hardware-specific settings for each host.
- `darwin/common.nix`: Shared settings for Darwin (user, SOPS, packages, Tailscale, Caddy, Homebrew).
- `darwin/hosts/silicon/configuration.nix`: Host-specific settings for `silicon`.
- `home/default.nix`: Imports `home/home.nix`.
- `home/home.nix`: Home Manager configuration for `joe` (SOPS, SSH, `nixvim`, Thunar, Yazi, Broot, Bottom, Starship, Brew, emoji list, standard directories).
- `home/services.nix`: User services (Syncthing).
- `home/fonts.nix`: Font and theme configs (`fontconfig`, `gtk` with `Adwaita-dark`, `qt`, `xdg`, Hack Nerd Font with font cache refresh).
- `home/desktops/hyprland/hyprland.nix`: Hyprland configuration with monitor settings via a hostname-based lookup table, Fuzzel, and emoji picker keybindings.
- `home/desktops/hyprland/waybar/*`: Waybar configuration for auto-detected monitors (dark theme).
- `home/desktops/hyprland/swaync/*`: SwayNC notification setup (dark theme).
- `home/desktops/hyprland/hyprpaper.conf`: Wallpaper config.
- `home/desktops/hyprland/hyprlock.conf`: Screen lock config.
- `home/desktops/hyprland/fuzzel.ini`: Fuzzel configuration with Catppuccin Mocha theming and Hack Nerd Font.
- `home/desktops/hyprland/kitty.conf`: Kitty configuration with Hack Nerd Font and Catppuccin Mocha theming.
- `home/desktops/hyprland/emoji-picker.sh`: Fuzzel-based emoji picker script using `emojis.txt`.
- `home/desktops/hyprland/emojis.txt`: Curated emoji list for documentation and note-taking.
- `home/programs/thunar/thunar.nix`: Thunar GUI file manager settings with `Adwaita-dark` theme.
- `home/programs/thunar/thunarrc`: Thunar configuration.
- `home/programs/starship/starship.nix`: Starship prompt configuration with Nerd Font symbols.
- `home/programs/brew/brew.nix`: Homebrew configuration for Spotify on `silicon`.
- `home/programs/yazi/yazi.nix`: Yazi configuration module.
- `home/programs/yazi/yazi.toml`: Yazi settings with emoji prompt and Starship plugin.
- `home/programs/yazi/theme.toml`: Yazi theme with emoji icons for filetypes and Catppuccin Mocha colors.
- `home/programs/broot/broot.nix`: Broot terminal-based file explorer (dark theme).
- `home/programs/broot/conf.toml`: Broot configuration (dark theme).
- `home/programs/bottom/bottom.nix`: Bottom system monitor (dark theme).
- `home/programs/bottom/bottom.toml`: Bottom configuration (dark theme).
- `lib/default.nix`: Imports `lib/helper.nix`.
- `lib/helper.nix`: Helper functions (`mkNixos`, `mkHome`, `mkDarwin`).
- `.sops.yaml`: SOPS configuration for `secrets.yaml`.
- `secrets.yaml`: Encrypted secrets (`joe_password`, `joe_ssh_key`, `cifs-credentials`, `tailscale_auth_key`, `tailnet_name`).