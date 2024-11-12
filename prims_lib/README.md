# FuseSoC Primitive Libraries Examples

*If you haven't already, [set up your development environment](../README.md#developer-environment).*

A demonstration project highlighting approaches to handling primitive libraries in FuseSoC-based projects.

## What are primitive libraries

Primitive (prim) libraries are common amongst HDL projects with multiple targets, i.e. a simulator, synthesis for an FPGA or synthesis for an ASIC process node.
Primitives provide the basic blocks/modules to digital design engineers,
and importantly enable these basic blocks to be changed depending on the target.
This enable primitive modules to be tailored to their target.

Normally, there are generic primitives that are written in native HDL and made compatible with logic simulators, and there are target-specific primitives that typically instantiate low-level primitives of the target ecosystem, such as ASIC standard library cells or FPGA programmable/hardened cells.

When a digital designer wants to declare they depend on a particular set of primitives, there needs to be a notion of an abstract primitive which the designer can depend on, and which can be swapped for a concrete implementation by the build system when the target is known.

An additional constraint in open source silicon projects is that these primitive libraries need to be easy to add by people using the project without any information about them being required in the upstream open source repository.
A motivating example is ASIC standard libraries.
The use of a particular ASIC standard library or any information about it is often sensitive, and cannot appear in the upstream repository.


## The Toy Example

The diagram below shows the dependency tree of the toy example.

![A graphical representation of the toy example](doc/toy_example.svg)

The top level (`hugom:example:top`) depends on two multiplier IP blocks: `hugom:multiplier:array_multiplier` and `hugom:multiplier:wallace_tree_multiplier`.
The array multiplier only requires the adder primitive, so depends only on `hugom:prims:adder`.

The dotted line around `hugom:prims:adder`, and all other cores in it's `hugom:prims` library,
denote these are abstract cores without any real implementation.
They then depend on their possible implementations, which either come from either the `hugom:prims_generic` or `hugom:prims_specific` libraries.

`hugom:multiplier:wallace_tree_multiplier` not only depends on an adder module but also half and full adder modules.
Instead of having to specifying all the dependencies, it can depend on `hugom:prims:all` to declare that it depends on all modules provided by the primitives library.

A useful feature is for a primitives library to be able to implement only a subset of the primitives required by a primitives library, and then be able to specify an implementation to fall back on for the primitives that it doesn't implement.
In the toy example, `hugom:prims_specific` doesn't implement a half adder and instead makes use of the `hugom:prims_generic:half_adder`.


## How to set up primitive libraries in FuseSoC

Back in 2021, FuseSoC 1.12.0 had no way to handle primitive libraries, which is a reason behind the lowRISC fork of FuseSoC.
A brief explanation of what this fork added and how it was used by OpenTitan to enable primitive libraries can be read [here](doc/how-opentitan-handles-primitives.md).

As of FuseSoC versions 2.4, there are two ways to enable the use of primitive libraries: *virtual cores* or *filters*.
Examples of each approach can be found in the [`virtual_cores`](./virtual_cores) and [`filters`](./filters) directories.

The same commands can be used from either directory to run the directories' example:

```sh
fusesoc run hugom:example:top
fusesoc run --flag select_prims --flag prims_specific hugom:example:top
fusesoc run --flag select_prims --flag prims_secret hugom:example:top
```
