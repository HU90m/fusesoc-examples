# SPDX-FileCopyrightText: lowRISC contributors
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileContributor: Hugo McNally
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

      buildInputs = with pkgs; [libelf zlib];
      nativeBuildInputs = with pkgs; [reuse graphviz verilator pythonEnv];

      lints = pkgs.stdenv.mkDerivation {
        name = "fusesoc-examples-lints";
        src = ./.;
        inherit buildInputs nativeBuildInputs;
        dontBuild = true;
        doCheck = true;
        PYTHONPATH=./python_plugins;
        checkPhase = ''
          HOME=$TMPDIR

          reuse lint
          ruff format --check
          ruff check

          prims_checks() {
            fusesoc run --setup hugom:example:top
            fusesoc run --flag select_prims --flag prims_specific --setup hugom:example:top
            fusesoc run --flag select_prims --flag prims_secret hugom:example:top
          }
          pushd prims_lib/virtual_cores
            prims_checks
          popd
          pushd prims_lib/filters
            prims_checks
          popd
        '';
        installPhase = "mkdir $out";
      };
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {
        name = "prim-lib-examples";
        inherit buildInputs nativeBuildInputs;
        shellHook = ''
          export REPO_ROOT="$(${getExe pkgs.git} rev-parse --show-toplevel)"
          export PYTHONPATH="$REPO_ROOT/python_plugins";
        '';
      };
      checks = {inherit lints;};
    };
  in
    flake-utils.lib.eachDefaultSystem system_outputs;
}
