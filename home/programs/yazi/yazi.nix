{
  config,
  pkgs,
  lib,
  ...
}: {
  home-manager.users.joe = {
    programs.yazi = {
      enable = true;
      package = pkgs.yazi;
      enableZshIntegration = true;
    };

    xdg.configFile = {
      "yazi/yazi.toml".source = ./yazi.toml;
      "yazi/theme.toml".source = ./theme.toml;
    };
  };
}
