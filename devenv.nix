{pkgs, ...}: {
  packages = with pkgs; [
    (ruby.withPackages (ps:
      with ps; [
        jekyll
        minima
      ]))
    (aspellWithDicts (d: [d.en]))
  ];
}
