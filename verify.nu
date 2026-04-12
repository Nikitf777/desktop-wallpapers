#!/usr/bin/env nu

for entry in (
    open --raw wallpapers.csv | from csv --noheaders --separator " "
) {
    print $'Verifying ($entry.column1)...'
    print (if ($entry.column0 == (http get --raw --allow-errors $entry.column1
    | into binary
    | hash sha256)) { "✅ Valid" } else { "❌ Invalid" })
    print
}
