{ config, ... }:
{
  imports = [
    ./apps
    ./modules
    ./terminal
    ./wm
    ./super-fish-monitor.nix
    ../modules/machine.nix
  ];
  config = {
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    home = {
      username = "saghen";
      homeDirectory = "/home/${config.home.username}";
      stateVersion = "24.05";
      sessionPath = [ "$HOME/.local/bin" ];
      sessionVariables.NH_FLAKE = "$HOME/code/personal/nixfiles";
      language.base = "en_CA.UTF-8";
    };
  };
}
