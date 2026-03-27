{ pkgs, ... }:
{
  services.libinput.touchpad.naturalScrolling = true;

  # window manager
  programs.hyprland = {
    enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };
  services.displayManager.defaultSession = "hyprland";

  # login screen with auto login
  services.displayManager = {
    sessionPackages = [ pkgs.niri ];
    autoLogin.user = "saghen";
    gdm.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    configPackages = [ pkgs.jay ];
  };

  # required by various gtk apps, such as nautilus for detecting removable drives
  services.gvfs.enable = true;
}
