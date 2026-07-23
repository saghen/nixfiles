{ pkgs, ... }:
rec {
  # Cursor theme (system-wide)
  home.pointerCursor = {
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    gtk.enable = true;
    x11.enable = true;
  };

  # Icon theme (system-wide)
  gtk.iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };
  # expected by many gtk apps
  home.packages = with pkgs; [
    adwaita-icon-theme
    xsettingsd
  ];

  # GTK Theme
  gtk.theme = {
    name = "Colloid-Teal-Dark-Catppuccin";
    package = pkgs.colloid-gtk-theme.override {
      colorVariants = [ "dark" ];
      themeVariants = [ "teal" ];
      sizeVariants = [ "standard" ];
      # "black" = mocha variant
      tweaks = [
        "catppuccin"
        "black"
        "rimless"
      ];
    };
  };
  xdg.configFile = {
    "gtk-3.0/assets".source = "${gtk.theme.package}/share/themes/${gtk.theme.name}/gtk-3.0/assets";
    "gtk-3.0/gtk.css".source = "${gtk.theme.package}/share/themes/${gtk.theme.name}/gtk-3.0/gtk.css";
    "gtk-3.0/gtk-dark.css".source =
      "${gtk.theme.package}/share/themes/${gtk.theme.name}/gtk-3.0/gtk-dark.css";

    "gtk-4.0/assets".source = "${gtk.theme.package}/share/themes/${gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${gtk.theme.package}/share/themes/${gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${gtk.theme.package}/share/themes/${gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  # Misc GTK configuration
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Colloid-Teal-Dark-Catppuccin";
      color-scheme = "prefer-dark";
    };
    "org/gtk/settings/file-chooser" = {
      sort-directories-first = true;
    };
  };

  # TODO: QT Theme
  qt.style = { };
}
