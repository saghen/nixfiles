{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    # fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      noto-fonts-color-emoji
      cantarell-fonts

      (callPackage ./feather { })
      (callPackage ./iosevka-nerd { })
      (callPackage ./operator-nerd { })
    ];
  };
}
