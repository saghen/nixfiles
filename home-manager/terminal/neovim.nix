# Requires cloning nvim config manually
# git clone https://github.com/saghen/nvim ~/.config/nvim
{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  home.sessionVariables.VISUAL = "nvim";
  home.sessionVariables.PAGER = "nvim +Man!";

  sops.secrets.neovim = {
    sopsFile = ../../keys/sops/neovim.yaml;
    path = "${config.xdg.configHome}/nvim/lua/secrets.lua";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

    extraLuaConfig = ''
      -- required for smart-open.nvim
      vim.g.sqlite_clib_path = "${pkgs.sqlite.out}/lib/libsqlite3.so"
      vim.g.cpptools_debugger_path = "${pkgs.vscode-extensions.ms-vscode.cpptools}/extension/debugAdapters/bin/OpenDebugAD7"

      vim.g.colors = {
        crust = "${config.colors.crust}",
        mantle = "${config.colors.mantle}",
        base = "${config.colors.base}",
        core = "${config.colors.core}",

        surface_0 = "${config.colors.surface-0}",
        surface_1 = "${config.colors.surface-1}",
        surface_2 = "${config.colors.surface-2}",

        overlay_0 = "${config.colors.overlay-0}",
        overlay_1 = "${config.colors.overlay-1}",
        overlay_2 = "${config.colors.overlay-2}",

        subtext_0 = "${config.colors.subtext-0}",
        subtext_1 = "${config.colors.subtext-1}",
        subtext_2 = "${config.colors.subtext-2}",
        text = "${config.colors.text}",

        lavender = "${config.colors.lavender}",
        lavender_dark = "${config.colors.lavender-dark}",

        blue = "${config.colors.blue}",
        blue_dark = "${config.colors.blue-dark}",

        sapphire = "${config.colors.sapphire}",
        sapphire_dark = "${config.colors.sapphire-dark}",

        sky = "${config.colors.sky}",
        sky_dark = "${config.colors.sky-dark}",

        teal = "${config.colors.teal}",
        teal_dark = "${config.colors.teal-dark}",

        green = "${config.colors.green}",
        green_dark = "${config.colors.green-dark}",

        yellow = "${config.colors.yellow}",
        yellow_dark = "${config.colors.yellow-dark}",

        peach = "${config.colors.peach}",
        peach_dark = "${config.colors.peach-dark}",

        maroon = "${config.colors.maroon}",
        maroon_dark = "${config.colors.maroon-dark}",

        red = "${config.colors.red}",
        red_dark = "${config.colors.red-dark}",

        mauve = "${config.colors.mauve}",
        mauve_dark = "${config.colors.mauve-dark}",

        pink = "${config.colors.pink}",

        flamingo = "${config.colors.flamingo}",

        rosewater = "${config.colors.rosewater}",

        cyan = "${config.colors.cyan}",
      }

      local success = pcall(require, 'secrets')
      if not success then vim.notify('secrets.lua not found', vim.log.levels.ERROR) end

      -- bootstrap lazy.nvim, lazyvim and my plugins
      require('config.lazy')
    '';

    # for blink-tree
    extraWrapperArgs = [
      "--suffix"
      "LD_LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [ pkgs.libgit2 ]}"
    ];

    extraPackages = with pkgs; [
      tree-sitter

      # Luarocks
      lua51Packages.luarocks
      lua51Packages.lua

      # Voice recording for gp.nvim
      alsa-utils # for arecord
      (sox.override { enableLame = true; })

      ## LSPs, formatters, linters
      efm-langserver
      # kubernetes
      helm-ls
      yaml-language-server
      # lua
      (pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        pname = "emmylua_ls";
        version = "0.13.0";

        buildAndTestSubdir = "crates/emmylua_ls";
        cargoHash = "sha256-SbsYlIVWDpBU2bxJqXUtOiMHkOoa8Up27X7rVKLLLm0=";

        src = fetchFromGitHub {
          owner = "EmmyLuaLs";
          repo = "emmylua-analyzer-rust";
          tag = finalAttrs.version;
          hash = "sha256-93PlsVvlUravsnW7YBCii04jCEJPP+6U2vYbVBjcX8M=";
        };
      }))
      lua-language-server
      stylua
      # go
      gopls
      # misc
      bash-language-server
      dockerfile-language-server
      postgres-language-server
      harper # grammar/spelling
      # nix
      nil
      nixfmt
      # python
      ruff
      basedpyright
      # rust
      # NOTE: rust-analyzer is managed by fenix
      graphviz # for crate graph visualization
      # terraform
      terraform-ls
      terraform # required by lsp for formatting
      tflint
      # web
      prettierd
      vscode-langservers-extracted # eslint, css, html, markdown, json
      biome
      typescript
      vtsls
    ];
  };
}
