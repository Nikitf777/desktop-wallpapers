#!/usr/bin/env nu

def main [
    input_file: path
    --subdirectory: string = ""
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
    let wallpapers_directory = "$out/share/backgrounds"
    let wallpapers_subdirectory = $'($wallpapers_directory)/($subdirectory)'
    mut create_symlinks = ""
    if (not ($subdirectory | is-empty)) {
      $create_symlinks = $'ln -s ($wallpapers_subdirectory)/* ($wallpapers_directory)'
    }
    let nix_output = [$'{ pkgs, lib, ... }:
let
  wallpapers = [($nix_entries)
  ];

  wallpapersPackage = pkgs.runCommand "system-wallpapers" { } ''
    mkdir -p ($wallpapers_subdirectory)
    ${lib.concatMapStringsSep "\n" ', '(w: "cp ${w.src} ', $'($wallpapers_subdirectory)") wallpapers}
    ($create_symlinks)
  '';
in
{
  environment.systemPackages = [ wallpapersPackage ];
}'] | str join

    echo $nix_output
}
