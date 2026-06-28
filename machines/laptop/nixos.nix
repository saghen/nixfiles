{ inputs, ... }:
{
  # hardware-specific modules
  # TODO: use framework specific module
  imports = [ inputs.hardware.nixosModules.framework-amd-ai-300-series ];

  config = {
    networking.hostName = "liam-laptop";
    networking.hostId = "968d12a1";

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
