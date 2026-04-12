#!/usr/bin/env nu

def main [
    url: string = ""
    --file (-f): string = "wallpapers.csv"
] {
    let url = if ($url | is-not-empty) {
        $url
    } else {
        input "Enter wallpaper URL: "
    }

    let new_hash = (http get --raw $url | into binary | hash sha256)

    let existing = if ($file | path exists) {
        open --raw $file
        | from csv --noheaders --separator " "
        | each { |entry| {
            column0: ($entry.column0 | str trim),
            column1: ($entry.column1 | str trim)
        }}
    } else { [] }

    if ($existing | any { |entry| $entry.column0 == $new_hash and $entry.column1 == $url }) {
        print "Exact pair already exists. Skipping."
        return
    }

    let cleaned = $existing | where { |entry| $entry.column0 != $new_hash and $entry.column1 != $url }

    let updated = $cleaned ++ [{column0: $new_hash, column1: $url}]

    ($updated | each { |entry| $"($entry.column0) ($entry.column1)" } | str join "\n") ++ "\n" | save -f $file
    print $"Successfully added: ($new_hash) ($url)"
}
