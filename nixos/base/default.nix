{ config, lib, ... }:
{
  imports = [
    ./backups.nix
    ./boot.nix
    ./gaming.nix
    ./networking.nix
    ./security.nix
    ./sound.nix
    ./wm.nix
  ];

  config = {
    # rootless, since membership in the docker group is equivalent to root
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    # start manually via `systemctl --user start docker`
    systemd.user.services.docker.wantedBy = lib.mkIf config.machine.optimizePower (lib.mkForce [ ]);

    # allow executables bundled for generic linux distros to run
    programs.nix-ld.enable = true;

    # Higher performance dbus
    services.dbus.implementation = "broker";

    # Distribute interrupts over cores (Improves responsiveness during 100% cpu load)
    services.irqbalance.enable = !config.machine.optimizePower;

    # Power management for applications, and battery support for limbo
    services.upower.enable = config.machine.optimizePower;
  };
}
