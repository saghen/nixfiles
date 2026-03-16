{ pkgs, ... }:
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
  home.packages = with pkgs; [
    mpv
    vlc
  ];

  programs.mpv = {
    enable = true;
    config = mpvConfig;
  };
  services.jellyfin-mpv-shim = {
    enable = true;
    mpvConfig = mpvConfig;
  };
}
