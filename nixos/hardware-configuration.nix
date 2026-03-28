{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Boot
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/${config.machine.disks.boot.diskUuid}";
    fsType = config.machine.disks.boot.type;
    options = config.machine.disks.boot.options;
  };

  # Root
  boot.initrd.luks.devices."luks-${config.machine.disks.root.luksUuid}" = {
    device = "/dev/disk/by-uuid/${config.machine.disks.root.luksUuid}";
    allowDiscards = config.machine.disks.root.trim;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${config.machine.disks.root.diskUuid}";
    fsType = config.machine.disks.root.type;
    options = config.machine.disks.root.options;
  };

  # Swap
  # NOTE: NixOS setup doesn't insert this luks device by default which leads to long boot times
  # while it waits for the disk to appear.
  # You can get the UUID of the swap partition by running `lsblk -f` and looking for the UUID
  boot.initrd.luks.devices."luks-${config.machine.disks.swap.luksUuid}" = {
    device = "/dev/disk/by-uuid/${config.machine.disks.swap.luksUuid}";
    allowDiscards = config.machine.disks.swap.trim;
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/${config.machine.disks.swap.diskUuid}"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
