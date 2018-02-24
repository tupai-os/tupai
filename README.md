# Tupai
---

Tupai is a modular operating system targeting the i386, x86_64 and armv7 architectures.

## Objectives

Designed from the ground up in the Rust programming language, Tupai focusses on achieving the following objectives.

- Safety
- Stability
- Correctness
- Modularity
- Portability

## Platform support

Currently, Tupai targets only 3 architectures; `i386`, `x86_64` and `armv7`. However, Tupai is deliberately designed to make future ports to other architectures simple and painless.

## Building

To build Tupai, first clone the project into a local directory.

```
git clone --recursive-submodules git@github.com:tupai-os/tupai.git && cd tupai
```

To build an ISO for the default platform, `x86_64`, invoke make.

```
make
```

Once compiled, the kernel can be run using QEMU by invoking the `qemu` make subcommand.

```
make qemu
```

## Contributing

Currently, Tupai is not accepting third-party contributions.
