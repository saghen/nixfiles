{ ... }:
{
  config = {
    machine = {
      scalingFactor = 1.25;
      monitors = [
        "DP-1"
        "DP-2"
      ];
      width = 3840;
      height = 2160;
      refreshRate = 240;
      nvidia = false;

      microphoneHack = true;

      backup = {
        toSuperFish = true;
        fromSuperFish = true;
      };

      disks = {
        boot = {
          diskUuid = "A4CE-53EE";
          type = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };
        root = {
          luksUuid = "3ea45185-1664-42c7-af17-2061fdaad3cf";
          diskUuid = "296702af-bfd2-4f9b-b7bf-c15d4cfdf98a";
          type = "f2fs";
          options = [ "noatime" ];
        };
        swap = {
          luksUuid = "786cbc52-d2b8-4b5e-8038-8d47e636e088";
          diskUuid = "7f6f8f5d-4436-4063-9e17-b3cc94602745";
        };
      };
    };
  };
}
