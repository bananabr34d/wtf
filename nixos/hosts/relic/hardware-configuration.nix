{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/<root-uuid>";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/<boot-uuid>";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/<root-uuid>";
    fsType = "btrfs";
    options = ["subvol=@home"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/<root-uuid>";
    fsType = "btrfs";
    options = ["subvol=@nix"];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/<root-uuid>";
    fsType = "btrfs";
    options = ["subvol=@var/log"];
  };

  fileSystems."/var/lib" = {
    device = "/dev/disk/by-uuid/<root-uuid>";
    fsType = "btrfs";
    options = ["subvol=@var/lib"];
  };

  fileSystems."/tmp" = {
    device = "/dev/disk/by-uuid/<root-uuid>";
    fsType = "btrfs";
    options = ["subvol=@tmp"];
  };

  fileSystems."/home/joe/.local/share" = {
    device = "/dev/disk/by-uuid/<root-uuid>";
    fsType = "btrfs";
    options = ["subvol=@home/joe/.local/share"];
  };

  boot.initrd.luks.devices."crypted" = {
    device = "/dev/disk/by-uuid/<luks-uuid>";
  };

  swapDevices = [];

  # Enable Intel CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # Networking (Intel WiFi)
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  # Hardware-specific settings
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
