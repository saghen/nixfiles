{ pkgs, ... }:
{
  # controller support
  hardware.xone.enable = true;

  # games
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
      # min_log_level = "debug";
      origin_web_ui_allowed = "pc";
      fec_percentage = 0; # % of packets used for packet loss recovery
      qp = 20; # quality when vbr is unsupported
      output_name = "1";
      capture = "kms";
    };

    applications = {
      apps = [
        {
          name = "Steam";
          output = "";
          cmd = "";
          image-path = "steam.png";
          prep-cmd = [
            {
              do = "setsid steam steam://open/bigpicture";
              undo = "setsid steam steam://close/bigpicture &";
            }
          ];
        }
      ];
    };
  };
}
