{ config, ... }:
{
  home.sessionVariables.TERMINAL = "foot";
  programs.foot = {
    enable = true;
    server.enable = true; # better startup time, must use footclient
    settings =
      let
        colors = config.colors;
        convert = c: builtins.substring 1 6 c;
      in
      {
        main = {
          font = "Iosevka Custom Nerd Font:size=${
            toString (builtins.floor (14 * config.machine.scalingFactor))
          }";
          line-height = "${toString (builtins.floor (30 * config.machine.scalingFactor))}px";
          underline-thickness = "2px";
          underline-offset = "5px";
          pad = "4x4";
          initial-window-size-pixels = "1750x1050";
        };
        cursor = {
          unfocused-style = "hollow";
        };
        colors-dark = {
          background = convert colors.base;
          foreground = convert colors.text;

          # black
          bright0 = convert colors.surface-1;
          regular0 = convert colors.surface-2;

          # red
          bright1 = convert colors.red;
          regular1 = convert colors.red;

          # green
          bright2 = convert colors.green;
          regular2 = convert colors.green;

          # yellow
          bright3 = convert colors.yellow;
          regular3 = convert colors.yellow;

          # blue
          bright4 = convert colors.blue;
          regular4 = convert colors.blue;

          # magenta
          bright5 = convert colors.pink;
          regular5 = convert colors.pink;

          # cyan
          bright6 = convert colors.teal;
          regular6 = convert colors.teal;

          # white
          bright7 = convert colors.subtext-1;
          regular7 = convert colors.subtext-0;
        };
      };
  };
}
