# https://github.com/Gerg-L/spicetify-nix
{
  pkgs,
  inputs,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

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
      # Rewrites compositor scroll-driven animations to main-thread ones, otherwise Chromium ticks
      # the compositor at 60Hz forever (even paused and hidden)
      {
        src = ./.;
        name = "sdaFix.js";
      }
      # Turns off Spotify's heavier optional features via its own feature flags (home feed
      # audio/video previews and watch feed, video surfaces, promos) and Canvas
      {
        src = ./.;
        name = "lite.js";
      }
      # Hover-triggered transitions of layout properties (e.g. card footers animating `height`)
      # relayout the page every frame while scrolling under the pointer; apply them instantly
      {
        src = ./.;
        name = "hoverLayoutFix.js";
      }
    ];

    enabledSnippets = [
      # Static now-playing indicator instead of the theme's animated GIF (~7% renderer + 9% GPU
      # while playing)
      '':root { --spice-equalizer: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' fill='%23a6e3a1'%3E%3Crect x='2' y='6' width='3' height='8' rx='1'/%3E%3Crect x='6.5' y='2' width='3' height='12' rx='1'/%3E%3Crect x='11' y='8' width='3' height='6' rx='1'/%3E%3C/svg%3E") !important; }''
      # Spins forever inside a hidden Now Playing action button (~25% of a core while playing)
      ".main-nowPlayingView-loadingSpinner { animation: none !important; }"
      # .Root__main-view is a container query container, which defeats Chromium's incremental
      # layout: any change inside a page relaid out the whole page (~60ms on Home). Making the
      # scroll host a layout boundary brings that to ~4ms (Home click: 436 -> 265ms, layout -83%)
      ".main-view-container__scroll-node { contain: strict; }"
    ];

    # Runs inline in the spiced spotify's postInstall, right before `spicetify apply`
    extraCommands = ''
      # Native overlay scrollbars, for the native-scroll patch below, and Spotify's reduced
      # motion styles (drops most decorative animations)
      gappsWrapperArgs+=(--add-flags --enable-features=OverlayScrollbar --add-flags --force-prefers-reduced-motion)

      # Patch the xpui bundle once spicetify has applied (preFixup runs after postInstall)
      patchXpui() {
        local xpui=$out/share/spotify/Apps/xpui
        chmod u+w $xpui/xpui-modules.js $xpui/user.css
        # Replace OverlayScrollbars (forced layouts on every resize/mutation) with native scrolling
        ${pkgs.python3}/bin/python3 -I ${./patches/native-scroll.py} $xpui/xpui-modules.js
        # Fit page titles with 1-2 forced layouts instead of up to 8
        ${pkgs.python3}/bin/python3 -I ${./patches/title-fit.py} $xpui/xpui-modules.js
        # Render 6 instead of 20 off-screen tracklist rows per edge (filtering/opening lists re-render ~30% less)
        ${pkgs.python3}/bin/python3 -I ${./patches/overscan.py} $xpui/xpui-modules.js
        # Call remote-config exposure (analytics) listeners once per flag instead of on every flag read
        ${pkgs.python3}/bin/python3 -I ${./patches/rc-exposure.py} $xpui
        # Entity header checkVisibility() in the next frame instead of forcing style mid-commit
        ${pkgs.python3}/bin/python3 -I ${./patches/header-visibility-raf.py} $xpui
        # ::-webkit-scrollbar styles would turn the overlay scrollbars back into classic ones
        ${pkgs.python3}/bin/python3 -I ${./patches/strip-scrollbar-css.py} $xpui/user.css
      }
      preFixupHooks+=(patchXpui)
    '';
  };
}
