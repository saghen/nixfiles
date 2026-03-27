{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.noctalia.homeModules.default ];

  home.packages = with pkgs; [ gpu-screen-recorder ];

  programs.noctalia-shell = {
    enable = true;

    plugins = {
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        screen-recorder = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        weather-indicator = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };
    pluginSettings = {
      screen-recorder = {
        directory = config.xdg.userDirs.videos;
      };
    };

    settings = {
      general = {
        enableShadows = false;
        dimmerOpacity = 0.0;
        animationSpeed = 1.5;
        enableBlurBehind = false;
      };
      colorSchemes.predefinedScheme = "Catpuccin Lavender";

      bar = {
        showCapsule = false;
        enableExclusionZoneInset = false;
        backgroundOpacity = 1.0;
        frameRadius = 0;
        outerCorners = false;
        widgets = {
          left = [
            {
              id = "Launcher";
              useDistroLogo = true;
              enableColorization = true;
            }
            {
              id = "MediaMini";
              showArtistFirst = false;
              showVisualizer = true;
              maxWidth = 300;
              showProgressRing = false;
            }
          ];
          center = [
            {
              id = "Workspace";
              labelMode = "none";
              pillSize = 0.55;
              occupiedColor = "primary";
              emptyColor = "primary";
            }
          ];
          right = [
            {
              id = "Tray";
              hidePassive = true;
              colorizeIcons = true;
            }
            {
              id = "SystemMonitor";
              showDiskUsage = true;
            }
            { id = "plugin:screen-recorder"; }
            { id = "KeepAwake"; }
            { id = "Brightness"; }
            { id = "Volume"; }
            { id = "Bluetooth"; }
            { id = "Network"; }
            { id = "plugin:weather-indicator"; }
            {
              id = "Clock";
              formatHorizontal = "h:mm AP ddd, MMM dd";
            }
            { id = "Battery"; }
          ];
        };
      };

      location = {
        name = "Toronto";
        use12HourFormat = true;
      };
      ui = {
        tooltipsEnabled = false;
        panelBackgroundOpacity = 1.0;
      };
      appLauncher = {
        enableClipboardHistory = true;
        terminalCommand = "foot -e";
        density = "compact";
        enableSettingsSearch = false;
        enableWindowsSearch = false;
        enableSessionSearch = false;
      };
      audio.preferredPlayer = "spotify";

      nightLight.enabled = true;

      notifications = {
        enabled = true;
        # show on non-primary monitor if available
        monitors = [ (lib.last config.machine.monitors) ];
        density = "compact";
        overlayLayer = false;
      };

      idle = {
        enabled = true;
        fadeDuration = 0;
      };

      wallpaper = {
        enabled = true;
        directory = "${config.xdg.userDirs.pictures}/wallpapers/2026";
        useOriginalImages = true; # reduces cpu usage at the cost of memory
        automationEnabled = true; # rotate images randomly
        randomIntervalSec = 60 * 60; # rotate every hour
      };

      dock.enabled = false;
    };
  };
}
