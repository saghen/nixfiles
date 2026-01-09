{
  config,
  lib,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./limbo.nix
    ./misc.nix
    ./services/dunst.nix
    ./services/hyprpaper.nix
    ./theme.nix
    ./xdg.nix
  ];
  config = rec {
    # Generate a set of DISPLAY1, DISPLAY2, ... based on monitors list
    home.sessionVariables = builtins.listToAttrs (
      lib.imap1 (i: monitor: {
        name = "DISPLAY${toString i}";
        value = monitor;
      }) config.machine.monitors
    );
    systemd.user.sessionVariables = home.sessionVariables;
  };
}
