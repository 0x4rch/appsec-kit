#!/bin/sh
# headers-check.sh -- which security headers a site sends, in one curl.
#
#   sh headers-check.sh https://yourapp.com
#
# Reads the response headers of one public page and says which of the usual
# ones are missing, with one line on why each matters. That is all it does:
# one GET, the same one a browser makes. A missing header is not a breach;
# it is a door you can close in an afternoon.

url="${1:?usage: headers-check.sh https://yourapp.com}"
h=$(curl -sS -L -I -A "headers-check/1.0" --max-time 15 "$url" | tr -d '\r' | tr 'A-Z' 'a-z')
[ -z "$h" ] && { echo "no response from $url"; exit 1; }

check() {
  name="$1"; why="$2"
  if printf '%s\n' "$h" | grep -q "^$name:"; then
    printf '  ok       %s\n' "$name"
  else
    printf '  MISSING  %-32s %s\n' "$name" "$why"
  fi
}

echo "$url"
check content-security-policy   "limits where scripts can load from; the main defence against injected scripts"
check strict-transport-security "tells browsers to use https only, so a downgrade attack fails"
check x-content-type-options    "stops a browser guessing a file is a script when it is not"
check x-frame-options           "stops your pages being framed by another site for clickjacking (or use CSP frame-ancestors)"
check referrer-policy           "keeps your URLs, which may hold ids or tokens, out of other sites' logs"
check permissions-policy        "turns off camera, mic and location for pages that do not need them"

echo
if printf '%s\n' "$h" | grep -q "^set-cookie:"; then
  echo "cookies:"
  printf '%s\n' "$h" | grep "^set-cookie:" | while read -r line; do
    name=$(printf '%s' "$line" | sed 's/^set-cookie: *//' | cut -d= -f1)
    flags=""
    printf '%s' "$line" | grep -q "httponly" || flags="$flags no-HttpOnly(scripts can read it)"
    printf '%s' "$line" | grep -q "secure"   || flags="$flags no-Secure(sent over http too)"
    printf '%s' "$line" | grep -q "samesite" || flags="$flags no-SameSite(sent on cross-site requests)"
    [ -z "$flags" ] && flags=" ok"
    printf '  %-24s%s\n' "$name" "$flags"
  done
else
  echo "no cookies set on this page"
fi
