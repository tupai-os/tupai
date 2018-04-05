<p align="center">
<img alt="Tupai" width="512" src="https://raw.github.com/tupai-os/assets/master/logo/tupai-cover.png">
</p>

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

Currently, Tupai targets only 3 instruction set architectures; `i386`, `x86_64` and `armv7`. However, Tupai is deliberately designed to make future ports to other architectures simple and painless.

## Design

Tupai does not aim for POSIX compliance. However, much of its design is inspired by the POSIX specification.

## Building

To build Tupai, first clone the project into a local directory.

```
git clone --recursive-submodules git@github.com:tupai-os/tupai.git && cd tupai
```

To build an ISO for the default platform (`x64`), execute the following command.

```
sh build-x64.sh
```

`TODO: Explain how to build other architectures here`

## Running

Once compiled, the kernel can be run using QEMU by executing the following command.

```
sh qemu-x64.sh
```

`TODO: Explain how to run other architectures here`

## Naming

Tupai is named after the Malay word for 'squirrel'.

## Contributing

Currently, Tupai is not accepting third-party contributions due to its status as a final year university project. However, after May 2018 Tupai will begin accepting pull requests and issues.
