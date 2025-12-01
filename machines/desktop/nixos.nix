{
  inputs,
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
  };
}
