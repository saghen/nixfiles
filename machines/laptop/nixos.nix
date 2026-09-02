{ inputs, ... }:
{
  # hardware-specific modules
  # TODO: use framework specific module
  imports = [ inputs.hardware.nixosModules.framework-amd-ai-300-series ];

  config = {
    networking.hostName = "liam-laptop";
    networking.hostId = "968d12a1";

    # offload builds to the desktop over tailscale, with auth via tailscale ssh
    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        hostName = "liam-desktop";
        sshUser = "saghen";
        protocol = "ssh-ng";
        system = "x86_64-linux";
        maxJobs = 8;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
    ];
    nix.settings = {
      # the desktop fetches dependencies from public caches itself
      # instead of routing them through the laptop
      builders-use-substitutes = true;
      # pull already-built paths from the desktop's store (harmonia)
      extra-substituters = [ "http://liam-desktop:5000" ];
      extra-trusted-public-keys = [ "liam-desktop-1:hJbtnobnyrG3TE5oIYHzAOG1co9z6brCMP/6H0C2YO4=" ];
      connect-timeout = 3; # giveup quickly on unreachable
    };

    # automatic firmware updates: fwupdmgr update
    services.fwupd.enable = true;

    # recommended over TLP by framework team
    services.power-profiles-daemon.enable = true;

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
