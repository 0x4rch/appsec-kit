#!/bin/sh
# bundle-strings.sh -- everything readable in your own app bundle.
#
#   sh bundle-strings.sh MyApp.ipa
#   sh bundle-strings.sh app-release.apk
#
# Unzips YOUR app build into a temp folder, runs strings over it, and
# highlights the shapes keys and endpoints have. That is what anyone with the
# public build can do in the same minute, which is the point. Run it on your
# own app only; someone else's needs their permission.

f="${1:?usage: bundle-strings.sh MyApp.ipa | app.apk}"
[ -f "$f" ] || { echo "no such file: $f"; exit 1; }
tmp=$(mktemp -d)
unzip -q "$f" -d "$tmp" || { echo "could not unzip $f"; exit 1; }

echo "== endpoints =="
find "$tmp" -type f -print0 | xargs -0 strings 2>/dev/null \
  | grep -Eo 'https?://[A-Za-z0-9._-]+(/[A-Za-z0-9._/-]*)?' | sort | uniq -c | sort -rn | head -40

echo
echo "== things shaped like keys =="
find "$tmp" -type f -print0 | xargs -0 strings 2>/dev/null | grep -E \
  '(^|[^A-Za-z0-9])(AKIA[0-9A-Z]{16}|sk_live_[0-9A-Za-z]{20,}|sk-(proj-)?[A-Za-z0-9_-]{32,}|AIza[0-9A-Za-z_-]{30,}|gh[pousr]_[A-Za-z0-9]{36,}|appl_[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{12,}\.eyJ[A-Za-z0-9_-]{12,})' \
  | sort -u | cut -c1-120 | head -40
echo
echo "A Firebase web config, a Supabase anon key or a RevenueCat public key are meant to be here."
echo "A service-role key, a cloud access key or an LLM API key are not: rotate and move server-side."

rm -rf "$tmp"
