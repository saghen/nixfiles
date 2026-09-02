{
  config,
  pkgs,
  ...
}:
{
  # for krew
  home.sessionPath = [ "${config.home.sessionVariables.KREW_ROOT}/bin" ];

  programs = {
    # Fish enables this by default for autocomplete but it adds +4s to build
    man.generateCaches = false;
    fish = {
      enable = true;
      functions = {
        l = "eza";
        # disables greeting
        fish_greeting = "";
        # color for kubectl
        kubectl = "kubecolor $argv";
        # nix
        nr = "nix run nixpkgs#$argv[1] $argv[2..-1]";
        ns = "nix-shell --run fish $argv";
        nsp = "nix-shell --run fish -p $argv";
        nb = "nix build nixpkgs#$argv";
        nbp = "nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}' $argv";

        npr = "npm run --silent $argv";
        pnpr = "pnpm run --silent $argv";

        # customize transcient prompt
        starship_transient_prompt_func = "starship module directory && starship module character";

        hibernate = "systemctl hibernate";
      };
      shellAbbrs = {
        cd = "z";
        n = "nvim";
        e = "exit";

        jcu = "journalctl --user -xeu";
        jc = "journalctl -xeu";

        nd = "nix develop";
        nrs = "nh os switch";

        # kubectl
        k = "kubectl";
        kx = "kubectx";
        kn = "kubens";
        kg = "kubectl get";
        kd = "kubectl describe";
        kdel = "kubectl delete";

        kgp = "kubectl get pod";
        kgpw = "kubectl get pod -w";
        kgpy = "kubectl get pod -o yaml";
        kdp = "kubectl describe pod";
        kdelp = "kubectl delete pod";

        kgs = "kubectl get services";
        kgsy = "kubectl get services -o yaml";
        kds = "kubectl describe service";
        kdels = "kubectl delete service";

        kgr = "kubectl get replicaset";
        kgry = "kubectl get replicaset -o yaml";
        kdr = "kubectl describe replicaset";
        kdelr = "kubectl delete replicaset";

        kgd = "kubectl get deployment";
        kgdy = "kubectl get deployment -o yaml";
        kdd = "kubectl describe deployment";
        kdeld = "kubectl delete deployment";

        kgss = "kubectl get statefulset";
        kgssy = "kubectl get statefulset -o yaml";
        kdss = "kubectl describe statefulset";
        kdelss = "kubectl delete statefulset";

        kgcm = "kubectl get configmap";
        kgcmy = "kubectl get configmap -o yaml";
        kdcm = "kubectl describe configmap";
        kdelcm = "kubectl delete configmap";

        kl = "kubectl logs";
        klf = "kubectl logs -f";
        klc = "kubectl logs --container";
        klfc = "kubectl logs -f --container";
      };
      interactiveShellInit = ''
        # Use backward-kill-bigword to act like W in vim
        bind \b backward-kill-word
        bind \t complete-and-search

        # use fish for nix shells
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish | source
      '';
      plugins = with pkgs.fishPlugins; [
        {
          name = "autopair";
          src = autopair.src;
        }
        # text expansions such as .., !! and others
        {
          name = "puffer";
          src = puffer.src;
        }
      ];
    };

    # sqlite history
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        style = "compact";
        enter_accept = true;
      };
    };

    # prompt
    starship = {
      enable = true;
      enableTransience = true;
      settings = {
        # instead of this, we defined a function --on-event fish-prompt that runs echo
        add_newline = true;

        format = "$username$hostname$directory$cmd_duration$nix_shell$python$line_break$character";
        character = {
          success_symbol = "[~>](green)";
          error_symbol = "[~>](blue)";
        };
        directory.style = "blue";
        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
        };
        nix_shell.symbol = " ";
        python = {
          symbol = " ";
          format = "[$virtualenv]($style) ";
          style = "bright-black";
        };
      };
    };
  };
}
