{
  config,
  pkgs,
  ...
}: {
  home-manager.users.joe = {
    home.packages = with pkgs; [
      thunar
      thunar-archive-plugin
    ];

    xdg.configFile."Thunar/thunarrc".source = ./thunarrc;
  };
}
