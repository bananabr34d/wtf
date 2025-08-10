{
  config,
  pkgs,
  ...
}: {
  home-manager.users.joe = {
    programs.starship = {
      enable = true;
      settings = {
        format = "$all";
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
    xdg.configFile."starship.toml".source = ./starship.toml;
  };
}
