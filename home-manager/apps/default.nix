{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./firefox
    ./thunderbird
    ./spotify.nix
    ./video.nix
  ];
  config = {
    home.packages = with pkgs; [
      nautilus # File management
      equibop # Discord with screen share and audio
      gnome-system-monitor # System resource monitor
      gparted # Disk management
      pavucontrol # GUI Volume mixer and device settings
      tauon # Music player
      mpv # Video player
      feh # Image viewer
      qimgv # Image viewer
      nomacs # Image viewer
      (prismlauncher.override { jdks = [ pkgs.jdk21 ]; }) # Minecraft launcher
      jellyfin-media-player # Media player
      ente-desktop # Photos
    ];

    # override the package to drop the 2GB CEF binary
    programs.obs-studio =
      let
        obs = pkgs.obs-studio.override { browserSupport = false; };
      in
      {
        enable = true;
        package = obs;
        plugins = map (p: p.override { obs-studio = obs; }) (
          with pkgs.obs-studio-plugins;
          [
            obs-pipewire-audio-capture
            obs-vaapi
            obs-vkcapture
          ]
        );
      };

    # google drive lite
    services.syncthing.enable = true;

    xdg.configFile.qimgv-theme =
      let
        toINI = pkgs.lib.generators.toINI { };
        colors = config.colors;
      in
      {
        target = "qimgv/theme.conf";
        text = toINI {
          Colors = {
            accent = colors.primary;
            background = colors.base;
            background_fullscreen = colors.base;
            folderview = colors.base;
            folderview_topbar = colors.mantle;
            icons = colors.subtext-2;
            overlay = colors.core;
            overlay_text = colors.text;
            scrollbar = colors.surface-0;
            text = colors.text;
            widget = colors.core;
            widget_border = colors.surface-0;
          };
        };
      };
  };
}
