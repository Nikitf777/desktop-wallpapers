#!/usr/bin/env nu

def main [
    input_file: path
] {
    let entries = open $input_file --raw
        | from csv --noheaders --separator " "

    let nix_entries = $entries | each { |e|
        $'
    {
        src = pkgs.fetchurl {
            url = "($e.column1)";
            sha256 = "($e.column0)";
        };
    }'
    } | str join
    let nix_output = [$'{ config, pkgs, lib, ... }:

let
  wallpapers = [
($nix_entries)
  ];

  wallpapersPackage = pkgs.runCommand "system-wallpapers" {} ''
    mkdir -p $out/share/backgrounds
    ${lib.concatMapStringsSep "\n" ', '(w: "cp ${w.src} $out/share/backgrounds/") wallpapers}
  '';
in {
  environment.systemPackages = [ wallpapersPackage ];
}'] | str join

    echo $nix_output
}
