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

        container = {
          format = "[$symbol]($style) ";
          style = "bold red";
        };

        # Replace the "❯" symbol in the prompt with "~>"
        character = {
          success_symbol = "[~>](green)";
          error_symbol = "[~>](blue)";
        };

        # Pure preset
        # https://starship.rs/presets/pure-preset
        # with my own customizations
        format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$c$cmake$cobot$crystal$dart$elixer$elm$fennel$golang$guix_shell$haskell$haxe$java$julia$kotlin$lua$meson$nim$nix_shell$nodejs$ocaml$perl$php$pijul_channel$python$rlang$ruby$rust$scala$swift$zig$line_break$character";
        directory.style = "blue";
        git_branch = {
          format = "[$branch]($style)";
          style = "bright-black";
        };
        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style = "cyan";
          conflicted = "";
          untracked = "";
          modified = "";
          staged = "";
          renamed = "";
          deleted = "";
        };
        git_state = {
          format = "([$state( $progress_current/$progress_total)]($style)) ";
          style = "bright-black";
        };
        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
        };
        python = {
          format = "[$virtualenv]($style) ";
          style = "bright-black";
        };

        # Nerd Font symbols
        # https://starship.rs/presets/nerd-font
        aws.symbol = "  ";
        buf.symbol = " ";
        c.symbol = " ";
        conda.symbol = " ";
        crystal.symbol = " ";
        dart.symbol = " ";
        directory.read_only = " 󰌾";
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        fennel.symbol = " ";
        fossil_branch.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = " ";
        guix_shell.symbol = " ";
        haskell.symbol = " ";
        haxe.symbol = " ";
        hg_branch.symbol = " ";
        hostname.ssh_symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        kotlin.symbol = " ";
        lua.symbol = " ";
        memory_usage.symbol = "󰍛 ";
        meson.symbol = "󰔷 ";
        nim.symbol = "󰆥 ";
        nix_shell.symbol = " ";
        nodejs.symbol = " ";
        ocaml.symbol = " ";
        os.symbols = {
          Alpaquita = " ";
          Alpine = " ";
          AlmaLinux = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          Artix = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "󰛓 ";
          Gentoo = " ";
          HardenedBSD = "󰞌 ";
          Illumos = "󰈸 ";
          Kali = " ";
          Linux = " ";
          Mabox = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = "󰈺 ";
          openSUSE = " ";
          OracleLinux = "󰌷 ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          RockyLinux = " ";
          Redox = "󰀘 ";
          Solus = "󰠳 ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Void = " ";
          Windows = "󰍲 ";
        };
        package.symbol = "󰏗 ";
        perl.symbol = " ";
        php.symbol = " ";
        pijul_channel.symbol = " ";
        python.symbol = " ";
        rlang.symbol = "󰟔 ";
        ruby.symbol = " ";
        rust.symbol = " ";
        scala.symbol = " ";
        swift.symbol = " ";
        zig.symbol = " ";

        # No runtime versions preset
        # https://starship.rs/presets/no-runtimes
        # modified with no "via "
        bun.format = "[$symbol]($style) ";
        cmake.format = "[$symbol]($style) ";
        cobol.format = "[$symbol]($style) ";
        daml.format = "[$symbol]($style) ";
        deno.format = "[$symbol]($style) ";
        dotnet.format = "[$symbol(🎯 $tfm )]($style) ";
        elixir.format = "[$symbol]($style) ";
        elm.format = " [$symbol]($style) ";
        erlang.format = "[$symbol]($style) ";
        fennel.format = "[$symbol]($style) ";
        golang.format = "[$symbol]($style) ";
        gradle.format = "[$symbol]($style) ";
        haxe.format = "[$symbol]($style) ";
        helm.format = "[$symbol]($style) ";
        java.format = "[$symbol]($style) ";
        julia.format = "[$symbol]($style) ";
        kotlin.format = "[$symbol]($style) ";
        lua.format = "[$symbol]($style) ";
        meson.format = "[$symbol]($style) ";
        nim.format = "[$symbol]($style) ";
        nodejs.format = "[$symbol]($style) ";
        ocaml.format = "[$symbol(($switch_indicator$switch_name) )]($style) ";
        opa.format = "[$symbol]($style) ";
        perl.format = "[$symbol]($style) ";
        php.format = "[$symbol]($style) ";
        pulumi.format = "[$symbol$stack]($style) ";
        purescript.format = "[$symbol]($style) ";
        # python = { format = "[$symbol]($style) "; };
        quarto.format = "[$symbol]($style) ";
        raku.format = "[$symbol]($style) ";
        red.format = "[$symbol]($style) ";
        rlang.format = "[$symbol]($style) ";
        ruby.format = "[$symbol]($style) ";
        rust.format = "[$symbol]($style) ";
        solidity.format = "[$symbol]($style) ";
        typst.format = "[$symbol]($style) ";
        swift.format = "[$symbol]($style) ";
        vagrant.format = "[$symbol]($style) ";
        vlang.format = "[$symbol]($style) ";
        zig.format = "[$symbol]($style) ";
      };
    };
  };
}
