{
  config,
  pkgs,
  lib,
  ...
}: {
  home-manager.users.joe = {
    programs.bottom = {
      enable = true;
      package = pkgs.bottom;
      enableZshIntegration = true;
    };

    xdg.configFile."bottom/bottom.toml".source = ./bottom.toml;
  };
}
