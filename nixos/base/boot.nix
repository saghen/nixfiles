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
          # helpers.nix provides a few utilities for building kernel with LTO.
          # I haven't figured out a clean way to expose it in flakes.
          helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };

          # TODO: drop on next nix flake update
          # lld 21.1.8 built by GCC 16 emits broken relocations, causing objtool to fail with
          # "bad .discard.annotate_insn entry". Fixed in LLVM 22.1.8 (llvm/llvm-project@905a88b),
          # so build the kernel with LLVM 22 until nixpkgs' default llvmPackages includes the fix.
          # https://github.com/ClangBuiltLinux/linux/issues/2162
          helpersLLVM22 = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" {
            pkgs = pkgs // {
              pkgsBuildHost = pkgs.pkgsBuildHost // {
                llvmPackages = pkgs.pkgsBuildHost.llvmPackages_22;
              };
              pkgsBuildBuild = pkgs.pkgsBuildBuild // {
                llvmPackages = pkgs.pkgsBuildBuild.llvmPackages_22;
              };
            };
          };

          kernel = pkgs.cachyosKernels.linux-cachyos-latest.override {
            lto = "full";
            processorOpt = "zen4";
            autofdo = true; # basic PGO
            cpusched = "bore"; # outperforms eevdf in games
            performanceGovernor = true;
            bbr3 = true; # TCP congestion control

            # TODO: drop on next nix flake update (see helpersLLVM22)
            stdenv = helpersLLVM22.stdenvLLVM;
            # appended after the default LLVM 21 flags, so these take precedence
            extraMakeFlags = helpersLLVM22.ltoMakeflags;
          };
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

    kernel.sysctl = {
      "vm.max_map_count" = 1048576;

      # flush writes more frequently
      "vm.dirty_bytes" = 268435456;
      "vm.dirty_background_bytes" = 67108864;

      # wake kswapd earlier (1.25% of RAM gap between watermarks, default 0.1%)
      # so allocations in game threads rarely fall into direct reclaim
      "vm.watermark_scale_factor" = 125;
    };

    # multi-gen lru, much better performance under memory pressure
    kernel.sysfs.kernel.mm.lru_gen.min_ttl_ms = 1000;

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
