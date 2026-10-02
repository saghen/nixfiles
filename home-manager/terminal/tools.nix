{ pkgs, config, ... }:
{
  # rust packages
  home.sessionPath = [ "$HOME/.config/cargo/bin" ];

  home.packages = with pkgs; [
    # tools
    wl-clipboard # many programs expect in path
    nh # nix helper
    procps # pkill watch top sysctl etc...
    eza # better ls
    fd # better find
    sd # better sed
    jq # transform json
    yq-go # jq for yaml
    fzf # fuzzy finder
    gh # github cli FIXME: stores credentials in plain text
    trash-cli # put items into the trash
    playerctl # interact with mpris players
    pulseaudio # utilities like pactl
    ast-grep # structural code search
    tokei # count LoC

    # agents
    llm-agents.claude-code
    llm-agents.codex
    llm-agents.pi

    # devops
    kubectl
    kustomize
    kubectx # fast namespace and context switching
    kubecolor # colorized kubectl output
    kubernetes-helm # k8s package manager

    # languages
    go
    python3
    bun
    nodejs_24
    corepack_24
    gcc
    gnumake
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
      "miri"
    ])
    rust-analyzer-nightly
    pkg-config
  ];

  # Move a bunch of random dirs to XDG dirs
  home.sessionVariables =
    let
      home = "/home/${config.home.username}";
      cache = "${home}/.cache";
      cfg = "${home}/.config";
      data = "${home}/.local/share";
      state = "${home}/.local/state";
      # todo: find the UID of the user
      runtime = "/run/user/1000";
    in
    {
      CUDA_CACHE_PATH = "${cache}/nv";
      PNPM_HOME = "${data}/pnpm";
      NODE_REPL_HISTORY = "${data}/node_repl_history";
      NPM_CONFIG_PREFIX = "${data}/npm";
      NPM_CONFIG_CACHE = "${cache}/npm";
      NPM_CONFIG_TMP = "${runtime}/npm";
      NPM_CONFIG_IGNORE_SCRIPTS = "true";
      NPM_CONFIG_MIN_RELEASE_AGE = "3"; # days
      CARGO_HOME = "${cfg}/cargo";
      RUSTUP_HOME = "${data}/rust";
      GOPATH = "${data}/go";
      W3M_DIR = "${data}/w3m";
      XCOMPOSECACHE = "${cache}/X11/xcompose";
      KUBECONFIG = "${cfg}/kube/config";
      KREW_ROOT = "${data}/krew";
      DOCKER_CONFIG = "${cfg}/docker";
      PYTHON_HISTORY = "${state}/python/history";
      HISTFILE = "${state}/bash/history";
    };
  xdg.configFile = {
    bunfig = {
      target = ".bunfig.toml";
      text = ''
        [install]
        minimumReleaseAge = 259200 # 3 days
      '';
    };
    cargo = {
      target = "cargo/config.toml";
      text = ''
        [net]
        git-fetch-with-cli = true
      '';
    };
  };

  services = {
    ssh-agent.enable = true;

    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-tty;
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "github.com" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = "~/.ssh/id_github";
          IdentitiesOnly = true;
        };
        "hf.co" = {
          HostName = "hf.co";
          User = "git";
          IdentityFile = "~/.ssh/id_hf";
          IdentitiesOnly = true;
        };
        "otoro" = {
          ForwardAgent = true;
        };
      };
    };

    gpg = {
      enable = true;
      settings.pinentry-mode = "loopback";
    };

    # cat with syntax highlighting
    bat = {
      enable = true;
      config.theme = "base16";
    };

    git = {
      enable = true;
      lfs.enable = true;
      maintenance = {
        enable = true;
        repositories =
          let
            root = "${config.home.homeDirectory}/code";
            repos = [
              "nvim/blink.cmp"
              "nvim/blink.pairs"
              "nvim/blink.indent"
              "nvim/tuque"
              "personal/frizbee"
              "personal/limbo"
            ];
          in
          map (path: "${root}/${path}") repos;
      };
      signing = {
        signByDefault = true;
        key = "A8F94F230A4470B1";
        format = "openpgp";
      };
      settings = {
        init.defaultBranch = "main";
        pull.rebase = true;
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        commit.verbose = true;
        core = {
          fsmonitor = true;
          untrackedCache = true;
        };

        user = {
          email = "liamcdyer@gmail.com";
          name = "Liam Dyer";
        };

        url = {
          "ssh://git@github.com" = {
            insteadOf = "https://github.com";
          };
          "ssh://git@hf.co" = {
            insteadOf = "https://huggingface.co";
          };
        };
      };
    };

    # better grep
    ripgrep = {
      enable = true;
      arguments = [
        "--smart-case"
        "--colors"
        "match:fg:magenta"
      ];
    };

    # z for jumping between directories
    zoxide.enable = true;
  };
}
