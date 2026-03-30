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

  services.libinput.touchpad.naturalScrolling = true;

  environment.variables = {
    XDG_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1"; # enable wayland in all apps

    # scaling
    GDK_SCALE = toString config.machine.scalingFactor;
    QT_SCALE_FACTOR = toString config.machine.scalingFactor;
  };

  # window manager
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };
  services.displayManager.defaultSession = "niri";

  # login screen with auto login
  services.displayManager = {
    autoLogin.user = "saghen";
    gdm.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  # required by various gtk apps, such as nautilus for detecting removable drives
  services.gvfs.enable = true;
}
