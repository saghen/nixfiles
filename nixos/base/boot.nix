{ pkgs, inputs, ... }:
{
  # enable linux-firmware
  hardware.enableRedistributableFirmware = true;

  # cachyos kernel
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.default ];
  boot =
    let
      kernel = pkgs.cachyosKernels.linux-cachyos-latest.override {
        lto = "full";
        processorOpt = "zen4";
        autofdo = true; # basic PGO
        cpusched = "bore"; # outperforms eevdf in games
        performanceGovernor = true;
        bbr3 = true; # TCP congestion control
      };
      kernelPackages =
        let
          # helpers.nix provides a few utilities for building kernel with LTO.
          # I haven't figured out a clean way to expose it in flakes.
          helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };
        in
        helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor kernel);

    in
    {
      kernelPackages = kernelPackages;

      # 1000hz keyboard polling rate
      # who knows if that actually does anything
      kernelParams = [
        "quiet"
        "usbhid.kbpoll=1"
        "split_lock_detect=off" # slight gaming speed-up potentially (unmeasured)
      ];

      loader = {
        efi.canTouchEfiVariables = true;
        timeout = 5;
        systemd-boot.enable = true;
      };

      # Loading animation and LUKS password prompt
      initrd.systemd.enable = true;
      plymouth = {
        enable = true;
        extraConfig = ''
          [Daemon]
          ShowDelay=0
        '';
        theme = "breeze";
      };
    };
}
