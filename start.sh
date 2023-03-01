#!/usr/bin/env bash

# Rex Hunts Phishing Adventure (GET)
# https://twitter.com/CyberCrymen
# Copyright (C) 2023 ~ @CyberCrymen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This tool is publically availble from https://github.com/cybercrymen/phishing-adventure/

YOURIP=$(curl -s https://api.ipify.org/?callback=getIP)
apikey="$(cat urlscan.api)"
output_file="urlscan-results.txt"

echo
echo "- - - - - - - - - - - - - - - - - - - - -"
echo "Welcome to Rex Hunts Phishing Adventure by @CyberCrymen"
echo "Your current IP address is $YOURIP"
echo "CTRL-C to exit the console"
echo "- - - - - - - - - - - - - - - - - - - - -"
echo
echo "What bait/keyword do you want to use?"
echo "Some examples are: login, mygov, tracking, medicare, auspost"
read keyword
echo "- - - - - - - - - - - - - - - - - - - - -"
echo "Updating your domain db...";sleep 2

function error() {
    echo >&2 "$@"
    exit 1
}

for cmd in mkdir wc base64 curl cat zcat mktemp date tr realpath dirname; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        error "command: $cmd not found!"
    fi
done

set -e

DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
DAY_RANGE="${DAY_RANGE:-7}"
DAILY_DIR="${DAILY_DIR:-daily}"
TEMP_FILE="$(mktemp -p "$DIR" --suffix=nrd)"

BASE_URL_FREE="https://whoisds.com/whois-database/newly-registered-domains"

cd "$DIR"

function insert_temp_file() { echo "$*" >> "$TEMP_FILE"; }

function download() {

    i="$DAY_RANGE"
    TYPE="${1:-free}"

    TARGET_FILE="nrd.txt"
    DOWNLOAD_DIR="${DAILY_DIR}/${TYPE}"
    mkdir -p "$DOWNLOAD_DIR"

    echo "Downloading domains from the past 7 days...up to 3 days lag."

    while [ "$i" -gt "0" ]; do
        DATE="$(date -u --date "$i days ago" '+%Y-%m-%d')"
        FILE="${DOWNLOAD_DIR}/${DATE}"
        if [ -s "$FILE" ] && [ "$(grep -vc '^$' "$FILE")" -ge "1" ] ; then
            echo "$FILE already exists, skipping the download..."
        else
            printf "%s" "Download and decompress $DATE data ..."
            if [ "paid" = "$TYPE" ]; then
                URL="${BASE_URL_PAID}/${DATE}.zip/ddu"
            else
                FREE_URL_INFIX="$(echo "${DATE}.zip" | base64)"
                URL="${BASE_URL_FREE}/${FREE_URL_INFIX:0:-1}/nrd"
            fi
            curl -sSLo- "$URL" | zcat | tr -d '\015' >> "$FILE"
            echo "" >> "$FILE"
            echo "$(grep -vc '^$' "$FILE") domains found."
        fi
        insert_temp_file "# ${DATE} NRD start"
        cat "$FILE" >> "$TEMP_FILE"
        insert_temp_file "# ${DATE} NRD end"
        i="$((i - 1))"
    done

    chmod +r "$TEMP_FILE"
    mv "$TEMP_FILE" "$TARGET_FILE"

    echo "NRD list for the last $DAY_RANGE days saved to $TARGET_FILE, $(grep -cvE '^(#|$)' "$TARGET_FILE") domains found."
    echo
}

download free
echo "- - - - - - - - - - - - - - - - - - - - -"
echo "Filtering the db with the word $keyword"
echo "- - - - - - - - - - - - - - - - - - - - -"
cat nrd.txt | grep $keyword > $keyword.txt;sleep 2
rm nrd.txt
echo
echo -e "You have found $(grep -vc '^$' "$keyword.txt") domains! \n";sleep 1
cat $keyword.txt
echo;echo "All done... There will be a file called $keyword.txt"
echo
echo "Submitting URLs to URLScan.io"
echo

cat $keyword.txt | tr -d "\r" | while read url; do
  echo "Scanning URL: $url"
  curl -s -X POST "https://urlscan.io/api/v1/scan/" \
    -H "Content-Type: application/json" \
    -H "API-Key: $apikey" \
    -d "{\"url\": \"$url\", \"visibility\": \"public\", \"tags\": [\"@CyberCrymen\"], \"country\": \"au\"}" >> "$output_file"
  sleep 2
done
echo
echo;echo "All done... There you can now start analyzing each domain via URLScan."
echo "Visit https://urlscan.io/search/#task.tags:%22@cybercrymen%22"
