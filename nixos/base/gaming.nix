{ inputs, pkgs, ... }:
{
  boot.kernelModules = [ "ntsync" ];

  # controller support
  hardware.xone.enable = true;

  # games
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [ mangohud ];
    extraCompatPackages = [
      inputs.proton-cachyos.packages.${pkgs.stdenv.hostPlatform.system}.proton-cachyos-v3 # x86-64-v3 build
    ];
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
  };
}
