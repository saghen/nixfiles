{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        ui_scale = config.machine.scalingFactor;
        polkit_agent = true;
        animation = {
          enabled = !config.machine.optimizePower;
          speed = 1.5;
        };
        mpris.blacklist = [ "firefox-nightly" ];
        launcher.categories = false;
      };

      # improves idle power draw due to fewer screen updates
      system.monitor = lib.mkIf config.machine.optimizePower {
        cpu_poll_seconds = 10.0;
        memory_poll_seconds = 10.0;
        disk_poll_seconds = 60.0;
      };

      theme.builtin = "Catppuccin";
      location.address = "Toronto, ON";
      nightlight.enabled = true;
      weather.enabled = true;
      notifications.monitors = [ (lib.last config.machine.monitors) ]; # non-primary if available

      widget.clock.format = "{:%-I:%M %p} {:%a}, {:%b %d}";
      widget.workspaces = {
        display = "none";
        pill_scale = 0.8;
        occupied_color = "primary";
        empty_color = "primary";
      };
      widget.media.max_width = 350 * config.machine.scalingFactor;
      widget.launcher.glyph = "";
      widget.tray.drawer = true;
      widget.internal_battery = {
        type = "battery";
        device = "auto";
        display_mode = "icon";
      };
      widget.brightness.show_label = false;
      widget.volume.show_label = false;
      widget.network.show_label = false;
      widget.weather.show_condition = false;

      widget.cpu = {
        type = "sysmon";
        stat = "cpu_usage";
        show_value = false;
      };
      widget.temp = {
        type = "sysmon";
        stat = "cpu_temp";
        show_value = false;
      };
      widget.ram = {
        type = "sysmon";
        stat = "ram_used";
        show_value = false;
      };
      widget.disk = {
        type = "sysmon";
        stat = "disk_used_pct";
        path = "/";
        show_value = false;
      };
      system.monitor = {
        cpu_temp_activity_threshold = 80;
        cpu_temp_critical_threshold = 85;
        disk_used_pct_activity_threshold = 90;
        disk_used_pct_critical_threshold = 95;
      };

      bar.main = {
        scale = config.machine.scalingFactor;
        thickness = 34 * config.machine.scalingFactor;
        widget_spacing = 12 * config.machine.scalingFactor;
        radius = 0;
        margin_ends = 0;
        margin_edge = 0;
        shadow = false;
        outer_corners = false;

        start = [
          "launcher"
          "media"
        ];
        center = [ "workspaces" ];
        end = [
          "tray"
          "cpu"
          "temp"
          "ram"
          "disk"
          "power_profile"
          "brightness"
          "volume"
          "bluetooth"
          "network"
          "weather"
          "clock"
          "internal_battery"
        ];
      };

      idle = {
        behavior.lock = {
          timeout = 60 * 60; # hour
          command = "noctalia:session lock";
        };
        behavior.screen_off = {
          timeout = 60 * 10; # 10 minutes
          command = "noctalia:dpms-off";
          resumeCommand = "noctalia:dpms-on";
        };
      };

      wallpaper = {
        directory = "${config.xdg.userDirs.pictures}/wallpapers/current";
        automation.enabled = true;
        automation.interval_seconds = 60 * 60; # rotate every hour
      };
    };
  };
}
