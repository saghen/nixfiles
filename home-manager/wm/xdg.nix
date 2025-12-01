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
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      config.common.default = "*";
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
      in
      {
        enable = true;

        associations.added = {
          "inode/directory" = [ files ];

          "audio/aac" = [
            mpv
            vlc
          ];
          "audio/flac" = [
            mpv
            vlc
          ];
          "audio/mpeg" = [
            mpv
            vlc
          ];
          "audio/ogg" = [
            mpv
            vlc
          ];
          "audio/opus" = [
            mpv
            vlc
          ];
          "audio/wav" = [
            mpv
            vlc
          ];
          "audio/webm" = [
            mpv
            vlc
          ];

          "video/x-msvideo" = [
            mpv
            vlc
          ]; # avi
          "video/mp4" = [
            mpv
            vlc
          ];
          "video/mpeg" = [
            mpv
            vlc
          ];
          "video/ogg" = [
            mpv
            vlc
          ];
          "video/mp2t" = [
            mpv
            vlc
          ];
          "video/webm" = [
            mpv
            vlc
          ];
          "video/matroska" = [
            mpv
            vlc
          ];

          "image/jpeg" = [
            qimgv
            nomacs
            feh
          ];
          "image/heic" = [
            qimgv
            nomacs
            feh
          ];
          "image/heif" = [
            qimgv
            nomacs
            feh
          ];
          "image/png" = [
            qimgv
            nomacs
            feh
          ];
          "image/apng" = [
            qimgv
            nomacs
            feh
          ];
          "image/gif" = [
            qimgv
            nomacs
            feh
          ];
          "image/webp" = [
            qimgv
            nomacs
            feh
          ];
          "image/avif" = [
            qimgv
            nomacs
            feh
          ];
          "image/bmp" = [
            qimgv
            nomacs
            feh
          ];
          "image/ico" = [
            qimgv
            nomacs
            feh
          ];
          "image/tiff" = [
            qimgv
            nomacs
            feh
          ];
          "image/svg+xml" = [
            qimgv
            nomacs
            feh
            nvim
            firefox
          ];

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
