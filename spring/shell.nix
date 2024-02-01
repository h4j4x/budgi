let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-23.11";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShell {
  packages = with pkgs; [
    jdk21
    liquibase
    newman
  ];

  shellHook = ''
    echo ================
    echo Java:
    java -version
    echo ================
    echo Liquibase:
    liquibase -version
    echo ================
    echo Newman:
    newman --version
  '';
}
