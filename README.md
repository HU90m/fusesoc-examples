# FuseSoC Examples

This repository contains examples to help one better understand FuseSoC features.

- [prims_lib](./prims_lib): An example of how to set up primitive libraries for your project.


## Developer Environment

The easiest way to get up and running is to use [the nix environment](#the-nix-environment),
but it's not required and one can [manually install dependencies](#manual-environment-setup).

### The Nix Environment

If you don't already have Nix installed,
you can follow the instructions at: <https://zero-to-nix.com/start/install>.

Once you have nix installed, run the following to enter the developer environment.

```sh
nix develop .
```

### Manual Environment Setup

You'll need to install a recent version of [verilator](https://www.veripool.org/verilator/)
and [poetry](https://python-poetry.org/).

Then run the following to get poetry to install all the required python dependencies.

```sh
poetry shell
```


### Checks

You can run the following command to run all lints and checks.

```sh
nix flake check
```

This is especially useful if you're contributing a change and want to check nothing's been broken.
