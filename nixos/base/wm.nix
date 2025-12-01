{ pkgs, ... }:
{
  services.libinput.touchpad.naturalScrolling = true;

  # window manager
  programs.hyprland = {
    enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };
  services.displayManager.defaultSession = "hyprland-uwsm";
  security.pam.services.hyprlock = { }; # required to allow hyprlock to unlock

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
