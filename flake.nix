{
  description = "FuseSoC Prim Lib Examples";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    poetry2nix,
  } @ inputs: let
    system_outputs = system: let
      pkgs = import nixpkgs {inherit system;};
      inherit (pkgs.lib) getExe;

      pythonEnv = let
        poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;};
      in
        poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          python = pkgs.python311;
          overrides = [poetry2nix.defaultPoetryOverrides];
        };
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {
        name = "prim-lib-examples";
        buildInputs = with pkgs; [libelf zlib];
        nativeBuildInputs = with pkgs; [graphviz verilator pythonEnv];
        shellHook = ''
          export REPO_ROOT="$(${getExe pkgs.git} rev-parse --show-toplevel)"
          export PYTHONPATH="$REPO_ROOT/python_plugins";
        '';
      };
    };
  in
    flake-utils.lib.eachDefaultSystem system_outputs;
}
