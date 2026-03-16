{ ... }:
{
  # Bluetooth
  hardware.bluetooth.enable = true;

  # Internet
  networking.useNetworkd = true;
  networking.wireless.iwd.enable = true;
  services.resolved = {
    enable = true;
    settings.Resolve.DNSOverTLS = "true";
  };
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # VPNs
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [ "--ssh" ];
  };
  services.mullvad-vpn.enable = true;
}
