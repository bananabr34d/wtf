{
  config,
  pkgs,
  hostName,
  ...
}: {
  home-manager.users.joe = {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        monitor = let
          monitors = {
            carbon = ["eDP-1,1920x1200@60,0x0,1"];
            hydrogen = ["DP-1,3840x2160@60,0x0,1" "HDMI-A-1,1920x1080@60,3840x0,1"];
            ether = [",preferred,auto,1"];
            relic = ["eDP-1,1920x1080@60,0x0,1.5"];
          };
        in
          monitors.${hostName} or [",preferred,auto,1"];
        exec-once = [
          "waybar"
          "swaync"
          "hyprpaper"
          "hyprlock"
        ];
        bind = [
          "SUPER,F,exec,brave"
          "SUPER,N,exec,swaync-client -t"
          "SUPER,L,exec,hyprlock"
          "SUPER,P,exec,hyprpicker"
          ",Print,exec,hyprshot"
          "SUPER,E,exec,thunar"
          "SUPER,Y,exec,kitty -e yazi"
          "SUPER,I,exec,${./emoji-picker.sh}"
          "SUPER,R,exec,fuzzel"
        ];
      };
    };

    xdg.configFile = {
      "waybar/config.jsonc".source = ./waybar/config.jsonc;
      "waybar/style.css".source = ./waybar/style.css;
      "swaync/config.json".source = ./swaync/config.json;
      "swaync/style.css".source = ./swaync/style.css;
      "hypr/hyprpaper.conf".source = ./hyprpaper.conf;
      "hypr/hyprlock.conf".source = ./hyprlock.conf;
      "fuzzel/fuzzel.ini".source = ./fuzzel.ini;
      "kitty/kitty.conf".source = ./kitty.conf;
      "hypr/emoji-picker.sh".source = ./emoji-picker.sh;
      "hypr/emojis.txt".source = ./emojis.txt;
    };
  };
}
