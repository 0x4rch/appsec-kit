# A security page in an afternoon

Copy this to /security on your site. Fill in only what is true. A short page
with real sentences beats a long one with borrowed ones, and a buyer's first
question is usually answered by the first three sections.

---

## Security at {Company}

We are a small team and this page says plainly what we do. If you need more
detail for a review, email {security@company.com} and a person will answer.

### Where your data lives
Hosted on {provider} in {region}. The database is {Postgres on Supabase /
Firestore / ...}. Backups run {daily} and are kept for {30 days}; we tested a
restore on {date}.

### Encryption
All traffic uses HTTPS. Data is encrypted at rest by {provider}. Passwords are
hashed with {bcrypt / argon2}; we never see them. API keys and secrets live in
{a secrets manager / environment variables on the server}, never in the app.

### Who can access it
{N} people have production access, each with their own account and two-factor
authentication. Access is reviewed {quarterly / when someone joins or leaves}.
Customer data is only accessed to support you, and we log when it happens.

### How the app is protected
{Row level security / per-user authorization} on every table and endpoint.
Dependencies are audited {weekly}. {Rate limits on login and signup.} Security
headers are set and checked.

### Third parties that receive data
{Stripe (payments), Postmark (email), PostHog (analytics)}. Each receives only
what it needs. The full list and what each receives is in our privacy policy.

### If something goes wrong
We will tell affected customers within {72 hours} of confirming an incident,
say what was reached and what we did. Report a vulnerability to
{security@company.com}; we reply within {two business days} and will not take
action against good-faith research.

### What we do not have yet
{No SOC 2 report. No penetration test yet; planned for {quarter}.} We would
rather say so than imply otherwise.

Last updated {date}.
