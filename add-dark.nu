#!/usr/bin/env nu

def main [
    url: string = ""
] {
    ./add-wallpaper.nu --file urls/dark.csv $url
}
