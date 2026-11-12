# packages

[![Build Packages](https://github.com/HacknetAOS/packages/actions/workflows/build-packages.yml/badge.svg)](https://github.com/HacknetAOS/packages/actions/workflows/build-packages.yml)

Arch Linux `PKGBUILD` definitions and build script for HacknetOS.

## Package Index

| Package | Architecture | Description |
| :--- | :--- | :--- |
| [`hacknet-keyring`](hacknet-keyring) | `any` | Official PGP keyring (`6D9D481F4ACB997F919BCA90D9069C156B0C606C`) for `pacman-key --populate hacknetos` |
| [`hacknet-proto`](hacknet-proto) | `x86_64` | Shared IPC protocol, grid layout, and theme preset types |
| [`hacknet-theme`](hacknet-theme) | `x86_64` | Theme compiler (`hacknet-theme`), presets (`/usr/share/hacknet/themes`), and `layout.toml` |
| [`hacknetd`](hacknetd) | `x86_64` | Window placement daemon, NetMap provider, and systemd user service |
| [`hacknetctl`](hacknetctl) | `x86_64` | Command-line client and Bash completions for `hacknetd` |
| [`hacknet-shell`](hacknet-shell) | `any` | Quickshell desktop shell, `greetd` login greeter, session launchers, and compositor configs |
| [`yay`](yay) | `x86_64` | Pre-built AUR helper (`yay` 13.1.0) |
| [`hacknet-os`](hacknet-os) | `x86_64` | Meta-package pulling in the full HacknetOS desktop stack |

## Building Locally

Ensure `base-devel`, `cargo`, and sibling repositories (`hacknet-core`, `hacknet-shell`, `hacknet-theme`) are checked out under the parent directory (or set `HACKNET_SRC` to their parent directory), then run:

```bash
./build-packages.sh
```

Built `.pkg.tar.zst` archives, detached `.sig` signatures (when the release signing key is present in the local GPG keyring), and the `hacknetos.db` pacman database are written to `pkg-out/`.

