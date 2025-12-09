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
            rev = "b833f2d94ea6c59262f433857083e377b2522b52";
            hash = "sha256-sGmqgL+UmFw587yfBHWT/UvcOI7+TkXb+IOFZGB+reo=";
          })
          + /dist;

        name = "whatsThatGenre.js";
      }
    ];
  };
}
