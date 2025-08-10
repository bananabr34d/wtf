{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/<disk>";
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
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/@" = { mountpoint = "/"; };
                    "/@home" = { mountpoint = "/home"; };
                    "/@nix" = { mountpoint = "/nix"; };
                    "/@var/log" = { mountpoint = "/var/log"; };
                    "/@var/lib" = { mountpoint = "/var/lib"; };
                    "/@tmp" = { mountpoint = "/tmp"; };
                    "/@home/joe/.local/share" = { mountpoint = "/home/joe/.local/share"; };
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
