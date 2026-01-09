{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  monitors = config.machine.monitors;
  colors = config.colors;
  convertHL = c: "0xff" + builtins.substring 1 6 c;

  gameWorkspace = toString (if builtins.length monitors > 1 then 3 else 5);
  discordWorkspace = toString (if builtins.length monitors > 1 then 7 else 4);
  spotifyWorkspace = toString (if builtins.length monitors > 1 then 7 else 5);
  # blackoutWorkspace = toString (if builtins.length monitors > 1 then 8 else 2);
in
{
  home.packages = with pkgs; [ wl-clipboard ];

  # launcher
  programs.vicinae.enable = true;
  programs.vicinae.systemd.enable = true;

  # turn off screens
  services.hypridle = {
    enable = true; # TODO: breaks VRR
    settings = {
      general = {
        # avoid starting multiple hyprlock instances
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        # turn screen off after 5 minutes
        {
          timeout = 300;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # lock after 10 minutes
        {
          timeout = 600;
          on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
        }
      ];
    };
  };

  # night light
  services.gammarelay.enable = true;

  # window manager
  wayland.windowManager.hyprland = {
    enable = true;

    plugins = with pkgs; [
      # (hyprlandPlugins.mkHyprlandPlugin {
      #   pluginName = "hyprselect";
      #   version = "0.1";
      #   src = fetchFromGitHub {
      #     owner = "jmanc3";
      #     repo = "hyprselect";
      #     rev = "88c1ff97cf2b33add3ddea62991700f6bf6b5893";
      #     hash = "sha256-pLSfS4x6SMVykUqTLYE8feEQqP1yOtKDVeAvzFJoc+I=";
      #   };
      #
      #   inherit (hyprland) nativeBuildInputs;
      #
      #   meta = with lib; {
      #     homepage = "https://github.com/jmanc3/hyprselect";
      #     description = "A plugin that adds a completely useless desktop selection box to Hyprland";
      #     license = licenses.unlicense;
      #     platforms = platforms.linux;
      #   };
      # })
    ];

    settings = {
      "$mod" = "SUPER";

      monitor =
        let
          monitors = config.machine.monitors;
          width = config.machine.width;
          height = config.machine.height;
          refreshRate = config.machine.refreshRate;

          monitorStrings = lib.imap (
            i: monitor:
            "${monitor}, ${toString width}x${toString height}@${toString refreshRate}, ${
              toString ((builtins.length monitors - i) * width)
            }x0, 1"
          ) monitors;
        in
        monitorStrings ++ [ "Unknown-1, disable" ];

      xwayland = {
        force_zero_scaling = true;
      };

      # assign 6 workspaces to each monitor
      workspace =
        builtins.genList (
          x:
          let
            ws = toString (x + 1);
            monitor = builtins.elemAt monitors (x / 6);
          in
          "${ws}, monitor:${monitor}"
        ) (builtins.length monitors * 6)
        # Hide gaps on single window in workspace
        ++ [
          "w[tv1], gapsout:0, gapsin:0"
          "f[1], gapsout:0, gapsin:0"
        ];

      # TODO: doesnt apply to foot because it runs as a server
      env = [
        "XDG_BACKEND,wayland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_CURRENT_DESKTOP,hyprland"
        "QT_QPA_PLATFORM,wayland"

        # scaling
        "GDK_SCALE,${toString config.machine.scalingFactor}"
        "QT_SCALE_FACTOR,${toString config.machine.scalingFactor}" # todo: does this do anything?

        # enable wayland in all apps
        "NIXOS_OZONE_WL,1"
      ]
      ++ lib.optionals (config.machine.nvidia) [
        "LIBVA_DRIVER_NAME,nvidia"
        "NVD_BACKEND,direct"
      ];

      ## Settings
      general = {
        gaps_out = 8;
        gaps_in = 8;
        allow_tearing = true;

        "col.inactive_border" = convertHL colors.base;
        "col.active_border" = convertHL colors.primary;
      };
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
      decoration.blur.enabled = false;
      cursor = {
        no_hardware_cursors = true;
        no_warps = true;
        default_monitor = builtins.elemAt monitors 0;
        # set the minimum refresh rate of the monitor to prevent flicker
        min_refresh_rate = 48;
      };
      input = {
        # 2 allows cursor focus separate from keyboard focus
        # to allow for scrolling without focusing
        follow_mouse = 2;
        float_switch_override_focus = 0;

        touchpad.natural_scroll = true;

        kb_options = "caps:super";
        repeat_rate = 40;
        repeat_delay = 240;
      };
      misc = {
        # focus when applications request it
        focus_on_activate = true;

        # causes background apps to run at 60fps, primarily for elden ring
        render_unfocused_fps = 60;

        disable_hyprland_logo = true;
        background_color = convertHL colors.crust;
        force_default_wallpaper = 0;

        enable_swallow = false; # naive implementation works poorly
        swallow_regex = "footclient";

        # Whether mouse moving into a different monitor should focus it
        mouse_move_focuses_monitor = false;

        disable_xdg_env_checks = true;

        # Reduces latency by showing frames as they come in, and eliminates tearing
        vrr = 3;
      };
      render.direct_scanout = 2;
      # debug = { disable_logs = false; };

      ## Animations
      animation = [ "global,1,1,default," ];

      ## Binds
      bind =
        let
          a2u = "${pkgs.app2unit}/bin/app2unit -s a";

          wayfreeze = "${
            inputs.wayfreeze.packages.${pkgs.stdenv.hostPlatform.system}.wayfreeze
          }/bin/wayfreeze";
          wayshot = "${pkgs.wayshot}/bin/wayshot";
          slurp = "${pkgs.slurp}/bin/slurp";
          pkill = "${pkgs.procps}/bin/pkill";
          wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
          wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
          satty = "${pkgs.satty}/bin/satty";
          jq = "${pkgs.jq}/bin/jq";

          # https://github.com/Jappie3/wayfreeze/issues/14
          screenshotTmpl =
            args:
            "${wayfreeze} --hide-cursor --after-freeze-cmd='"
            + "${wayshot} ${args} --stdout | ${wl-copy}" # take screenshot and copy to clipboard
            + " && ${wl-paste} > ~/pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" # save to file
            + " && cat < ~/pictures/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" # stdout filename for satty
            + "; ${pkill} wayfreeze'"; # unfreeze

          screenshotRegion = screenshotTmpl ''-s "$(${slurp})"'';

          # never touch this...
          # format from docs: https://github.com/emersion/slurp
          windowSlurp = pkgs.writeShellScriptBin "window-slurp" ''
            VISIBLE_WORKSPACES=$(hyprctl monitors -j | ${jq} -r 'map(.activeWorkspace.id) | tostring')
            hyprctl clients -j | ${jq} "map(select([.workspace.id] | inside($VISIBLE_WORKSPACES))) | map(select(.hidden | not))" | ${jq} -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | ${slurp}
          '';
          screenshotWindow = screenshotTmpl ''-s "$(${windowSlurp}/bin/window-slurp)"'';

          monitorSlurp = pkgs.writeShellScriptBin "monitor-slurp" ''
            hyprctl monitors -j | ${jq} -r '.[] | "\(.x),\(.y) \(.width)x\(.height)"' | ${slurp}
          '';
          screenshotMonitor = screenshotTmpl ''-s "$(${monitorSlurp}/bin/monitor-slurp)"'';

          subtext = builtins.substring 1 6 colors.subtext-1;
          launchNeovimZellij = pkgs.writeShellScriptBin "launch-neovim-zellij" ''
            WINDOW_ADDRESS=$(hyprctl clients -j | jq 'map(select(.class == "zellij-neovim")) | .[0].address' -r)
            if [ "$WINDOW_ADDRESS" == "null" ]; then
              footclient \
                -o colors.foreground=${subtext} \
                -o pad=0x0 \
                --window-size-pixels=3840x2160 \
                --app-id zellij-neovim \
                --title zellij-neovim \
                fish -c "zellij --session neovim --new-session-with-layout neovim || zellij attach neovim"
            else
              hyprctl dispatch focuswindow zellij-neovim
            fi
          '';

          toggleBlackout = pkgs.writeShellScriptBin "toggle-blackout" ''
            #!/bin/bash
            MONITOR="DP-2"  # Change to your monitor name
            PIDFILE="/tmp/blackout_monitor.pid"

            if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
                kill "$(cat "$PIDFILE")"
                rm "$PIDFILE"
                echo "Blackout disabled"
            else
                # Get the current workspace on the target monitor
                WORKSPACE=$(hyprctl monitors -j | jq -r ".[] | select(.name==\"$MONITOR\") | .activeWorkspace.id")
                
                # Set a one-time window rule for the next mpv window
                hyprctl keyword windowrule "tag +blackout, match:class ^(mpv)$, match:title ^(lavfi.+)"
                hyprctl keyword windowrule "tag blackout, workspace $WORKSPACE silent"
                hyprctl keyword windowrule "tag blackout, fullscreen on"
                hyprctl keyword windowrule "tag blackout, no_anim on"
                hyprctl keyword windowrule "tag blackout, no_focus on"
                
                # Start mpv
                mpv --loop=inf --no-input-default-bindings \
                    --really-quiet --no-osc --no-osd-bar \
                    av://lavfi:color=c=black &
                echo $! > "$PIDFILE"
                
                echo "Blackout enabled on $MONITOR (workspace $WORKSPACE)"
            fi
          '';

          swayosdClient = "${pkgs.swayosd}/bin/swayosd-client";
        in
        [
          # applications
          "$mod, Space, exec, ${a2u} fish -c 'vicinae toggle'"
          "$mod, Return, exec, ${a2u} footclient"
          # NOTE: specifying the window size avoids a flash of smaller window
          # NOTE: specifying the foreground color sets the cursor color when the background/foreground are the same
          "$mod, c, exec, ${a2u} ${launchNeovimZellij}/bin/launch-neovim-zellij"
          "$mod + SHIFT, c, exec, ${a2u} footclient -o colors.foreground=${subtext} -o pad=0x0 --window-size-pixels=2560x1440 --app-id neovim --title neovim nvim"
          "$mod + SHIFT, Return, exec, ${a2u} foot" # fallback in case foot.service fails

          # screenshots
          ", Print, exec, ${screenshotRegion}"
          "SHIFT, Print, exec, ${screenshotRegion} | ${satty} --early-exit --filename -"
          "CTRL, Print, exec, ${screenshotWindow}"
          "CTRL + SHIFT, Print, exec, ${screenshotWindow} | ${satty} --early-exit --filename -"
          "ALT, Print, exec, ${screenshotMonitor}"
          "ALT + SHIFT, Print, exec, ${screenshotMonitor} | ${satty} --early-exit --filename -"

          # window management
          "$mod, q, focusmonitor, +1"
          # TODO: figure out how to alterzindex since bringactivetotop is deprecated
          "$mod, r, exec, hyprctl dispatch cyclenext && hyprctl dispatch bringactivetotop"
          "$mod + SHIFT, r, cyclenext, prev"
          "$mod, a, movewindow, mon:+1"
          "$mod, w, exec, hyprctl activewindow -j | jq '.fullscreen == 0' -e && hyprctl dispatch closewindow activewindow"
          "$mod + ALT, w, closewindow, activewindow"
          "$mod + ALT + SHIFT, w, killactive"
          "$mod, f, togglefloating"
          "$mod + SHIFT, f, fullscreen"
          "$mod, s, swapactiveworkspaces, ${lib.concatStringsSep " " monitors}"
          "$mod, d, centerwindow"
          "$mod, t, exec, ${toggleBlackout}/bin/toggle-blackout"

          # special
          ## swayosd  TODO: never tested
          ", XF86AudioRaiseVolume, exec, ${swayosdClient} --output-volume raise"
          ", XF86AudioLowerVolume, exec, ${swayosdClient} --output-volume lower"
          ", XF86AudioMute, exec, ${swayosdClient} --output-volume mute-toggle"
          ", XF86AudioMicMute, exec, ${swayosdClient} --input-volume mute-toggle"
          ", XF86MonBrightnessUp, exec, ${swayosdClient} --brightness raise"
          ", XF86MonBrightnessDown, exec, ${swayosdClient} --brightness lower"
          ## media
          ", XF86AudioPlay, exec, playerctl --player=spotify play-pause"
          ", XF86AudioNext, exec, playerctl --player=spotify next"
          ", XF86AudioPrev, exec, playerctl --player=spotify previous"
          "CTRL, XF86AudioPlay, exec, playerctl --player=firefox play-pause"
          "CTRL, XF86AudioNext, exec, playerctl --player=firefox next"
          "CTRL, XF86AudioPrev, exec, playerctl --player=firefox previous"

          "$mod + ALT, n, exit"
        ]
        ++ (
          # workspaces
          # binds $mod + [alt +] {1..6} to [move to] workspace {1..6}
          builtins.concatLists (
            builtins.genList (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
                # TODO: changes depending on monitor order
                is_main_monitor = "test $(hyprctl activeworkspace -j | jq '.monitorID') -eq 0";
                get_workspace = "${is_main_monitor} && echo ${toString (x + 1)} || echo ${toString (x + 7)}";
              in
              [
                "$mod, ${ws}, exec, hyprctl dispatch workspace $(${get_workspace})"
                "$mod + ALT, ${ws}, exec, hyprctl dispatch movetoworkspace $(${get_workspace})"
              ]
            ) 6
          )
        );

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      ## Rules
      windowrule = [
        # Hide border on single window in workspace
        "match:workspace w[tv1]s[false], match:float 0, border_size 0"
        "match:workspace f[1]s[false], match:float 0, border_size 0"

        # Default all floating
        "match:class .*, float on"
        "match:title .*, float on"

        # Firefox
        "match:class firefox-nightly, tile on"

        # Games: fullscreen, workspace 3, always focused for workspace, ignore activate
        "tag +game, match:class (steam_app_.+|tf_linux64|gamescope)"
        "tag game, fullscreen on"
        "tag game, workspace ${gameWorkspace}"
        "tag game, render_unfocused on"
        # VRR flickers so this is the next best thing
        "tag game, immediate on"
        "tag game, content game"
        # TODO: Can't click out of the game window onto the other monitor
        # "stayfocused,class:(steam_app_.+|tf_linux64|gamescope)"

        # Tiled
        "match:class spotify, tile on, workspace ${spotifyWorkspace}"
        "match:class vesktop, tile on, workspace ${discordWorkspace}"
        "match:class neovim, tile on"
        "match:class zellij-neovim, tile on"
        "match:class thunderbird, match:title Mozilla Thunderbird, tile on" # must be specific, otherwise popups will tile

        # Sizing
        "match:class org.gnome.SystemMonitor, size 900 1000"
        "match:class org.gnome.Nautilus, size 1200 800"
        "match:class steam, match:title Steam, size 1800 1200"
        "match:class qimgv, min_size 640 480"

        # Floating
        "match:class utility, float on"
        "match:class notification, float on"
        "match:class toolbar, float on"
        "match:class splash, float on"
        "match:class dialog, float on"
        "match:class file_progress, float on"
        "match:class confirm, float on"
        "match:class dialog, float on"
        "match:class download, float on"
        "match:class error, float on"
        "match:class notification, float on"
        "match:class splash, float on"
        "match:class toolbar, float on"

        # Disable animations
        "match:class foot(client)?, no_anim 1"
      ];

      ## Autostart
      exec-once = [
        "[workspace 1 silent] firefox-nightly"
        "${pkgs.swayosd}/bin/swayosd-server"
        "[workspace ${spotifyWorkspace} silent] spotify"
        # TODO: https://github.com/Vencord/Vesktop/issues/342
        # needed for working drag and drop
        "[workspace ${discordWorkspace} silent] vesktop"
      ]
      ++ lib.optionals config.machine.microphoneHack [
        # constantly set volume to 1 to counteract something adjusting it
        "while true; do sleep 1 && ${pkgs.pulseaudio}/bin/pactl set-source-volume @DEFAULT_SOURCE@ 100%; done &"
      ];
    };
  };
}
