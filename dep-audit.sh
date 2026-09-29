#!/bin/sh
# dep-audit.sh -- one command a week for dependency problems.
#
# Works out which package managers the repo uses and runs each one's own
# audit, printing only what needs a decision. Run it from the repo root on
# Monday. Nothing is installed or changed; it only reads.
#
#   sh dep-audit.sh            # this repo
#   sh dep-audit.sh ~/code/app # another one

cd "${1:-.}" || exit 1
ran=0

say() { printf '\n== %s ==\n' "$1"; }

if [ -f package-lock.json ] || [ -f package.json ]; then
  say "npm (package.json)"
  if [ ! -f package-lock.json ]; then
    echo "no package-lock.json: commit one, or every install can pull a different version."
  fi
  npm audit --audit-level=moderate --omit=dev 2>/dev/null || echo "(npm audit found something above; read the 'fix available' lines)"
  ran=1
fi
if [ -f pnpm-lock.yaml ]; then say "pnpm"; pnpm audit --prod 2>/dev/null; ran=1; fi
if [ -f yarn.lock ]; then say "yarn"; yarn npm audit --environment production 2>/dev/null || yarn audit --groups dependencies 2>/dev/null; ran=1; fi
if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
  say "python"
  if command -v pip-audit >/dev/null 2>&1; then pip-audit 2>/dev/null; else echo "install pip-audit (pip install pip-audit) and run again"; fi
  ran=1
fi
if [ -f Cargo.lock ]; then
  say "cargo"
  if command -v cargo-audit >/dev/null 2>&1; then cargo audit 2>/dev/null; else echo "cargo install cargo-audit, then run again"; fi
  ran=1
fi
if [ -f Gemfile.lock ]; then
  say "bundler"
  if command -v bundle-audit >/dev/null 2>&1; then bundle-audit check --update 2>/dev/null; else echo "gem install bundler-audit, then run again"; fi
  ran=1
fi
if [ -f go.sum ]; then
  say "go"
  if command -v govulncheck >/dev/null 2>&1; then govulncheck ./... 2>/dev/null; else echo "go install golang.org/x/vuln/cmd/govulncheck@latest, then run again"; fi
  ran=1
fi
if [ -f Podfile.lock ] || [ -f Package.resolved ]; then
  say "ios"
  echo "no built-in audit for CocoaPods or SwiftPM. Check each pinned version against the project's releases page; the Package.resolved diff in a PR is the review."
  ran=1
fi

[ "$ran" = 0 ] && echo "no lockfile or manifest found here. Run it from the repo root."
exit 0
