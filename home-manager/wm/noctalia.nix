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
      };
      version = 2;
    };
    pluginSettings = {
      screen-recorder = {
        directory = config.xdg.userDirs.videos;
      };
    };

    settings = {
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
            { id = "ControlCenter"; }
            {
              id = "Clock";
              formatHorizontal = "h:mm AP ddd, MMM dd";
            }
            { id = "Battery"; }
          ];
        };
      };
      general = {
        enableShadows = false;
        dimmerOpacity = 0.0;
        clockFormat = "hh\\nmm";
        animationSpeed = 1.5;
        enableBlurBehind = false;
      };
      location = {
        name = "Toronto";
        use12HourFormat = true;
      };
      ui = {
        tooltipsEnabled = false;
        panelBackgroundOpacity = 1.0;
      };
      wallpaper.enabled = false;
      dock.enabled = false;
      colorSchemes.predefinedScheme = "Catpuccin Lavender";
      nightLight.enabled = true;
      notifications = {
        # show on non-primary monitor if available
        monitors = [ (lib.last config.machine.monitors) ];
        density = "compact";
        overlayLayer = false;
      };
      appLauncher = {
        enableClipboardHistory = true;
        terminalCommand = "foot -e";
        density = "compact";
        enableSettingsSearch = false;
        enableWindowsSearch = false;
        enableSessionSearch = false;
      };
    };
  };

  sops.secrets.limbo = {
    sopsFile = ../../keys/sops/limbo.yaml;
    path = "${config.xdg.configHome}/limbo/secrets.json";
  };
}
