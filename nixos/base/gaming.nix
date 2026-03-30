{ pkgs, ... }:
{
  # controller support
  hardware.xone.enable = true;

  # games
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [ mangohud ];
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
  };
  programs.gamescope.enable = true;

  # streaming
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;

    settings = {
      min_log_level = "debug";
      origin_web_ui_allowed = "pc";
      fec_percentage = 0; # % of packets used for packet loss recovery
      qp = 20; # quality when vbr is unsupported
    };

    applications = {
      apps = [
        {
          name = "Steam";
          output = "";
          cmd = "";
          exclude-global-prep-cmd = "false";
          elevated = "false";
          auto-detach = "true";
          image-path = "steam.png";
          detached = [ "setsid steam steam://open/bigpicture" ];
        }
      ];
    };
  };
}
