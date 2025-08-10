{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fontconfig
    (nerdfonts.override {fonts = ["Hack"];}) # Install Hack Nerd Font
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  xdg.configFile."fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <dir>~/.local/share/fonts</dir>
      <alias>
        <family>serif</family>
        <prefer><family>DejaVu Serif</family></prefer>
      </alias>
      <alias>
        <family>sans-serif</family>
        <prefer><family>DejaVu Sans</family></prefer>
      </alias>
      <alias>
        <family>monospace</family>
        <prefer><family>Hack Nerd Font</family><family>DejaVu Sans Mono</family></prefer>
      </alias>
    </fontconfig>
  '';

  home.activation = {
    refreshFontCache = ''
      ${pkgs.fontconfig}/bin/fc-cache -fv
    '';
  };
}
