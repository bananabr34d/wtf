{
  config,
  pkgs,
  lib,
  ...
}: {
  home-manager.users.joe = {
    programs.broot = {
      enable = true;
      package = pkgs.broot;
      enableZshIntegration = true;
    };

    xdg.configFile."broot/conf.toml".source = ./conf.toml;
  };
}
