{
  config,
  pkgs,
  ...
}: {
  home-manager.users.joe = {
    home.packages = with pkgs; [
      homebrew
    ];

    homebrew = {
      enable = true;
      brews = [
        "spotify"
      ];
    };
  };
}
