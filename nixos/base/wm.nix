{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.niri.nixosModules.niri ];
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];
  niri-flake.cache.enable = false;

  services.speechd.enable = false; # uses 700MiB of memory

  environment.variables = {
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1"; # enable wayland in all apps

    # scaling
    QT_SCALE_FACTOR = toString config.machine.scalingFactor;
  };

  # window manager
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };
  services.displayManager.defaultSession = "niri";

  # auto login
  services.greetd = {
    enable = true;
    settings = {
      # login shell so /etc/profile sets environment.variables
      initial_session = {
        user = "saghen";
        command = "${pkgs.bash}/bin/bash -l -c 'exec niri-session'";
      };
      # poweroff on logout
      default_session = {
        user = "root";
        command = "${config.systemd.package}/bin/systemctl poweroff";
      };
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  # required by various gtk apps, such as nautilus for detecting removable drives
  services.gvfs.enable = true;
}
