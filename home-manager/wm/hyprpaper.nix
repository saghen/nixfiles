{ config, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/pictures/wallpaper.png" ];
      wallpaper = map (m: {
        monitor = m;
        path = "~/pictures/wallpaper.png";
        fit_mode = "cover";
      }) config.machine.monitors;
    };
  };
}
