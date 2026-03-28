{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      noto-fonts-color-emoji
      cantarell-fonts
      (callPackage ./iosevka-nerd { })
    ];
  };
}
