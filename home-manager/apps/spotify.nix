# https://github.com/Gerg-L/spicetify-nix
{
  pkgs,
  spicetify-nix,
  ...
}:
let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  # TODO: drop this, not needed anymore
  # https://github.com/Gerg-L/spicetify-nix/issues/374
  pkgsPinned =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/67650575de1a9c27262b96b2608f7d41ae311a0b.tar.gz";
        sha256 = "00c729p8gqka57hbvsx09rxmbzc3g05pxgv0vgg5h0jcnghap3sr";
      })
      {
        inherit (pkgs) system;
        config.allowUnfreePredicate = pkg: (pkgs.lib.getName pkg == "spotify");
      };
in
{
  imports = [ spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;
    spicetifyPackage = pkgsPinned.spicetify-cli;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with spicePkgs.extensions; [
      hidePodcasts
      bookmark
      betterGenres
    ];
  };
}
