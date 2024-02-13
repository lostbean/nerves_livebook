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
      in {
        formatter = pkgs.nixpkgs-fmt;

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs;
            let
              frameworks = darwin.apple_sdk.frameworks;
              inherit (lib) optional optionals;
            in [
              # Dev environment
              elixir_1_14
              elixir_ls
              erlang
              rebar3
              fwup
              git
              squashfsTools
              openssl
            ] ++ optionals stdenv.isLinux [
              # Docker build
              (python3.withPackages (ps: with ps; [ pip numpy ]))
              stdenv
              gcc
              gnumake
              bazel
              glibc
              gcc
              glibcLocales
              inotify-tools
              autoconf
              automake
              curl
              x11_ssh_askpass
              pkg-config
              libmnl
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
            mix archive.install hex nerves_bootstrap
            printf '\u001b[32m
            The Bauhaus!
            \e[0m
            '
          '';
        };
      });
}
