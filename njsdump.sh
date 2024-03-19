
NEXTJS_MANIFEST="$1"

echo "[*] Search for Next.js Javascript files and pages from build manifest (ex: https://www.target.com/assets/_next/static/abcde/_buildManifest.js)"

validate_url() {
    url="$1"

    url_regex="^(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))?$"

    if ! [[ "$url" =~ $url_regex ]]; then
        echo "Invalid provided URL."
        exit -1
    fi
}

validate_url $NEXTJS_MANIFEST

HOSTNAME=$(echo "$NEXTJS_MANIFEST" | awk -F/ '{print $3}')
BASEURL=$(echo "$NEXTJS_MANIFEST" | sed 's/\(_next\).*/\1/')
BASEURL_NONEXT=$(echo "$BASEURL" | sed 's/\(\/_next\).*//')
BUILDID=$(echo "$NEXTJS_MANIFEST" | sed 's|.*/\([^/]*\)/_buildManifest\.js|\1|')

JSFILES=$(curl --silent -k $NEXTJS_MANIFEST | grep -o '"[^"]*\.js"' - | sed 's/"//g')

echo "[*] Downloading JS files:"
for f in $JSFILES
do
    echo "$BASEURL/$f"
    wget --no-check-certificate  -P ./output/$HOSTNAME --quiet "$BASEURL/$f"
done

URIS=$(curl --silent -k $NEXTJS_MANIFEST | grep -o 'sortedPages:\[.*"\]' - | sed 's/sortedPages:\[\(.*\)\]/\1/' | awk -F '"' '{for (i=2; i<=NF; i+=2) print $i}')
echo "[*] Found following pages:"
for u in $URIS
do
    echo "$BASEURL_NONEXT$u"
done

SERVERSIDEPROPSURL="$BASEURL/data/$BUILDID/index.json"
echo "[*] Tips: also check out server side props on $SERVERSIDEPROPSURL. Happy hunting!"