{
  description = "Dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, unstable, flake-utils, ... }:
    let utils = flake-utils;
    in utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        unstable_pkgs = unstable.legacyPackages.${system};
        otp = pkgs.beam.packages.erlangR26;
      in {
        formatter = pkgs.nixpkgs-fmt;

        devShell = pkgs.mkShell {
          # keep your shell history in iex
          ERL_AFLAGS = "-kernel shell_history enabled";

          nativeBuildInputs = with pkgs;
            let
              frameworks = darwin.apple_sdk.frameworks;
              inherit (lib) optional optionals;
            in [
              # Dev environment
              otp.elixir_1_16
              elixir_ls
              rebar3
              fwup
              git
              squashfsTools
              openssl
              curl
            ] ++ optionals stdenv.isLinux [
              # Docker build
              (python3.withPackages (ps: with ps; [ pip numpy ]))
              stdenv
              gnumake
              bazel
              glibc
              gcc
              glibcLocales
              inotify-tools
              autoconf
              automake
              x11_ssh_askpass
              pkg-config
              inotify-tools
              libmnl
              usbutils
            ] ++ optionals stdenv.isDarwin [
              # add macOS headers to build mac_listener and ELXA
              frameworks.CoreServices
              frameworks.CoreFoundation
              frameworks.Foundation
            ];
          # Allow to use unpatched binaries (nevers uses its own gcc to cross compile images)
          NIX_LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [ stdenv.cc.cc ];
          NIX_LD = with pkgs;
            lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";

          shellHook = ''
            SUDO_ASKPASS=${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass

            # local directory
            mkdir -p .nix-mix .nix-hex
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex

            export MIX_PATH="${otp.hex}/lib/erlang/lib/hex/ebin"
            export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH

            mix archive.install hex nerves_bootstrap --force

            printf '\u001b[32m
            The Bauhaus!
            \e[0m
            '
          '';
        };
      });
}
