{ pkgs, ... }:

{
  packages = with pkgs; [(ruby.withPackages (ps: [ps.github-pages]))];
}
