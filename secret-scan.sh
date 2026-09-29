#!/bin/sh
# secret-scan.sh -- a git pre-commit hook that refuses to commit a key.
#
# Install, once per repo:
#   cp secret-scan.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
#
# What it does: looks at the lines you are about to commit (staged additions
# only) for the shapes real keys have, and stops the commit if it finds one.
# It does not look at your whole repo and it does not phone home. If a key is
# already in your history, this will not find it: rotate that key.
#
# False positive? Commit with --no-verify, once, on purpose.

set -e

# Each line: a label, then a pattern. Anchored so a URL slug like
# "risk-management-programs" cannot match the OpenAI shape.
PATTERNS='
AWS access key id|(^|[^A-Za-z0-9])AKIA[0-9A-Z]{16}([^A-Za-z0-9]|$)
Stripe live secret|(^|[^A-Za-z0-9])sk_live_[0-9A-Za-z]{20,}
Stripe restricted key|(^|[^A-Za-z0-9])rk_live_[0-9A-Za-z]{20,}
OpenAI key|(^|[^A-Za-z0-9])sk-(proj-)?[A-Za-z0-9_-]{32,}
Anthropic key|(^|[^A-Za-z0-9])sk-ant-[A-Za-z0-9_-]{32,}
GitHub token|(^|[^A-Za-z0-9])gh[pousr]_[A-Za-z0-9]{36,}
Slack token|(^|[^A-Za-z0-9])xox[baprs]-[A-Za-z0-9-]{10,}
Google API key|(^|[^A-Za-z0-9])AIza[0-9A-Za-z_-]{30,}
Supabase service role|service_role.{0,80}eyJ[A-Za-z0-9_-]{12,}\.eyJ
Private key block|-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----
Generic secret assignment|(api[_-]?key|secret|token|password)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9_\-]{20,}["'"'"']
'

found=0
# Staged additions only, with the file name and line number kept.
git diff --cached --unified=0 --no-color | awk '
  /^\+\+\+ / { file = substr($2, 3); next }
  /^@@/ { split($3, a, ","); line = substr(a[1], 2) - 1; next }
  /^\+/ && !/^\+\+\+/ { line++; print file ":" line ":" substr($0, 2); next }
  /^ / { line++ }
' > /tmp/secret-scan.$$ || true

printf '%s\n' "$PATTERNS" | while IFS='|' read -r label pattern; do
  [ -z "$label" ] && continue
  if grep -E -n "$pattern" /tmp/secret-scan.$$ >/tmp/secret-scan.hit.$$ 2>/dev/null; then
    echo "secret-scan: looks like $label:"
    cut -c1-140 /tmp/secret-scan.hit.$$ | sed 's/^/  /'
    echo 1 > /tmp/secret-scan.found.$$
  fi
done

if [ -f /tmp/secret-scan.found.$$ ]; then
  rm -f /tmp/secret-scan.$$ /tmp/secret-scan.hit.$$ /tmp/secret-scan.found.$$
  echo
  echo "Commit refused. If this is really a key: move it to an env var and rotate it."
  echo "If it is not: git commit --no-verify, this once."
  exit 1
fi
rm -f /tmp/secret-scan.$$ /tmp/secret-scan.hit.$$
exit 0
