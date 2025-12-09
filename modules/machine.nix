{ lib, ... }:
with lib;
let
  bootDevice = {
    diskUuid = mkOption {
      type = types.str;
      description = "Device path (lsblk -f)";
    };

    type = mkOption {
      type = types.str;
      description = "Filesystem type (e.g., ext4, btrfs)";
    };

    options = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Mount options";
    };
  };

  luksDevice = {
    luksUuid = mkOption {
      type = types.str;
      description = "LUKS device name (lsblk -f | grep crypto_LUKS)";
    };

    diskUuid = mkOption {
      type = types.str;
      description = "Device path after unlocking (lsblk -f, unlock with cryptsetup luksOpen /dev/nvme...)";
    };

    type = mkOption {
      type = types.str;
      description = "Filesystem type (e.g., f2fs, btrfs)";
    };

    options = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Mount options";
    };

    trim = mkOption {
      type = types.bool;
      default = true;
      description = "Trim filesystem";
    };
  };
in
{
  options.machine = {
    scalingFactor = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Global UI scaling factor";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of monitor names";
      default = [
        "DP-4"
        "DP-6"
      ];
    };

    width = lib.mkOption {
      type = lib.types.int;
      default = 3840;
      description = "Width of the monitors";
    };

    height = lib.mkOption {
      type = lib.types.int;
      default = 2160;
      description = "Height of the monitors";
    };

    refreshRate = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "Refresh rate of the monitors";
    };

    optimizePower = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Optimize power usage";
    };

    nvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable NVIDIA GPU support";
    };

    microphoneHack = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable microphone hack which forces the volume to 100%";
    };

    backup = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options = {
          toSuperFish = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable backups to super fish";
          };
        };
      };
      description = "Backup configuration";
    };

    disks = lib.mkOption {
      type = lib.types.submodule {
        options = {
          boot = bootDevice;
          root = luksDevice;
          swap = luksDevice;
        };
      };
      description = "Disks configuration";
    };
  };
}
