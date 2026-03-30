{
  pkgs,
  config,
  ...
}:
{
  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true; # legacy, try removing in a couple years
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
    };

    portal = {
      enable = true;
      configPackages = with pkgs; [
        xdg-desktop-portal-gnome
      ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
      ];
      xdgOpenUsePortal = true;
    };

    mimeApps =
      let
        firefox = "firefox-nightly.desktop";
        feh = "feh.desktop";
        nomacs = "nomacs.desktop";
        qimgv = "qimgv.desktop";
        nvim = "nvim.desktop";
        files = "org.gnome.Nautilus.desktop";
        mpv = "mpv.desktop";
        vlc = "vlc.desktop";

        player = [
          mpv
          vlc
        ];
        imageViewer = [
          qimgv
          nomacs
          feh
        ];
      in
      {
        enable = true;

        associations.added = {
          "inode/directory" = [ files ];

          "audio/aac" = player;
          "audio/flac" = player;
          "audio/mpeg" = player;
          "audio/ogg" = player;
          "audio/opus" = player;
          "audio/wav" = player;
          "audio/webm" = player;

          "video/x-msvideo" = player; # avi
          "video/mp4" = player;
          "video/mpeg" = player;
          "video/ogg" = player;
          "video/mp2t" = player;
          "video/webm" = player;
          "video/matroska" = player;

          "image/jpeg" = imageViewer;
          "image/heic" = imageViewer;
          "image/heif" = imageViewer;
          "image/png" = imageViewer;
          "image/apng" = imageViewer;
          "image/gif" = imageViewer;
          "image/webp" = imageViewer;
          "image/avif" = imageViewer;
          "image/bmp" = imageViewer;
          "image/ico" = imageViewer;
          "image/tiff" = imageViewer;
          "image/svg+xml" = imageViewer;

          "text/html" = [
            firefox
            nvim
          ];

          "application/pdf" = [ firefox ];

          "x-scheme-handler/http" = [ firefox ];
          "x-scheme-handler/https" = [ firefox ];
          "x-scheme-handler/about" = [ firefox ];
          "x-scheme-handler/unknown" = [ firefox ];
          "x-scheme-handler/webcal" = [ firefox ];
        };
        defaultApplications = {
          "x-scheme-handler/http" = [ firefox ];
          "x-scheme-handler/https" = [ firefox ];
          "x-scheme-handler/about" = [ firefox ];
          "x-scheme-handler/unknown" = [ firefox ];
          "x-scheme-handler/webcal" = [ firefox ];

          "audio/*" = [ vlc ];
          "video/*" = [ mpv ];
          "image/*" = [ qimgv ];
          "inode/directory" = [ files ];

          "application/json" = [ nvim ];
          "text/*" = [ nvim ];
          "text/html" = [ firefox ];
        };
      };
  };
}
