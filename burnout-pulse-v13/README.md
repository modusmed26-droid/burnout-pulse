# Burnout Pulse

A weekly check-in for physicians, with a coach to talk things through and
advice that fits your scores. The check-in takes about two minutes. The rest
is there when you want it.

## What's new in v13

- **Onboarding asks what kind of doctor you are.** Eight broad specialties:
  ER, Surgery, Internal Medicine, Family Medicine, Pediatrics, Psychiatry,
  OB/GYN, Anesthesia. Some of the check-in questions are reworded to fit your
  actual day, the scoring stays the same so trends stay comparable.
- **Journal tab.** A private notepad with optional photos. Lives only on
  your device. Honest about its limits so you know not to put anything
  identifying there.
- **About tab.** What the app is, the six dimensions and where they come
  from, the privacy stance, what the app is not.
- **A loading screen and a pull-up gesture into sign-in.** Touch drag-up on
  mobile, tap-or-drag on desktop, both work.
- **A box-open animation** into the main app on successful sign-in. Honors
  prefers-reduced-motion.

## What's in it

**Check-in.** Six questions about how the week treated you: energy left over,
connection to patients, sense of doing good work, control over your day,
recovery off the clock, and how the next shift feels. Each answer is on a
five-point scale. The six answers become one 0 to 100 score. Higher means
more strain.

The wording adapts to your specialty. An ER doctor gets "By the end of a
shift, how depleted do you feel?" A surgeon gets "After a long OR day...".
A psychiatrist gets "After a day of sessions..." The underlying six axes are
the same, so your trend stays comparable across the app.

**Trend.** Every check-in is filed with its date so you can see the run of
scores over weeks. One bad week is one bad week. Four in a row is a pattern.
Below the trend, the app gives advice for each of the six dimensions, keyed
to how you scored that dimension on your latest check-in. Low control gets
different advice than low recovery.

**Coach.** A conversational space to think out loud. Tell it about your day,
say what's on your mind. It knows your check-in scores and remembers past
conversations, so it can talk about specifics rather than generalities. It is
gentle but it does not pretend. It will not give you reassurance it cannot
stand behind.

**Journal.** A private place to write about a day, with up to four photos
per entry if a picture helps. Stored only on your device. Photos are shrunk
to 1600px on the long edge before being saved as data URLs in localStorage.
The journal is honest about what "private" means here: it is private from
other accounts and other devices, but anyone with this device unlocked can
read it. Don't store anything that needs to be properly secured.

**People.** A leaderboard and a friends list, both optional and both off by
default. The leaderboard is opt-in and anonymous: an animal-and-number handle
and your latest score, nothing else. Friends lets you keep a private
check-in thread with someone you add by email.

**About.** What the app is, the six dimensions and where they come from, the
privacy stance, what the app is not. Worth reading once.

## The coach, and the safety layer

The coach is built to be warm and honest. Most of the time it just listens
and asks good questions.

There is one thing it does differently. Every message you send is checked for
language that signals a genuine crisis. For ordinary hard stuff, a bad shift,
frustration, exhaustion, even dark humor, the check does nothing and the
coach stays exactly as it is. But if something serious comes through, the
coach stops, stays warm, and points you to real help: the Physician Support
Line and 988. It does not lecture and it does not go cold. It also does not
paper over it with cheerfulness, because that is the one moment where comfort
alone is not enough.

This check runs in two places. The app does it on your device. The coach API,
if you wire it in, does it again on the server before the model is ever
called. Two layers, because getting this wrong matters more than getting
anything else in the app right.

## Two ways to run it

The app works the moment you open `index.html`, with no setup at all. In that
mode everything is stored in your browser's localStorage and nothing is sent
anywhere. The coach runs on a local fallback: it still reads your scores and
history and responds in context, it just does not have open-domain knowledge.
Friends chat works on one device.

To make the coach fully conversational and to make friends chat work between
real people on real devices, there are two upgrades. They are independent;
you can do either, both, or neither.

### Upgrade one: the conversational coach

This is the upgrade that turns the coach from a basic fallback into a real
Claude conversation. The local fallback cannot reason or answer open
questions; it varies its wording but it is still a stopgap. The real coach
needs an API key.

1. Get a key at https://console.anthropic.com. The coach is billed per
   message, by usage, with no monthly fee. Current per-message pricing
   depends on the model and is listed at https://www.anthropic.com/pricing
   and in the console. Check it there rather than trusting a number quoted
   here, since pricing changes.
2. Deploy to Vercel (see the deploying section below).
3. In the Vercel project settings, add an environment variable named
   `ANTHROPIC_API_KEY` with your key as the value.
4. Redeploy.

That is all. The app already calls `/api/coach` on its own, so there is no
code to edit. Once a key is present, the coach is a full conversation and the
note under the message box changes to "Live coach". With no key, `api/coach.js`
returns a 503 and the app falls back to the local coach.

One thing to know: opening `index.html` as a local file will always use the
fallback, because a local file has no server to run `api/coach.js`. The real
coach exists only on a deployment. To point the app at a different endpoint
path, set `window.BP_COACH_ENDPOINT` in the script.

### Upgrade two: the Supabase backend

This makes accounts, check-in history, the coach log, the leaderboard, and
friends chat real and server-backed, so they work across devices and friends
chat works between two actual people.

The full walkthrough is in `supabase/SUPABASE_SETUP.md`. In short: create a
Supabase project, run `supabase/schema.sql` in its SQL editor, and add your
Supabase URL and anon key to the app. The schema includes row-level security
so a user can only ever read their own data, their own coach log, and
messages inside friendships they belong to.

## Running locally

```
open index.html
```

That is the whole thing. No build step.

## Deploying

```
git init
git add .
git commit -m "initial"
# push to a GitHub repo, then import it at vercel.com
```

`vercel.json` sets a few sensible security headers.

## Files

```
index.html               the whole app
api/coach.js              conversational coach endpoint (optional)
supabase/schema.sql       database tables and security policies (optional)
supabase/SUPABASE_SETUP.md  step by step backend guide
vercel.json               deploy config and headers
package.json              metadata
.env.example              template for the optional keys
PRIVACY.md                what is stored and where, in plain language
```

## What this is, and what it is not

Burnout Pulse is a reflection tool. The score borrows its three core ideas
from the Maslach Burnout Inventory, but it is not the MBI and is not a
diagnostic instrument. The coach is supportive, not a therapist.

A weekly score does one useful thing: it makes a slow change visible while
there is still room to act on it. The app is direct about its own limits, and
on the screen where scores run highest it says the plain thing, that the next
step is a person, not a number.
