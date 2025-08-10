# CHANGELOG

## August 09, 2025
- **10:41 AM CDT**: Updated `nixos/hosts/relic/disko-config.nix` to set `luks.content.settings.allowDiscards = true` for SSD TRIM support and added `mountOptions = [ "compress=zstd" "noatime" ]` to BTRFS subvolumes for performance and space efficiency. Updated `INSTALL.md` to reflect the new `disko-config.nix`. (Ref: `disko-config.nix`, `INSTALL.md`)
- **9:39 AM CDT**: Updated `INSTALL.md` to use a LUKS passphrase prompt instead of a temporary key file (`/tmp/secret.key`), removed key file creation and copying steps, updated `disko-config.nix` to exclude `keyFile`, and adjusted LUKS key management steps to focus on passphrase verification. (Ref: `INSTALL.md`)
- **6:22 AM CDT**: Updated `INSTALL.md` to persist the temporary LUKS key file to `/mnt/boot/secret.key`, configure `hardware-configuration.nix` to use it, add `nixos-enter` testing step, and recommend updating the LUKS key post-installation. (Ref: `INSTALL.md`)
- **5:49 AM CDT**: Updated `INSTALL.md` to include cloning the repository in the live environment, copying to /mnt/home/joe/wtf, and performing SOPS and other steps in /mnt/home/joe/wtf for persistence. (Ref: `INSTALL.md`)

## August 08, 2025
- **8:20 PM CDT**: Moved installation steps for `relic` from `README.md` to `INSTALL.md`, added reference to `INSTALL.md` in `README.md`, and updated directory structure to include `INSTALL.md`. (Ref: `README.md`, `INSTALL.md`)
- **8:17 PM CDT**: Updated `README.md` to remove `starship.toml` from directory structure and file descriptions, reflecting its replacement by `starship.nix` settings. (Ref: `starship.nix`)
- **8:08 PM CDT**: Updated `home/desktops/hyprland/hyprland.nix` to source `swaync/config.json` and `swaync/style.css` via `xdg.configFile`, ensuring SwayNC’s notification setup with dark theme is applied. (Ref: `hyprland.nix`, `swaync/config.json`, `swaync/style.css`)
- **8:05 PM CDT**: Updated `home/desktops/hyprland/hyprland.nix` to source `waybar/config.jsonc` and `waybar/style.css` via `xdg.configFile`, ensuring Waybar’s dual-monitor setup and dark theme are applied. (Ref: `hyprland.nix`, `waybar/config.jsonc`, `waybar/style.css`)
- **8:01 PM CDT**: Added `home/programs/thunar/thunarrc`, confirming it sets the `Adwaita-dark` theme and is correctly sourced via `thunar.nix`. (Ref: `thunarrc`)
- **7:55 PM CDT**: Updated `home/programs/starship/starship.nix` to remove redundant `xdg.configFile` sourcing of `starship.toml`, relying on `programs.starship.settings` for configuration, and removed `starship.toml` from the directory structure. (Ref: `starship.nix`)
- **7:54 PM CDT**: Added `home/programs/bottom/bottom.nix` and `bottom.toml`, verified that `bottom.toml` is correctly sourced via `xdg.configFile` in `bottom.nix`, and included `enableZshIntegration = true` for Zsh completions. (Ref: `bottom.nix`, `bottom.toml`)
- **7:53 PM CDT**: Updated `home/programs/broot/broot.nix` to include `enableZshIntegration = true`, enabling Zsh completion and the `broot` function for directory navigation, consistent with other tools like Yazi. (Ref: `broot.nix`)
- **7:51 PM CDT**: Verified that `home-manager.users.joe` in `home/programs/broot/broot.nix` is necessary and not redundant, as it scopes Broot settings to user `joe`, consistent with other submodules. (Ref: `broot.nix`)
- **7:49 PM CDT**: Added `home/programs/broot/broot.nix` and `conf.toml`, verified that `conf.toml` is correctly sourced via `xdg.configFile` in `broot.nix`. (Ref: `broot.nix`, `conf.toml`)
- **7:48 PM CDT**: Updated `home/programs/yazi/yazi.nix` to include `enableZshIntegration = true`, enabling the `y` command for directory navigation in Zsh. (Ref: `yazi.nix`)
- **7:45 PM CDT**: Added `home/programs/yazi/yazi.nix` and `yazi.toml`, verified that `yazi.toml` and `theme.toml` are correctly sourced via `xdg.configFile` in `yazi.nix`. (Ref: `yazi.nix`, `yazi.toml`, `theme.toml`)
- **7:42 PM CDT**: Confirmed `home/desktops/hyprland/hyprland.nix` as the latest version, correctly imported in `home/home.nix` for complete Home-Manager setup. (Ref: `hyprland.nix`)
- **6:38 PM CDT**: Updated `relic/configuration.nix` to import `hardware-configuration.nix`, ensuring hardware settings are included for Dell XPS 13 9350. (Ref: `relic/configuration.nix`)
- **6:36 PM CDT**: Added `hardware-configuration.nix` for `relic` (Dell XPS 13 9350), aligning with `disko-config.nix` and `nixos-hardware.nixosModules.dell-xps-13-9350`. (Ref: `hardware-configuration.nix`)
- **6:34 PM CDT**: Removed `common.nix` import from `relic/configuration.nix` and defined `nixos/default.nix` to avoid redundant imports, ensuring `common.nix` is only included via `flake.nix`. (Ref: `relic/configuration.nix`, `default.nix`)
- **6:31 PM CDT**: Updated `nixos/services/caddy.nix` to use SOPS secret for `tailnet_name` instead of hardcoded value, improving security. (Ref: `caddy.nix`)
- **5:44 PM CDT**: Updated `README.md` to clarify `flake.nix` is local to `~/wtf` and not on `x.ai/grok`, emphasized Yazi emoji support. (Ref: `README.md`)

## August 06, 2025
- **8:12 PM CDT**: Moved Thunar and Starship to `home/programs/`, added Homebrew for Spotify on `silicon`, updated `README.md` with specific Disko commands. (Ref: `README.md`, `thunar.nix`, `starship.nix`, `brew.nix`)