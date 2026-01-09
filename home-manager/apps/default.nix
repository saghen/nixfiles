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
      bluetui # Bluetooth TUI
      impala # WIFI TUI
      nautilus # File management
      vesktop # Discord with screen share and audio
      gnome-system-monitor # System resource monitor
      gparted # Disk management
      obsidian # Notes
      pavucontrol # GUI Volume mixer and device settings
      helvum # GUI Audio routing: Control what apps get what audio
      tauon # Music player
      mpv # Video player
      feh # Image viewer
      qimgv # Image viewer
      nomacs # Image viewer
      obs-studio # Record
      prismlauncher # Minecraft launcher
    ];

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
