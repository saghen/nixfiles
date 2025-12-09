{
  config,
  pkgs,
  firefox-nightly,
  ...
}:
{
  home = {
    sessionVariables = {
      BROWSER = "firefox-developer-edition";
    };
  };

  programs.firefox = {
    enable = true;
    package = firefox-nightly.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin;

    profiles = {
      saghen = {
        isDefault = true;

        userChrome = builtins.readFile ./userChrome.css;
        userContent = builtins.readFile ./userContent.css;

        settings = {
          # required for userChrome.css and userContent.css
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          "browser.aboutConfig.showWarning" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.contentblocking.category" = "strict";
          "browser.newtabpage.activity-stream.feeds.section.highlights" = true;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "full-screen-api.warning.timeout" = -1; # Disable fullscreen warning

          "middlemouse.paste" = false;

          # fractional scaling
          "layout.css.devPixelsPerPx" = config.machine.scalingFactor;

          # always ask for download location
          "browser.download.useDownloadDir" = false;

          # don't recommend text in forms
          "browser.formfill.enable" = false;
          "dom.forms.autocomplete.formautofill" = false;

          "cookiebanners.service.mode.privateBrowsing" = 1;

          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
          "devtools.toolbox.host" = "right";

          "layout.frame_rate" = config.machine.refreshRate;
          "gfx.webrender.all" = true;

          "privacy.annotate_channels.strict_list.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.query_stripping.enabled" = true;
          "privacy.query_stripping.enabled.pbmode" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;
          # https://news.ycombinator.com/item?id=40952330
          "dom.private-attribution.submission.enabled" = false;

          "services.sync.prefs.sync-seen.browser.newtabpage.pinned" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "network.dns.disablePrefetch" = false;
          "network.predictor.enabled" = true;
          "network.prefetch-next" = true;
        };

        search = {
          force = true;
          default = "Kagi";
          order = [
            "Kagi"
            "ddg"
            "NixOS Wiki"
            "Nix Packages"
            "Nix Options"
            "Home Manager"
            "Arch Wiki"
            "Arch Packages"
            "AUR"
            "NPM"
          ];
          engines =
            let
              updateInterval = 24 * 60 * 60 * 1000; # every day
            in
            {
              "Kagi" = {
                urls = [
                  { template = "https://kagi.com/search?q={searchTerms}"; }
                  {
                    template = "https://kagi.com/api/autosuggest?q={searchTerms}";
                    type = "application/x-suggestions+json";
                  }
                ];
                icon = "https://assets.kagi.com/v2/favicon-32x32.png";
                updateInterval = updateInterval;
                definedAliases = [
                  "@kagi"
                  "@k"
                ];
              };
              "NixOS Wiki" = {
                urls = [
                  {
                    template = "https://nixos.wiki/index.php?search={searchTerms}";
                  }
                ];
                icon = "https://nixos.wiki/favicon.png";
                updateInterval = updateInterval;
                definedAliases = [ "nw" ];
              };
              "Nix Packages" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "np" ];
              };
              "Nix Options" = {
                urls = [
                  {
                    template = "https://search.nixos.org/options";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "no" ];
              };
              "Noogle" = {
                urls = [
                  {
                    template = "https://noogle.dev/q";
                    params = [
                      {
                        name = "term";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "nx" ];
              };
              "Home Manager" = {
                urls = [
                  {
                    template = "https://home-manager-options.extranix.com/?query={searchTerms}";
                  }
                ];
                icon = "https://home-manager-options.extranix.com/images/favicon.png";
                updateInterval = updateInterval;
                definedAliases = [ "hm" ];
              };
              "NPM" = {
                urls = [ { template = "https://www.npmjs.com/package/{searchTerms}"; } ];
                icon = "https://static-production.npmjs.com/b0f1a8318363185cc2ea6a40ac23eeb2.png";
                updateInterval = updateInterval;
                definedAliases = [ "npm" ];
              };
            };
        };
      };
    };
  };
}
