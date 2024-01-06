{ pkgs, ... }:

{
  languages.java.enable = true;
  languages.java.jdk.package = pkgs.jdk21;

  packages = [
    pkgs.newman
  ];

  enterShell = ''
    echo ---
    java -version
    echo ___
    echo Newman:
    newman -version
    echo ---
  '';
}
