#!/usr/bin/env bash
#
# Find website official URL from Wikipedia
#
#/ Usage:
#/   ./dfw.sh <search_text>
#/
#/ open link in browser:
#/   DFW_OPEN_BROWSER=true ./dfw.sh <search_text>

set -e
set -u

usage() {
    printf "%b\n" "$(grep '^#/' "$0" | cut -c4-)" >&2 && exit 1
}

set_var() {
    _WIKIPEDIA_SEARCH_API="https://en.wikipedia.org/w/api.php?action=query&prop=info&inprop=url&format=json&origin=*"
    if [[ -z "${DFW_OPEN_BROWSER:-}" ]]; then
        DFW_OPEN_BROWSER=false
    fi
}

set_command() {
    _CURL="$(command -v curl)" || command_not_found "curl" "https://curl.haxx.se/download.html"
    _OPEN="$(command -v xdg-open)" || true
}

set_args() {
    expr "$*" : ".*--help" > /dev/null && usage
    _SEARCH_TEXT="$*"
}

check_var() {
    if [[ -z "${_SEARCH_TEXT:-}" ]]; then
        usage
    fi
}

print_info() {
    # $1: info message
    printf "%b\n" "\033[32m[INFO]\033[0m $1" >&2
}

print_error() {
    # $1: error message
    printf "%b\n" "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

command_not_found() {
    # $1: command name
    # $2: installation URL
    [[ -n "${2:-}" ]] && print_info "Insatll $1 from \033[32m${2}\033[0m"
    print_error "$1\033[0m command not found!"
}

get_wiki_url() {
    # $1: search text
    local l
    l=$($_CURL -sS -G "${_WIKIPEDIA_SEARCH_API}" --data-urlencode "titles=${1}" \
        | sed -E 's/.*fullurl//' \
        | sed -E 's/editurl.*//' \
        | awk -F '"' '{print $3}')

    [[ -z "$l" ]] && print_error "Wikipedia link is not available!"
    echo "$l"
}

get_url_from_wiki() {
    # $1: wiki url
    local l
    l=$($_CURL -sS "$1" \
        | sed -E 's/tr/\n/g' \
        | grep -E "class=\"url\"|>URL<|>Website<" \
        | sed -E 's/title=\"alternative\".*//' \
        | sed -E 's/.*class=\"external \w+\" href=\"//' \
        | sed -E 's/\">.*//' \
        | head -1)

    [[ -z "$l" ]] && print_error "Link not found on page $1 ..."
    echo "$l"
}

open_link() {
    # $1: link
    [[ -z "$_OPEN" ]] && print_error "Default browser is not set!"
    $_OPEN "$1"
}

main() {
    set_args "$@"
    set_command
    set_var
    check_var

    local l o
    l=$(get_wiki_url "$_SEARCH_TEXT")
    o=$(get_url_from_wiki "$l")
    echo "$o"
    [[ "$DFW_OPEN_BROWSER" == true ]] && open_link "$o"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
