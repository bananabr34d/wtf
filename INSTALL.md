# Installation Instructions for Dell XPS 13 9350 (`relic`)

This document provides detailed steps for installing the NixOS configuration on the Dell XPS 13 9350 (`relic`) using the flake from the GitHub repository. The configuration includes a LUKS-encrypted BTRFS disk layout, Hyprland desktop environment, and various user tools for `joe`.

## Prerequisites
- A USB drive with at least 8GB capacity.
- Access to another computer to create the bootable USB.
- Your Dell XPS 13 9350 (`relic`) with a compatible disk (e.g., `/dev/nvme0n1`).
- Internet access for downloading NixOS ISO and fetching packages.
- Your Tailscale auth key and Samba credentials for `secrets.yaml`.
- A strong LUKS passphrase (20+ characters, mixed case, numbers, symbols) for disk encryption.

## Step-by-Step Instructions

1. **Download and Create NixOS Live USB**:
   - Download the NixOS 25.05 minimal ISO from [nixos.org](https://nixos.org/download.html).
   - On another computer, create a bootable USB:
     - **Linux/macOS**: Use `dd`:
       ```bash
       sudo dd if=nixos-minimal-25.05-x86_64-linux.iso of=/dev/sdX bs=4M status=progress && sync
       ```
       Replace `/dev/sdX` with your USB device (check with `lsblk`).
     - **Windows**: Use Rufus to flash the ISO to the USB.
   - Insert the USB into the XPS 13 9350 (`relic`).

2. **Boot into NixOS Live Environment**:
   - Power on the XPS 13 9350 and enter the BIOS/UEFI (usually `F2` or `F12` at boot).
   - Set the USB as the primary boot device and disable Secure Boot (if enabled, as it may interfere with NixOS).
   - Boot into the NixOS live environment and log in (user: `nixos`, no password).

3. **Clone the `wtf` Repository**:
   - In the live environment terminal, clone the `wtf` repository to `~/wtf`:
     ```bash
     git clone https://github.com/username/wtf ~/wtf
     ```
     Replace `https://github.com/username/wtf` with the actual repository URL if different.
   - Navigate into the `wtf` directory:
     ```bash
     cd ~/wtf
     ```

4. **Enable Experimental Features**:
   - In the terminal:
     ```bash
     export NIX_CONFIG="experimental-features = nix-command flakes"
     ```

5. **Partition and Format the Disk**:
   - Identify the XPS 13 9350’s disk:
     ```bash
     lsblk
     ```
     - Likely `/dev/nvme0n1` for NVMe SSDs or `/dev/sda` for SATA.
   - Run Disko to partition, format, and mount the disk using `nixos/hosts/relic/disko-config.nix`. You will be prompted to enter a LUKS passphrase:
     ```bash
     sudo nix run github:nix-community/disko -- --mode disko nixos/hosts/relic/disko-config.nix
     ```
     Example `disko-config.nix`:
     ```nix
     {
       disko.devices = {
         disk = {
           nvme0n1 = {
             type = "disk";
             device = "/dev/nvme0n1";
             content = {
               type = "gpt";
               partitions = {
                 ESP = {
                   size = "1G";
                   type = "EF00";
                   content = {
                     type = "filesystem";
                     format = "vfat";
                     mountpoint = "/boot";
                   };
                 };
                 luks = {
                   size = "100%";
                   content = {
                     type = "luks";
                     name = "crypted";
                     settings = {
                       allowDiscards = true;
                     };
                     content = {
                       type = "btrfs";
                       extraArgs = [ "-f" ];
                       subvolumes = {
                         "/@" = {
                           mountpoint = "/";
                           mountOptions = [ "compress=zstd" "noatime" ];
                         };
                         "/@home" = {
                           mountpoint = "/home";
                           mountOptions = [ "compress=zstd" "noatime" ];
                         };
                         "/@nix" = {
                           mountpoint = "/nix";
                           mountOptions = [ "compress=zstd" "noatime" ];
                         };
                         "/@var/log" = {
                           mountpoint = "/var/log";
                           mountOptions = [ "compress=zstd" "noatime" ];
                         };
                         "/@var/lib" = {
                           mountpoint = "/var/lib";
                           mountOptions = [ "compress=zstd" "noatime" ];
                         };
                         "/@tmp" = {
                           mountpoint = "/tmp";
                           mountOptions = [ "compress=zstd" "noatime" ];
                         };
                         "/@home/joe/.local/share" = {
                           mountpoint = "/home/joe/.local/share";
                           mountOptions = [ "compress=zstd" "noatime" ];
                         };
                       };
                     };
                   };
                 };
               };
             };
           };
         };
       };
     }
     ```
   - Verify mounts:
     ```bash
     lsblk
     mount | grep /mnt
     ```
     - Ensure `/mnt`, `/mnt/boot`, `/mnt/home`, `/mnt/nix`, `/mnt/var/log`, `/mnt/var/lib`, `/mnt/tmp`, `/mnt/home/joe/.local/share` are mounted.

6. **Copy the `wtf` Repository**:
   - Copy the `wtf` repository to `/mnt/home/joe/wtf/`:
     ```bash
     sudo mkdir -p /mnt/home/joe/wtf
     sudo cp -r . /mnt/home/joe/wtf/
     sudo chown -R joe:users /mnt/home/joe
     ```

7. **Set Up SOPS and Secrets**:
   - Install `sops` and `age`:
     ```bash
     nix-shell -p sops age
     ```
   - Generate an age key pair:
     ```bash
     mkdir -p ~/.config/sops/age
     age-keygen -o ~/.config/sops/age/keys.txt
     ```
   - Copy the public key from `~/.config/sops/age/keys.txt` (starts with `age1...`).
   - Navigate to `/mnt/home/joe/wtf`:
     ```bash
     cd /mnt/home/joe/wtf
     ```
   - Update `.sops.yaml` with the public key. Example:
     ```yaml
     keys:
       - &joe age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     creation_rules:
       - path_regex: .*
         key_groups:
           - age:
               - *joe
     ```
   - Edit `secrets.yaml` to include `joe_password`, `cifs-credentials`, `tailscale_auth_key`, `tailnet_name`:
     ```bash
     sops secrets.yaml
     ```
     Example:
     ```yaml
     joe_password: ENC[...]
     cifs-credentials: |
       username=<your-username>
       password=<your-password>
     tailscale_auth_key: <your-auth-key>
     tailnet_name: <your-tailnet>.ts.net
     ```

8. **Generate and Configure Hardware Configuration**:
   - Generate `hardware-configuration.nix`:
     ```bash
     nixos-generate-config --root /mnt
     mv /mnt/etc/nixos/hardware-configuration.nix nixos/hosts/relic/
     ```
   - Verify `nixos/hosts/relic/hardware-configuration.nix` includes the LUKS device:
     ```bash
     bat nixos/hosts/relic/hardware-configuration.nix
     ```
     Ensure the `boot.initrd.luks.devices."crypted"` block does not specify a `keyFile`.

9. **Install NixOS**:
   - Run:
     ```bash
     sudo nixos-install --flake .#relic
     ```
   - Set a temporary root password when prompted (you’ll replace it with `joe_password` from SOPS later).

10. **Test Installation with `nixos-enter`**:
    - Enter the installed system’s environment:
      ```bash
      sudo nixos-enter
      ```
    - Test LUKS unlocking:
      ```bash
      cryptsetup luksOpen /dev/disk/by-uuid/<luks-uuid> crypted
      mount | grep crypted
      ```
      Replace `<luks-uuid>` with the UUID from `lsblk -f`, and enter the LUKS passphrase when prompted.
    - Test user login and basic functionality:
      ```bash
      su - joe
      cd ~/wtf
      bat ~/.config/hypr/hyprland.conf
      bat ~/.config/yazi/yazi.toml
      snapper list
      ```
    - Exit the chroot:
      ```bash
      exit
      ```

11. **Set Up Hyprland and Yazi**:
    - Reboot and log in as `joe`. Enter the LUKS passphrase when prompted.
    - Navigate to `~/wtf`:
      ```bash
      cd ~/wtf
      ```
    - Verify configurations:
      ```bash
      bat ~/.config/hypr/hyprland.conf
      bat ~/.config/yazi/yazi.toml
      bat ~/.config/yazi/theme.toml
      bat ~/.config/waybar/config.jsonc
      bat ~/.config/waybar/style.css
      bat ~/.config/swaync/config.json
      bat ~/.config/swaync/style.css
      bat ~/.config/fuzzel/fuzzel.ini
      bat ~/.config/kitty/kitty.conf
      bat ~/.config/emojis.txt
      bat ~/.config/emoji-picker.sh
      swaync-client -t
      fuzzel  # Launch Fuzzel (SUPER+R)
      kitty -e yazi  # Launch Yazi (SUPER+Y), check emoji icons
      ```

12. **Post-Install Verification**:
    - Update the system:
      ```bash
      sudo nixos-rebuild switch --flake .#relic
      home-manager switch -b backup --flake .#joe@relic
      ```
    - Verify Snapper:
      ```bash
      snapper list
      ls /home/.snapshots /var/log/.snapshots /var/lib/.snapshots /tmp/.snapshots /home/joe/.local/share/.snapshots
      ```
    - Verify terminal applications, fonts, and emojis:
      ```bash
      tldr tar              # Simplified tar examples
      rg "pattern" .        # Search for pattern in flake
      fd file ~/Documents   # Find files in Documents
      htop                  # View processes
      btm                   # View system monitor (bottom)
      br                    # Launch broot
      nvim ~/org/notes.org  # Launch Neovim with Org Mode
      nvim ~/zettel/test.md  # Launch Neovim with Zettelkasten
      fuzzel                # Launch Fuzzel (SUPER+R)
      ~/.config/emoji-picker.sh  # Launch emoji picker (SUPER+I), paste emoji in Neovim
      bemoji                # Test bemoji for additional emoji selection
      kitty -e yazi         # Launch Yazi, verify emoji icons (e.g., 📄 for text, 📁 for directories)
      spotify               # Launch desktop app
      fc-list | grep Hack   # Verify Hack Nerd Font installation
      ```
    - Test emoji rendering in Yazi:
      ```bash
      kitty -e yazi ~/Documents
      # Verify icons: 📄 for .txt, 📷 for .jpg, 📝 for .md, 📁 for directories
      ```
    - Test emoji insertion:
      ```bash
      kitty -e yazi ~/org
      # Open notes.org in Neovim from Yazi, insert emoji via SUPER+I
      ```

13. **Back Up Secrets and Verify LUKS Passphrase**:
    - Back up `~/.config/sops/age/keys.txt` and SSH keys (`~/.ssh/id_ed25519`) using secure methods (e.g., encrypted USB, Syncthing, password manager, or encrypted cloud storage).
    - Verify the LUKS passphrase works by rebooting and entering it at the boot prompt.
    - Optionally, add a new LUKS passphrase or key file:
      ```bash
      sudo cryptsetup luksAddKey /dev/nvme0n1p2
      ```
      Follow prompts to enter the existing passphrase and add a new one.
    - If adding a key file, update `nixos/hosts/relic/hardware-configuration.nix` to include `keyFile` and rebuild:
      ```bash
      sudo nano nixos/hosts/relic/hardware-configuration.nix
      sudo nixos-rebuild switch --flake .#relic
      ```
