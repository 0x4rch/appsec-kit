# appsec-kit

Small scripts and checklists for people who ship software and do not have a
security person. Each one does one thing, reads only, and explains itself at
the top of the file. Nothing here phones home.

| File | What it does |
|---|---|
| [secret-scan.sh](secret-scan.sh) | A git pre-commit hook that refuses to commit anything shaped like a key |
| [dep-audit.sh](dep-audit.sh) | Runs the right dependency audit for whatever package manager the repo uses |
| [headers-check.sh](headers-check.sh) | One curl: which security headers and cookie flags a site is missing, and why each matters |
| [bundle-strings.sh](bundle-strings.sh) | Unzips your own app build and shows what anyone with the public build can read in it |
| [supabase-rls-check.sql](supabase-rls-check.sql) | Lists tables with row level security off, tables with no policies, and every policy you have |
| [pre-ship-prompt.md](pre-ship-prompt.md) | The prompt to run in Claude Code or Codex before shipping an agent-built app |
| [security-page.md](security-page.md) | A /security page template in plain sentences, only what is true |

Run them on your own software. Someone else's needs their written permission.

By [Nate Parker](https://nateparker.dev). MIT licensed.
