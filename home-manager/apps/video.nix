{ lib, ... }:
let
  mpvConfig = {
    profile = "high-quality";
    vo = "gpu-next";
    gpu-api = "vulkan";
    gpu-context = "waylandvk";
    hdr-compute-peak = true;
    target-colorspace-hint = true;
    cache = true;
    cache-secs = 3600;
    cache-on-disk = true;
    demuxer-max-bytes = "5000000KiB";
  };
in
{
  programs.mpv = {
    enable = true;
    config = mpvConfig;
  };
  services.jellyfin-mpv-shim = {
    enable = true;
    mpvConfig = mpvConfig;
  };
  systemd.user.services.jellyfin-mpv-shim.Install.WantedBy = lib.mkForce [ ];
}
