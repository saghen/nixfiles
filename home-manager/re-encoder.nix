{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.re-encoder.homeManagerModules.default ];

  services.re-encoder = {
    enable = config.machine.reEncoder;
    monitor.claude = pkgs.llm-agents.claude-code;
  };
}
