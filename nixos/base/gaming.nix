{ inputs, pkgs, ... }:
{
  # controller support
  hardware.xone.enable = true;

  # games
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [ mangohud ];
    extraCompatPackages = [ inputs.proton-cachyos.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
  };
}
