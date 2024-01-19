{ pkgs, ... }:

{
  languages.java.enable = true;
  languages.java.jdk.package = pkgs.jdk21;

  packages = [
    pkgs.liquibase
    pkgs.newman
  ];

  enterShell = ''
    echo ---
    java -version
    echo ___
    echo Newman:
    newman -version
    echo ---
    liquibase -version
    echo ---
  '';

  dotenv.disableHint = true;
}
