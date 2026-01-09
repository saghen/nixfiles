{ config, ... }:
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
    virtualisation.docker.enable = true;
    # required for nvidia support in docker
    hardware.graphics.enable32Bit = true;

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
