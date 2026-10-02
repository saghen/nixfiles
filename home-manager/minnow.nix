{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.minnow.homeManagerModules.default ];

  services.minnow = {
    enable = config.machine.minnow;
    monitor.claude = pkgs.llm-agents.claude-code;
  };
}
