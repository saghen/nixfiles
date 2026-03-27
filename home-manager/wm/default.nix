{
  config,
  lib,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./misc.nix
    ./noctalia.nix
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
