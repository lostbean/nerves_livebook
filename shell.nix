{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  name = "nervesShell";
  buildInputs = [
    autoconf
    automake
    curl
    erlangR25
    fwup
    git
    pkgs.beam.packages.erlangR25.elixir_1_14
    rebar3
    squashfsTools
    x11_ssh_askpass
    pkg-config
  ];
  shellHook = ''
    SUDO_ASKPASS=${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
  '';
}
