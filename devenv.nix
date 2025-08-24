{pkgs, ...}: {
  packages = with pkgs; [
    (ruby.withPackages (ps:
      with ps; [
        jekyll
        minima
      ]))
    #jekyll (ruby.withPackages (ps: [ps.github-pages]))
  ];
}
