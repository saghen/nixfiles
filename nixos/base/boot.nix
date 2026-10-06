{
  pkgs,
  inputs,
  config,
  ...
}:
{
  # enable linux-firmware
  hardware.enableRedistributableFirmware = true;

  # cachyos kernel
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.default ];
  boot = {
    # stock kernel when optimizing for power, since the cachyos build is tuned for performance
    kernelPackages =
      if config.machine.optimizePower then
        pkgs.linuxPackages_latest
      else
        let
          kernel = pkgs.cachyosKernels.linux-cachyos-latest.override {
            # clang LTO builds (thin and full) currently fail on 7.2, both here (objtool: "bad
            # .discard.annotate_insn entry") and in upstream's hydra. autofdo requires LTO, and
            # without a profile it only adds profiling metadata anyway
            lto = "none";
            processorOpt = "zen4";
            cpusched = "bore"; # outperforms eevdf in games
            performanceGovernor = true;
            bbr3 = true; # TCP congestion control
          };
          # helpers.nix provides a few utilities for building kernel with LTO.
          # I haven't figured out a clean way to expose it in flakes.
          helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };
        in
        helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor kernel);

    # 1000hz keyboard polling rate
    # who knows if that actually does anything
    kernelParams = [
      "quiet"
      "usbhid.kbpoll=1"
      "split_lock_detect=off" # slight gaming speed-up potentially (unmeasured)
      "fbcon=vc:2-63" # keep the text console off tty1 so that boot messages don't get shown
    ];

    kernel.sysctl."vm.max_map_count" = 1048576;

    loader = {
      efi.canTouchEfiVariables = true;
      # hidden unless a key (i.e. space) is held while booting
      timeout = 0;
      systemd-boot.enable = true;
    };

    # slightly faster boot due to smaller read, nix defaults to -10
    initrd.compressorArgs = [
      "-19"
      "-T0"
    ];

    # loading animation and LUKS password prompt
    initrd.systemd.enable = true;
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };

  # leave plymouth's last frame on screen until niri starts
  systemd.services.plymouth-quit.serviceConfig.ExecStart = [
    ""
    "-${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
  ];
}
