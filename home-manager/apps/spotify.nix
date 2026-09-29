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
      # https://code.vexcited.com/spicetify/genres
      ({
        src = pkgs.fetchzip {
          url = "https://code.vexcited.com/spicetify/genres/releases/download/0.1.0/genres-0.1.0.zip";
          hash = "sha256-80WFlkowiaG6+nUXVyE6ULYSlTT4jB93LjczPepcNqk=";
          stripRoot = false;
        };
        name = "index.js";
      })
    ];
  };
}
