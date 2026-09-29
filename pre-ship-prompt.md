# The prompt to run before you ship an agent-built app

Paste this into Claude Code, Codex or whatever built the app, from the repo
root. It asks for a list first and fixes second, one diff at a time, so you
can read each change before it lands. Run it again after; the second list
should be short.

---

Before I ship this app I want a security pass. Do not change anything yet.

First, read the whole codebase and list, with file and line:

1. Every secret that reaches the client: any API key, token, service-role key,
   admin credential or private key in frontend code, the mobile bundle, a
   public config file or a committed .env. For each, say whether it is meant to
   be public (a Supabase anon key, a Firebase web config, a Stripe publishable
   key are) or not.
2. Every database table without row level security or equivalent rules, and
   every table whose rules allow any authenticated user to read or write rows
   that belong to another user.
3. Every API endpoint, edge function or server action that does not verify the
   caller's identity from the session or token, or that takes the user id from
   the request body instead of the verified session.
4. Every authorization check that exists only in the UI (a hidden button, a
   disabled menu item, a client-side role check) with no matching check on the
   server.
5. Every place the app trusts input without validating it: file uploads,
   redirects, HTML rendered from user text, SQL or shell built from strings.
6. Every webhook handler that does not verify the provider's signature.
7. Every login, signup or password reset path with no rate limit.
8. Any error response that returns a stack trace, a query or an internal path.

Then, for each item, one at a time: propose the fix as a diff, explain it in
two plain sentences, and wait for me to say yes before applying it. Do not
batch them. Do not add new dependencies without asking. Do not rewrite files
you were not asked to touch.

When we are done, print the list again with each item marked fixed, deferred
or not-an-issue, with one line of reason each.
