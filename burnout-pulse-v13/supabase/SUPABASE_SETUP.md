# Supabase setup

This connects Burnout Pulse to a real backend. After this, accounts,
check-ins, the coach log, the leaderboard, and friends chat are stored in a
database and work across devices. Friends chat becomes real two-person
messaging.

The app works fine without any of this. Only do it when you want the backend.

## What you need

A Supabase account (the free tier is enough to start) and about fifteen
minutes.

## Step 1: Create a project

Go to supabase.com, create a new project, and wait for it to finish
provisioning. Pick a region close to your users.

## Step 2: Run the schema

In the project, open the SQL editor. Open `schema.sql` from this folder, copy
all of it, paste it into a new query, and run it.

This creates six things: the `profiles`, `checkins`, `coach_messages`,
`friendships`, and `messages` tables, plus the `leaderboard` view. It also
turns on row-level security for every table and adds the policies that keep
each user's data private. It adds a trigger that creates a profile row
automatically whenever someone signs up.

Read the comments in `schema.sql` if you want to understand exactly what each
policy allows. The short version: a user can touch only their own rows, chat
messages are visible only to the two people in a friendship, and the
leaderboard exposes nothing but an anonymous handle and a score.

## Step 3: Get your keys

In the project settings, under API, copy two values:

- The project URL
- The `anon` public key

The anon key is safe to ship in client-side code. It is designed for that.
The security comes from the row-level security policies, not from hiding the
key. Do not ship the `service_role` key; that one bypasses every policy and
belongs only in server environments.

## Step 4: Add the keys to the app

You have two options.

For local testing, you can set them directly in `index.html`. Near the top of
the script, add:

```
window.BP_SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
window.BP_SUPABASE_ANON_KEY = "your-anon-key";
```

For a real deployment, set `SUPABASE_URL` and `SUPABASE_ANON_KEY` as
environment variables in Vercel and read them in through a small config
endpoint, so the keys are not committed to your repository.

## Step 5: Turn on email auth

In the Supabase project, under Authentication, make sure email sign-up is
enabled. For a smoother first run you can turn off email confirmation while
testing, then turn it back on before real users arrive.

## A note on the integration code

`schema.sql` is the database half and it is complete. The client half, the
code in `index.html` that calls Supabase instead of localStorage, is the part
you wire in. The app is structured to make this swap contained: account
reads and writes, check-in saves, coach log, leaderboard, and friends all go
through a small set of functions. Point those functions at the Supabase
client and the UI does not change.

If you want that client integration written out as well, it is a focused next
task rather than something to paste in blind. Build it deliberately, test the
row-level security policies with two real accounts, and confirm that account A
genuinely cannot read account B's data before going live.

## Checking the security policies actually work

Before you trust it, test it. Create two accounts. As account A, try to read
account B's check-ins and coach log. You should get nothing back. Add each
other as friends, accept, and confirm both can see the shared thread and
neither can see a thread they are not part of. If any of that fails, stop and
fix the policies before real data goes in.
