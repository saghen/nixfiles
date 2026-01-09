{ ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        {
          monitor = "";
          path = "~/pictures/wallpaper.png";
          fit_mode = "cover";
        }
      ];
    };
  };
}
