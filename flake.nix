{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    nvidia-patch.url = "github:icewind1991/nvidia-patch-nixos";
    nvidia-patch.inputs.nixpkgs.follows = "nixpkgs";

    firefox-nightly.url = "github:K900/flake-firefox-nightly/vendor-package-expression";
    firefox-nightly.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    limbo.url = "github:saghen/limbo";
    limbo.inputs.nixpkgs.follows = "nixpkgs";

    wayfreeze.url = "github:jappie3/wayfreeze";
    wayfreeze.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      sops-nix,
      hardware,
      ...
    }:
    let
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos/configuration.nix
            ./machines/${hostname}/nixos.nix
            ./machines/${hostname}/machine.nix
            sops-nix.nixosModules.sops

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = {
                  inputs = inputs;
                  inherit (inputs) alejandra;
                  inherit (inputs) spicetify-nix;
                  inherit (inputs) fenix;
                  inherit (inputs) limbo;
                  inherit (inputs) firefox-nightly;
                };
                sharedModules = [
                  sops-nix.homeManagerModules.sops
                  ./machines/${hostname}/machine.nix
                ];
                users.saghen = import ./home-manager/home.nix;
              };
            }
          ];
          specialArgs = { inherit inputs; };
        };
    in
    {
      nixosConfigurations = {
        liam-desktop = mkSystem "desktop";
        liam-laptop = mkSystem "laptop";
      };
    };
}
