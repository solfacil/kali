{
  description = ''
  Kali, an attempt to port clojure's malli library, a data-driven
  schemas for Elixir, less opinionated, more extensible and "database-free"
  than ecto.
  '';

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      linux = "x86_64-linux";
      darwin = "aarch64-darwin";

      name = "kali";

      pkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      inputs = sys: with pkgs sys; [
        gnumake
        gcc
        readline
        openssl
        zlib
        libxml2
        curl
        libiconv
        elixir
        glibcLocales
        postgresql
        redpanda
      ] ++ lib.optional stdenv.isLinux [
        inotify-tools
        gtk-engine-murrine
      ] ++ lib.optional stdenv.isDarwin [
        darwin.apple_sdk.frameworks.CoreServices
        darwin.apple_sdk.frameworks.CoreFoundation
      ];

    mkBeampkgs = sys: with pkgs sys;
      let
        inherit (beam) packagesWith;
        inherit (beam.interpreters) erlangR25;
      in packagesWith erlangR25;
    in
    rec {
      devShells = {
        "${linux}".default = with pkgs linux; mkShell {
          inherit name;
          buildInputs = inputs linux;
        };

        "${darwin}".default = with pkgs darwin; mkShell {
          inherit name;
          buildInputs = inputs darwin;
        };
      };

      packages = {
        "${linux}".default = with mkBeampkgs linux; buildMix rec {
          inherit name;
          version = "0.1.0";
          src = ./.;
        };
      };
    };
}
