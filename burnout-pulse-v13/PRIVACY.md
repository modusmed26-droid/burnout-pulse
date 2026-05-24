# Privacy

Burnout Pulse runs in one of two modes, and what happens to your data depends
on which one. This document covers both plainly.

## Default mode: everything stays on your device

Out of the box, with no setup, the app stores everything in your browser's
localStorage. That means:

- Your local account (email, first name, a Base64-encoded passphrase)
- Every saved check-in (date, six answers, score)
- Your full coach conversation log
- The leaderboard, if you switch it on
- Your friends list and chat threads

None of it is sent to a server, because in this mode there is no server. There
is no analytics and no tracking.

Two consequences. First, your data lives only in the browser on the device you
used. A different browser or device starts empty. Clearing this site's browser
data deletes everything and it cannot be recovered. Second, the coach in this
mode runs locally and does not send your messages anywhere.

## About the word "encryption"

In default mode the passphrase is Base64-encoded. That keeps it from sitting
in plain text in the developer console. It is not encryption. It is reversible
by anyone who looks. Do not reuse an important password for your local
account. It is a way to keep two people's histories separate in one browser,
not a security boundary.

If you set up the Supabase backend, this changes: Supabase Auth handles
passwords properly, with real hashing, and the app no longer stores a
passphrase itself.

## If you wire in the coach API

If a deployer sets an Anthropic API key and turns on the coach endpoint, then
your coach messages are sent to the Anthropic API to generate replies, along
with recent conversation context and your check-in scores. They are not sent
anywhere else. The crisis-safety check runs on the server before any message
reaches the model. See Anthropic's own data policies for how they handle API
requests.

If no key is set, none of this applies and the coach stays fully local.

## If you wire in the Supabase backend

With Supabase connected, your account, check-ins, coach log, and friends chat
are stored in a Supabase database instead of the browser, so they work across
devices.

The database schema (`supabase/schema.sql`) enforces row-level security. In
plain terms: a signed-in user can read and write only their own profile,
their own check-ins, and their own coach log. Chat messages are readable only
by the two people in that friendship. The leaderboard is a view that exposes
only an anonymous handle and a score, never a name, email, or user ID.

This is a real improvement in durability and a reasonable privacy posture, but
it is still not a HIPAA-compliant medical record system, and the app does not
claim to be one. HIPAA compliance involves business associate agreements,
formal access controls, and audit infrastructure beyond what a schema file
provides. If your institution requires a specific compliance standard, treat
this as a starting point to discuss with them, not a finished answer.

## The leaderboard

The leaderboard is off by default. Switching it on adds an anonymous handle
(an animal name and a number) and your most recent score. It never publishes
your name or email. You can switch it off at any time, which removes you.

## Friends and chat

Adding a friend and messaging them is opt-in. In default mode the thread lives
on your device. With Supabase, messages are stored server-side and visible
only to the two people in the thread, enforced by the security policies in the
schema.

## Deleting your data

In default mode, clearing this site's browser data removes everything. With
Supabase, deleting your account removes your rows; the schema is set so that
deleting a user cascades to their check-ins, coach log, friendships, and
messages.
