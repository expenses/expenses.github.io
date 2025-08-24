---
layout: post
title:  "Nix Tech Tree"
---

I run [https://nixos.org/](NixOS) on my laptop and I'm a big proponent of the Nix project. It's not easy to understand what Nix is, so I thought I'd have a go.

# Nix Store

Nix is a thing you either install on your existing (MacOS/Linux/WSL) OS or run as it's own OS. When you install Nix it sets up a bunch of users and stuff, but the core bit is a directory at `/nix`. In `/nix` is `/nix/store`. This stores files and directories with file names consisting of two parts - a hash and a (non-unique) name. For example `/nix/store/wvfhs8k86740b7j3h1iss94z7cb0ggj1-hello-2.12.2` has the hash `wvfhs8k86740b7j3h1iss94z7cb0ggj1` and the name `hello-2.12.2`. Hashes can be either `content-addressed` where the contents of a file or directory is used to compute the hash or `input-addressed` where the inputs of a derivation are used to compute the hash.

# Derivations

One thing that `/nix/store` stores are scripts to build programs and other store items. These are called Derivations and have a json-like file structure. For example, `/nix/store/5g60vyp4cbgwl12pav5apyi571smp62s-hello-2.12.2.drv` looks like this:

`Derive([("out","/nix/store/wvfhs8k86740b7j3h1iss94z7cb0ggj1-hello-2.12.2","","")],[("/nix/store/1mzpi7gzqibbkrmhbld3iydk9r6mjmc8-stdenv-linux.drv",["out"]),("/nix/store/c9r4qvprf4j2lrl9c3c3x4pyzjnwz0ii-hello-2.12.2.tar.gz.drv",["out"]),("/nix/store/s2bs92xzwb0ygzn35sqwy426d3691pha-bash-5.3p0.drv",["out"]),("/nix/store/swvfc4hrl5vwh6axjb8rbx6ia9mh6vmd-version-check-hook.drv",["out"])],["/nix/store/shkw4qm9qcw5sc5n1k5jznc83ny02r39-default-builder.sh","/nix/store/vj1c3wf9c11a0qs6p3ymfvrnsdgsdcbq-source-stdenv.sh"],"x86_64-linux",...`

The full formatted code is below. When build, the output contents of this derivation is available at `/nix/store/wvfhs8k86740b7j3h1iss94z7cb0ggj1-hello-2.12.2`.

```shell
~> /nix/store/wvfhs8k86740b7j3h1iss94z7cb0ggj1-hello-2.12.2/bin/hello
Hello, world!
```

Importantly, the hash of the output is determined by the derivation script and can be computed without doing the build, preventing work or from being computed, either by reusing an output directory or pulling the output off a cache server called a substituer.

# Nix Lang

There are any number of ways to write out derivations such as the one above, but generally you'd want to write your build instructions in a higher-level system so that you can say package `a` depends on `b` and `c`, and let any changes to the derivation for `c` modify the derivation for `a`. With nix, you generally utilise a Domain-Specific Language (DSL) for this purpose, confusing also called Nix (but here referred to as Nix Lang). In my opinion it's your standard DSL - it has improved ergonomics for enough things to the degree that I'd rather use it than a more general programming language, but it's not without its downsides. I don't want to fully get into the syntax here, but one example of the improved ergonomics that make a lot of sense for a build and configuration language is nested maps (called `attrs` in Nix Lang). For example, this:

```nix
nix.settings.experimental-features = [
  "nix-command"
  "flakes"
];
```

is the equivalent of:

```nix
nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
};
```

That alone is worth the price of entry IMO.

If you really hate it then [nixkel](https://github.com/tweag/nickel) is in development and Guix uses GNU Guile, a Scheme implementation.

# nixpkgs

Nixpkgs is a very large collection of packages written in Nix Lang. Almost all Nix users will be using nixpkgs, as among other things it has a defined standard environment that makes creating new packages easy by including the things you'd generally want (bash, make, etc).

# NixOS

NixOS is what happens when you use nixpkgs and Nix Lang to create a linux operating system. Essentially, you define your OS, packages, services, users etc as a piece of Nix Lang code. that is built into a derivation that lays out your system in a defined way. Then you run `nixos-rebuild switch` and this derivation is built and various elements of the output directory are symbolically linked to places such as `/run/current-system`. Based on what you altered in your config, services are stopped, started or restarted. A kernel image is also written to `/boot/kernels`.

You don't (and I definitely don't) need to care about the specifics, but having your OS defined like this means a couple of things:
- You never, ever have to edit something outside your home directory
- You'll forget what you have installed, as all the packages you're using are declaratively defined in your nixos config.
- You're never going to put your system in a broken state by losing power inbetween updates, as switching your config happens more or less atomically.
- Custom packages and scripts are first-class citizens and are treated no differently to 'official' packages from nixpkgs.

Here's an arbitrary snippet from my NixOS config:

```nix
{pkgs, ...}: {
  environment.sessionVariables.EDITOR = "${pkgs.vim}/bin/vim";

  fonts.packages = with pkgs; [noto-fonts noto-fonts-cjk-sans departure-mono];

  environment.systemPackages = with pkgs; [
    # ...
    alacritty
    blender
    wine
    anki
    (writeShellScriptBin "steam-big" "${steam}/bin/steam -forcedesktopscaling=1.5 $@")
    # ...
  ];

  # Needed for screen capture on hyprland!!!!!!!!!!!!!
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
    config.common.default = "*";
  };

  # taken from nixos wiki
  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;
  };
}
```

Deps:
- Nixpkgs

# Home Manager

Deps:
- NixOS

# Nix Flakes

Deps:
- Nix Lang

# Post

## Formatted Derivation

```javascript
Derive(
    [
        ("out","/nix/store/wvfhs8k86740b7j3h1iss94z7cb0ggj1-hello-2.12.2","","")
    ],
    [
        ("/nix/store/1mzpi7gzqibbkrmhbld3iydk9r6mjmc8-stdenv-linux.drv",["out"]),
        ("/nix/store/c9r4qvprf4j2lrl9c3c3x4pyzjnwz0ii-hello-2.12.2.tar.gz.drv",["out"]),
        ("/nix/store/s2bs92xzwb0ygzn35sqwy426d3691pha-bash-5.3p0.drv",["out"]),
        ("/nix/store/swvfc4hrl5vwh6axjb8rbx6ia9mh6vmd-version-check-hook.drv",["out"])
    ],
    [
        "/nix/store/shkw4qm9qcw5sc5n1k5jznc83ny02r39-default-builder.sh",
        "/nix/store/vj1c3wf9c11a0qs6p3ymfvrnsdgsdcbq-source-stdenv.sh"
    ],
    "x86_64-linux",
    "/nix/store/gkwbw9nzbkbz298njbn3577zmrnglbbi-bash-5.3p0/bin/bash",
    [
        "-e",
        "/nix/store/vj1c3wf9c11a0qs6p3ymfvrnsdgsdcbq-source-stdenv.sh",
        "/nix/store/shkw4qm9qcw5sc5n1k5jznc83ny02r39-default-builder.sh"
    ],
    [
        ("NIX_MAIN_PROGRAM","hello"),
        ("__structuredAttrs",""),
        ("buildInputs",""),
        ("builder","/nix/store/gkwbw9nzbkbz298njbn3577zmrnglbbi-bash-5.3p0/bin/bash"),
        ("cmakeFlags",""),
        ("configureFlags",""),
        ("depsBuildBuild",""),
        ("depsBuildBuildPropagated",""),
        ("depsBuildTarget",""),
        ("depsBuildTargetPropagated",""),
        ("depsHostHost",""),
        ("depsHostHostPropagated",""),
        ("depsTargetTarget",""),
        ("depsTargetTargetPropagated",""),
        ("doCheck","1"),
        ("doInstallCheck","1"),
        ("mesonFlags",""),
        ("name","hello-2.12.2"),
        ("nativeBuildInputs","/nix/store/p4myq48s5r4ragsys74a9pklgis9rdhj-version-check-hook"),
        ("out","/nix/store/wvfhs8k86740b7j3h1iss94z7cb0ggj1-hello-2.12.2"),
        ("outputs","out"),
        ("patches",""),
        ("pname","hello"),
        ("postInstallCheck","stat \"${!outputBin}/bin/hello\"\n"),
        ("propagatedBuildInputs",""),
        ("propagatedNativeBuildInputs",""),
        ("src","/nix/store/dw402azxjrgrzrk6j0p66wkqrab5mwgw-hello-2.12.2.tar.gz"),
        ("stdenv","/nix/store/nbrif411qgsj1h5r7rlgxxm140aj58dz-stdenv-linux"),
        ("strictDeps",""),
        ("system","x86_64-linux"),
        ("version","2.12.2")
    ]
)
```
