# TODO: build for march=native
{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./base
    ./fonts
    ../modules/machine.nix
  ];

  system.stateVersion = "24.05";

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Defaults to powersave without this
  powerManagement.cpuFreqGovernor = "performance";

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
    # Some old nix commands don't use XDG dirs, this forces it
    use-xdg-base-directories = true;
    # Number of parallel downloads
    max-substitution-jobs = 32;
    # Cardano IOG cache, devenv and community cachix
    trusted-substituters = [
      "https://cache.iog.io"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    trusted-users = [
      "root"
      "saghen"
    ];
  };

  nixpkgs = {
    overlays = [ inputs.fenix.overlays.default ];
    config.allowUnfree = true;
  };

  users.users.saghen = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  # Trim SSD (https://kokada.capivaras.dev/blog/an-unordered-list-of-hidden-gems-inside-nixos/)
  # Make sure to enable boot.initrd.luks.devices.*.allowDiscards
  services.fstrim.enable = true;
  # Monitor S.M.A.R.T. status
  services.smartd.enable = true;

  # Fish
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;
  programs.command-not-found.enable = false;
  # Fish enables this by default for autocomplete but it adds +15s to build
  documentation.man.generateCaches = false;
}
