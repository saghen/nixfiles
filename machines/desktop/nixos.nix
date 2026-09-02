{
  inputs,
  config,
  ...
}:
{
  # hardware-specific modules
  imports = with inputs.hardware.nixosModules; [
    common-cpu-amd
    common-gpu-amd
    common-pc-ssd
  ];

  config = {
    networking.hostName = "liam-desktop";
    networking.hostId = "968d12a1";

    # serve the nix store to the laptop as a binary cache
    sops.secrets.harmonia.sopsFile = ../../keys/sops/harmonia.yaml;
    services.harmonia.cache = {
      enable = true;
      signKeyPaths = [ config.sops.secrets.harmonia.path ];
      # prefer this cache over cache.nixos.org (priority 40, lower wins)
      settings.priority = 30;
    };
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5000 ];
  };
}
