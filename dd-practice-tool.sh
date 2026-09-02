#!/bin/sh
# Devil Daggers Practice Tool
# Switches your active spawnset (survival file) between vanilla and
# community spawnsets downloaded from devildaggers.info.

set -eu

# --- Locate the game folder -------------------------------------------------
FLATPAK_DD="$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/common/devildaggers/dd"
NATIVE_DD="$HOME/.local/share/Steam/steamapps/common/devildaggers/dd"

if [ -d "$FLATPAK_DD" ]; then
    DD="$FLATPAK_DD"
elif [ -d "$NATIVE_DD" ]; then
    DD="$NATIVE_DD"
else
    echo "Could not find your Devil Daggers 'dd' folder in either:"
    echo "  $FLATPAK_DD"
    echo "  $NATIVE_DD"
    echo "Edit DD in this script to point at the right path."
    exit 1
fi

API_BASE="https://devildaggers.info/api/spawnsets"

# --- Named community spawnsets (verified working against the current API) --
# format: "menu label|cache filename|api slug"
SPAWNSETS="
Pedeslayer|pedeslayer|Pedeslayer
Scanner|scanner|Scanner
"

# --- First-time setup: back up the real survival file, once ----------------
ensure_backup() {
    if [ ! -f "$DD/survivalbackup" ]; then
        if [ ! -f "$DD/survival" ]; then
            echo "No survival file found at $DD/survival — is the path right?"
            exit 1
        fi
        cp "$DD/survival" "$DD/survivalbackup"
        echo "First-time setup: backed up your original survival file."
        sleep 1
    fi
}

# --- Download a spawnset by API slug, verifying it actually worked ---------
# Deletes any cached copy that turns out to be bad (e.g. from a past 404)
# so it will be retried instead of getting stuck.
fetch_spawnset() {
    slug="$1"
    cache_file="$DD/$2"

    if [ -s "$cache_file" ]; then
        cp "$cache_file" "$DD/survival"
        return 0
    fi

    echo "Downloading $slug..."
    tmp_file=$(mktemp)
    http_code=$(wget --quiet --server-response -O "$tmp_file" \
        "$API_BASE/$slug/file" 2>&1 | awk '/^  HTTP/{print $2}' | tail -n1)

    if [ "$http_code" != "200" ] || [ ! -s "$tmp_file" ]; then
        echo "Failed to download '$slug' (HTTP ${http_code:-unknown})."
        echo "It may have been renamed or removed on devildaggers.info."
        rm -f "$tmp_file"
        return 1
    fi

    mv "$tmp_file" "$cache_file"
    cp "$cache_file" "$DD/survival"
}

play_vanilla() {
    ensure_backup
    cp "$DD/survivalbackup" "$DD/survival"
    echo "Now playing vanilla."
}

play_named() {
    label="$1"; cache="$2"; slug="$3"
    ensure_backup
    if fetch_spawnset "$slug" "$cache"; then
        echo "Now playing $label."
    fi
}

search_and_play() {
    ensure_backup
    printf "Spawnset name to search for (as it appears on devildaggers.info): "
    read -r query
    [ -z "$query" ] && return
    if fetch_spawnset "$query" "$query"; then
        echo "Now playing $query."
    fi
}

print_menu() {
    clear
    echo "=========================================="
    echo "Devil Daggers Practice Tool"
    echo
    echo "1: vanilla"
    echo
    echo "--- community spawnsets ---"
    n=2
    echo "$SPAWNSETS" | while IFS='|' read -r label cache slug; do
        [ -z "$label" ] && continue
        echo "$n: $label"
        n=$((n + 1))
    done
    echo "s: search for a spawnset by name from devildaggers.info"
    echo
    echo "Note: the old hardcoded 'no farm' dagger-count presets (e.g. a"
    echo "440/400/350... practice series) that used to ship with this tool"
    echo "have been removed — devildaggers.info no longer serves them under"
    echo "their old names. Use 's' to search for current equivalents by name."
    echo
    echo "q: quit"
    echo
}

main() {
    while true; do
        print_menu
        printf "select an option: "
        read -r answer

        case "$answer" in
            1) play_vanilla; sleep 1.5 ;;
            s|S) search_and_play; sleep 1.5 ;;
            q|Q) exit 0 ;;
            *)
                if echo "$answer" | grep -qE '^[0-9]+$'; then
                    idx=2
                    matched=0
                    old_ifs=$IFS
                    IFS='
'
                    for line in $SPAWNSETS; do
                        [ -z "$line" ] && continue
                        if [ "$idx" = "$answer" ]; then
                            IFS='|'
                            set -- $line
                            IFS=$old_ifs
                            play_named "$1" "$2" "$3"
                            matched=1
                            break
                        fi
                        idx=$((idx + 1))
                    done
                    IFS=$old_ifs
                    [ "$matched" = "0" ] && echo "Not a valid option."
                    sleep 1.5
                else
                    echo "Not a valid option."
                    sleep 1
                fi
                ;;
        esac
    done
}

main
