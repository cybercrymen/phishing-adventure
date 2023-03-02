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
#
# This tool is publically availble from https://github.com/cybercrymen/phishing-adventure/

YOURIP=$(curl -s https://api.ipify.org/?callback=getIP)

# Add your API key in the file below
APIKEY="$(cat urlscan.api)"

# URLScan Variables - Change the TAG and TAGURL to your own
OUTFILE="urlscan-results.txt"
TAG="@CyberCrymen"
URLTAG="https://urlscan.io/search/#task.tags:%22@cybercrymen%22"

clear
echo "###################################################"
echo "                                                   "
echo "   Welcome to Rex Hunts Phishing Adventure         "
echo "   By @CyberCrymen                                 "
echo "                                                   "
echo "   Your current IP address is $YOURIP              "
echo "   Press CTRL-C to exit the console                "
echo "                                                   "
echo "###################################################"
echo ""
echo "What bait/keyword do you want to use?"
echo "Some examples are: login, mygov, tracking, medicare, auspost"
read -p "Enter Target Word: " KEYWORD
echo "-------------------------------------------------"
echo "                                                 "
echo "  Updating your domain db...                     "
echo "                                                 "
echo "-------------------------------------------------"
sleep 2

# Setting an error function
function error() {
    echo >&2 "$@"
    exit 1
}

# This ensures that all the required commands are installed on the system before proceeding with further execution
for cmd in mkdir wc base64 curl cat zcat mktemp date tr realpath dirname; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        error "command: $cmd not found!"
    fi
done

# Lets get some domains...
set -e

DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
DAY_RANGE="${DAY_RANGE:-3}"
DAILY_DIR="${DAILY_DIR:-daily}"
TEMP_FILE="$(mktemp -p "$DIR" --suffix=nrd)"
BASE_URL_FREE="https://whoisds.com/whois-database/newly-registered-domains"
cd "$DIR"

function insert_temp_file() { echo "$*" >> "$TEMP_FILE"; }

function download() {

    i="$DAY_RANGE"
    TYPE="free"

    TARGET_FILE="nrd.txt"
    DOWNLOAD_DIR="${DAILY_DIR}/${TYPE}"
    mkdir -p "$DOWNLOAD_DIR"

    echo "Downloading domains from the past 3 days...up to 3 days lag."

    while [ "$i" -gt "0" ]; do
        DATE="$(date -u --date "$i days ago" '+%Y-%m-%d')"
        FILE="${DOWNLOAD_DIR}/${DATE}"
        if [ -s "$FILE" ] && [ "$(grep -vc '^$' "$FILE")" -ge "1" ] ; then
            echo "$FILE already exists, skipping the download..."
        else
            printf "%s" "Download and decompress $DATE data ..."
            FREE_URL_INFIX="$(echo "${DATE}.zip" | base64)"
            URL="${BASE_URL_FREE}/${FREE_URL_INFIX:0:-1}/nrd"
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

download

echo "-------------------------------------------------"
echo "                                                 "
echo "   Filtering the db with the word $KEYWORD       "
echo "                                                 "
echo "-------------------------------------------------"
echo ""

# Filtering the domains from the db file, then removing the db file
cat nrd.txt | grep $KEYWORD > $KEYWORD.txt
sleep 2; rm nrd.txt

# Print the number of filtered domains
echo "-------------------------------------------------"
echo "                                                 "
echo "   Filtered Domains Count                        "
echo "                                                 "
echo "-------------------------------------------------"
echo ""
echo "You have found $(grep -vc '^$' "$KEYWORD.txt") domains!"
echo ""
echo "There is a new file called $KEYWORD.txt in the current directory."
echo ""
echo "-------------------------------------------------"
echo "                                                 "
echo "   Submitting URLs to URLScan.io                 "
echo "                                                 "
echo "-------------------------------------------------"
sleep 2

# Submit one URL at a time until list is complete, sleep 2 is to avoid overloading the API on free user account.
cat $KEYWORD.txt | tr -d "\r" | while read url; do
  echo "Scanning URL: $URL"
  curl -s -X POST "https://urlscan.io/api/v1/scan/" \
    -H "Content-Type: application/json" \
    -H "API-Key: $APIKEY" \
    -d "{\"url\": \"$URL\", \"visibility\": \"public\", \"tags\": [\"$TAG\"], \"country\": \"au\"}" >> "$OUTFILE"
  sleep 3
done

# Final message... Thx
echo ""
echo "-------------------------------------------------"
echo "                                                 "
echo "   Analysis Complete! Visit Urlscan to review    "
echo "                                                 "
echo "-------------------------------------------------"
echo ""
echo "You can now start analyzing each domain via URLScan."
echo "There is a new file called $OUTFILE in the current directory."
echo "Visit $URLTAG"
echo ""
