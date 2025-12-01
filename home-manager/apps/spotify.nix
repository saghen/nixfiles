# https://github.com/Gerg-L/spicetify-nix
{
  pkgs,
  spicetify-nix,
  ...
}:
let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with spicePkgs.extensions; [
      hidePodcasts
      bookmark
      {
        src =
          (pkgs.fetchFromGitHub {
            owner = "LucasOe";
            repo = "spicetify-genres";
            rev = "38db860f7997edc2ee1c40445938e6c824e92c1c";
            hash = "sha256-iXyF17RVm0GGrC8rM2Ddlt0xn+1FA1P81oe+OtyMjao=";
          })
          + /dist;

        name = "whatsThatGenre.js";
      }
    ];
  };
}
