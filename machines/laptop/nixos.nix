{
  config,
  inputs,
  pkgs,
  ...
}:
{
  # hardware-specific modules
  imports = [ inputs.hardware.nixosModules.framework-amd-ai-300-series ];

  config = {
    networking.hostName = "liam-laptop";

    # offload builds to the desktop over tailscale
    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        hostName = "desktop";
        sshUser = "nix-builder";
        protocol = "ssh-ng";
        system = "x86_64-linux";
        maxJobs = 8;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
        # the nix daemon connects as root, which has no known_hosts entry.
        # base64 of the desktop's tailscale ssh ed25519 host key
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUgzZjBnRWF1c3RqZjFlUmpHL3ROT01yd2dhT0tuWU1JN3k3RkFTWVMvSUg=";
      }
    ];
    nix.settings = {
      # fetch from caches on desktop
      builders-use-substitutes = true;
      # pull already-built paths from the desktop's store (harmonia)
      extra-substituters = [ "http://desktop:5000" ];
      extra-trusted-public-keys = [ "liam-desktop-1:hJbtnobnyrG3TE5oIYHzAOG1co9z6brCMP/6H0C2YO4=" ];
      connect-timeout = 3; # giveup quickly on unreachable
    };

    # automatic firmware updates: fwupdmgr update
    services.fwupd.enable = true;

    # recommended over TLP by framework team
    services.power-profiles-daemon.enable = true;

    services.udev.extraRules =
      let
        syncthing =
          action:
          ''RUN+="${pkgs.systemd}/bin/systemctl --user --machine=saghen@ --no-block ${action} syncthing.service"'';
      in
      ''
        # stop syncthing on battery and start it again when plugged in
        ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="ACAD", ATTR{online}=="0", ${syncthing "stop"}
        ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="ACAD", ATTR{online}=="1", ${syncthing "start"}
      '';

    boot.kernelParams = [
      # watchdog periodically wakes every cpu to try to stop deadlocks
      # but this wastes power, especially at idle, disable it
      "nowatchdog" # periodically wakes every cpu
      # disable adaptive backlight management (saves power but looks significantly worse)
      # setting this to 1 saves around 0.5W, leaving it at -1 lets the userspace adjust
      "amdgpu.abmlevel=0"
    ];

    # batch writeback to disk every 15s rather than 5s
    boot.kernel.sysctl."vm.dirty_writeback_centisecs" = 1500;

    networking.networkmanager.wifi.powersave = true;

    # hibernate after 6 hours of suspend
    boot.resumeDevice = "/dev/disk/by-uuid/${config.machine.disks.swap.diskUuid}";
    systemd.sleep.settings.Sleep.HibernateDelaySec = "6h";
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleSuspendKey = "suspend-then-hibernate";
    };

    # faster boot, no black flash during plymouth luks password prompt
    hardware.amdgpu.initrd.enable = false;

    # enable fingerprint reader
    # register fingers via: sudo fprintd-enroll saghen -f finger
    services.fprintd.enable = true;

    # enable PAM fingerprint authentication
    security.pam.services = {
      sudo.fprintAuth = true;
      polkit-1.fprintAuth = true;
    };

    # fix built-in microphone: https://github.com/NixOS/nixos-hardware/issues/1603
    services.pipewire.wireplumber.extraConfig.no-ucm = {
      "monitor.alsa.properties" = {
        "alsa.use-ucm" = false;
      };
    };
  };
}
