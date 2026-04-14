# TODO: maximize-window-to-edges for firefox and neovim when flake updated
# TODO: steam fails to launch through noctalia-shell
# TODO: playerctl not working

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.machine;
  colors = config.colors;
  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);

  launchNeovimZellij = pkgs.writeShellScriptBin "nvim-zellij" ''
    if ID=$(niri msg -j windows | jq -e 'map(select(.app_id == "zellij-neovim")) | .[0].id'); then
      niri msg action focus-window --id $ID
    else
      footclient \
        -o colors.foreground=${builtins.substring 1 6 colors.subtext-1} \
        -o pad=0x0 \
        --window-size-pixels=3840x2160 \
        --app-id zellij-neovim \
        --title zellij-neovim \
        fish -c "zellij --session neovim --new-session-with-layout neovim || zellij attach neovim"
    fi
  '';

  screenshotRegion = pkgs.writeShellScriptBin "screenshot-region" ''
    mkdir -p ${config.xdg.userDirs.pictures}/screenshots/$(date +%Y)
    ${lib.getExe pkgs.wayshot} --geometry --clipboard ${config.xdg.userDirs.pictures}/screenshots/$(date +%Y)/$(date +%Y-%m-%d_%H-%M-%S).png
  '';
in
{
  home.packages = [
    screenshotRegion
    launchNeovimZellij
  ];

  programs.niri.settings = {
    # must use unstable niri and xwayland-satellite for xwayland support (steam)
    xwayland-satellite.path = "${lib.getExe pkgs.xwayland-satellite-unstable}";

    prefer-no-csd = true; # prefer no client side decorations
    screenshot-path = "${config.xdg.userDirs.pictures}/screenshots/%Y/%Y-%m-%d_%H-%M-%S.png";
    animations.slowdown = 0.8;
    animations.screenshot-ui-open.enable = false;
    overview.backdrop-color = colors.crust;

    layout = {
      gaps = 10 * cfg.scalingFactor;
      always-center-single-column = true;
      shadow.enable = false;
      border = {
        enable = true;
        width = 2;
        active.color = colors.primary;
        inactive.color = colors.base;
        urgent.color = colors.red;
      };
      focus-ring.enable = false;
    };

    input.keyboard = {
      repeat-rate = 40;
      repeat-delay = 240;
    };
    input.touchpad.natural-scroll = true;
    gestures.hot-corners.enable = false;

    outputs = builtins.listToAttrs (
      lib.imap0 (i: name: {
        inherit name;
        value = {
          scale = 1.0;
          variable-refresh-rate = cfg.variableRefreshRate;
          mode = {
            width = cfg.width;
            height = cfg.height;
            refresh = cfg.refreshRate * 1.0; # convert to float
          };
          position = {
            x = i * cfg.width * -1; # invert so we do left-to-right
            y = 0;
          };
        };
      }) cfg.monitors
    );

    spawn-at-startup = [
      { argv = [ "noctalia-shell" ]; }
      { argv = [ "firefox-nightly" ]; }
      { argv = [ "vesktop" ]; }
      { argv = [ "spotify" ]; }
    ];

    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = { };

      "Mod+Q".action.focus-monitor-next = { };
      "Mod+W".action.close-window = { };
      "Mod+D".action.spawn = noctalia "launcher toggle";
      "Mod+Return".action.spawn = "footclient";
      "Mod+Shift+Return".action.spawn = "foot"; # fallback in case foot.service fails
      "Mod+C".action.spawn = "${lib.getExe launchNeovimZellij}";
      "Mod+A".action.move-window-to-monitor-next = { };
      "Mod+S".action.move-workspace-to-monitor-next = { };
      "Mod+M".action.maximize-window-to-edges = { };

      "Mod+R".action.switch-preset-column-width = { };
      "Mod+E".action.switch-preset-column-width-back = { };

      "Mod+Space".action.switch-layout = "next";
      "Mod+Shift+Space".action.switch-layout = "prev";

      "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase";
      "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease";
      "XF86AudioMute".action.spawn = noctalia "volume muteOutput";
      "XF86AudioMicMute".action.spawn = noctalia "microphone muteInput";
      "XF86MonBrightnessUp".action.spawn = noctalia "brightness increase";
      "XF86MonBrightnessDown".action.spawn = noctalia "brightness decrease";

      "XF86AudioPlay".action.spawn-sh = "playerctl --player=spotify play-pause";
      "XF86AudioNext".action.spawn-sh = "playerctl --player=spotify next";
      "XF86AudioPrev".action.spawn-sh = "playerctl --player=spotify previous";

      "Mod+Left".action.focus-column-left = { };
      "Mod+Down".action.focus-window-down = { };
      "Mod+Up".action.focus-window-up = { };
      "Mod+Right".action.focus-column-right = { };
      "Mod+H".action.focus-column-or-monitor-left = { };
      "Mod+J".action.focus-window-or-workspace-down = { };
      "Mod+K".action.focus-window-or-workspace-up = { };
      "Mod+L".action.focus-column-or-monitor-right = { };

      "Mod+Shift+Left".action.move-column-left = { };
      "Mod+Shift+Down".action.move-window-down = { };
      "Mod+Shift+Up".action.move-window-up = { };
      "Mod+Shift+Right".action.move-column-right = { };
      "Mod+Shift+H".action.move-column-left = { };
      "Mod+Shift+J".action.move-window-down-or-to-workspace-down = { };
      "Mod+Shift+K".action.move-window-up-or-to-workspace-up = { };
      "Mod+Shift+L".action.move-column-right = { };

      "Mod+Home".action.focus-column-first = { };
      "Mod+End".action.focus-column-last = { };
      "Mod+Shift+Home".action.move-column-to-first = { };
      "Mod+Shift+End".action.move-column-to-last = { };

      "Mod+Ctrl+Left".action.focus-monitor-left = { };
      "Mod+Ctrl+Down".action.focus-monitor-down = { };
      "Mod+Ctrl+Up".action.focus-monitor-up = { };
      "Mod+Ctrl+Right".action.focus-monitor-right = { };
      "Mod+Ctrl+H".action.focus-monitor-left = { };
      "Mod+Ctrl+J".action.focus-monitor-down = { };
      "Mod+Ctrl+K".action.focus-monitor-up = { };
      "Mod+Ctrl+L".action.focus-monitor-right = { };

      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = { };
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = { };
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = { };
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = { };
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = { };
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = { };
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };

      "Mod+Page_Down".action.focus-workspace-down = { };
      "Mod+Page_Up".action.focus-workspace-up = { };
      "Mod+U".action.focus-workspace-down = { };
      "Mod+I".action.focus-workspace-up = { };
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
      "Mod+Ctrl+U".action.move-column-to-workspace-down = { };
      "Mod+Ctrl+I".action.move-column-to-workspace-up = { };

      "Mod+Shift+Page_Down".action.move-workspace-down = { };
      "Mod+Shift+Page_Up".action.move-workspace-up = { };
      "Mod+Shift+U".action.move-workspace-down = { };
      "Mod+Shift+I".action.move-workspace-up = { };

      # You can bind mouse wheel scroll ticks using the following syntax.
      # These binds will change direction based on the natural-scroll setting.
      #
      # To avoid scrolling through workspaces really fast, you can use
      # the cooldown-ms property. The bind will be rate-limited to this value.
      # You can set a cooldown on any bind, but it's most useful for the wheel.
      "Mod+WheelScrollDown" = {
        cooldown-ms = 150;
        action.focus-workspace-down = { };
      };
      "Mod+WheelScrollUp" = {
        cooldown-ms = 150;
        action.focus-workspace-up = { };
      };
      "Mod+Ctrl+WheelScrollDown" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-down = { };
      };
      "Mod+Ctrl+WheelScrollUp" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-up = { };
      };

      "Mod+WheelScrollRight".action.focus-column-right = { };
      "Mod+WheelScrollLeft".action.focus-column-left = { };
      "Mod+Ctrl+WheelScrollRight".action.move-column-right = { };
      "Mod+Ctrl+WheelScrollLeft".action.move-column-left = { };

      # Usually scrolling up and down with Shift in applications results in
      # horizontal scrolling; these binds replicate that.
      "Mod+Shift+WheelScrollDown".action.focus-column-right = { };
      "Mod+Shift+WheelScrollUp".action.focus-column-left = { };
      "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
      "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };

      # Similarly, you can bind touchpad scroll "ticks".
      # Touchpad scrolling is continuous, so for these binds it is split into
      # discrete intervals.
      # These binds are also affected by touchpad's natural-scroll, so these
      # example binds are "inverted", since we have natural-scroll enabled for
      # touchpads by default.
      # Mod+TouchpadScrollDown { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02+"; }
      # Mod+TouchpadScrollUp   { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02-"; }

      # You can refer to workspaces by index. However, keep in mind that
      # niri is a dynamic workspace system, so these commands are kind of
      # "best effort". Trying to refer to a workspace index bigger than
      # the current workspace count will instead refer to the bottommost
      # (empty) workspace.
      #
      # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
      # will all refer to the 3rd workspace.
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+Alt+1".action.move-column-to-workspace = 1;
      "Mod+Alt+2".action.move-column-to-workspace = 2;
      "Mod+Alt+3".action.move-column-to-workspace = 3;
      "Mod+Alt+4".action.move-column-to-workspace = 4;
      "Mod+Alt+5".action.move-column-to-workspace = 5;
      "Mod+Alt+6".action.move-column-to-workspace = 6;
      "Mod+Alt+7".action.move-column-to-workspace = 7;
      "Mod+Alt+8".action.move-column-to-workspace = 8;
      "Mod+Alt+9".action.move-column-to-workspace = 9;

      # Alternatively, there are commands to move just a single window:
      # Mod+Ctrl+1 { move-window-to-workspace 1; }

      # Switches focus between the current and the previous workspace.
      # Mod+Tab { focus-workspace-previous; }

      "Mod+Comma".action.consume-window-into-column = { };
      "Mod+Period".action.expel-window-from-column = { };

      # There are also commands that consume or expel a single window to the side.
      # Mod+BracketLeft  { consume-or-expel-window-left; }
      # Mod+BracketRight { consume-or-expel-window-right; }

      "Mod+Shift+R".action.reset-window-height = { };
      "Mod+F".action.maximize-column = { };
      "Mod+Shift+F".action.fullscreen-window = { };

      # Finer width adjustments.
      # This command can also:
      # * set width in pixels: "1000"
      # * adjust width in pixels: "-5" or "+5"
      # * set width as a percentage of screen width: "25%"
      # * adjust width as a percentage of screen width: "-10%" or "+10%"
      # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
      # set-column-width "100" will make the column occupy 200 physical screen pixels.
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";

      # Finer height adjustments when in column with other windows.
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      # use our own so we don't have to Ctrl+C
      # TODO: make feature request
      "Print".action.spawn = "${lib.getExe screenshotRegion}";
      "Ctrl+Print".action.screenshot-screen = { };
      "Alt+Print".action.screenshot-window = { };

      # The quit action will show a confirmation dialog to avoid accidental exits.
      "Mod+Shift+E".action.quit = { };

      # Powers off the monitors. To turn them back on, do any input like
      # moving the mouse or pressing any other key.
      "Mod+Shift+P".action.power-off-monitors = { };
    };

    window-rules = [
      {
        matches = [ { app-id = "firefox-nightly"; } ];
        open-on-output = builtins.head config.machine.monitors;
      }
      {
        matches = [
          { app-id = "vesktop"; }
          { app-id = "spotify"; }
        ];
        open-on-output = lib.last config.machine.monitors;
        default-column-width.proportion = 0.5;
      }
      # steam notifications: https://niri-wm.github.io/niri/Application-Issues.html#steam
      {
        matches = [
          {
            app-id = "steam";
            title = "^notificationtoasts_\\d+_desktop$";
          }
        ];
        default-floating-position = {
          x = 10;
          y = 10;
          relative-to = "bottom-right";
        };
        open-focused = false;
      }
    ];
  };
}
