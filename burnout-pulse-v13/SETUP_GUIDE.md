# Burnout Pulse: Complete Setup Guide

This guide takes you from the zip file on your MacBook to a live website with
a working AI coach. It assumes you have never deployed anything before. Every
step is spelled out.

Read this start to finish once before you begin, so you know what is coming.

## How long this takes

About 45 minutes the first time. Most of it is creating accounts and waiting
for things to load. None of it is hard.

## What you will end up with

- Your app live on the internet at a real web address
- A working, conversational AI coach
- (Optional, second half of this guide) a real database so accounts and chat
  work across devices

## The order we will do things

1. Get your computer ready (free tools)
2. Put your code on GitHub
3. Deploy to Vercel (this gets you a live website)
4. Get an Anthropic API key (this powers the AI coach)
5. Add the key to Vercel (this turns the coach on)
6. (Optional) Set up Supabase (the real database)

Do part 1 through 5 first. Get that working. Then decide if you want part 6.

You will need to create accounts on three websites: GitHub, Vercel, and
Anthropic. All three are free to sign up. Use the same email for all three to
keep it simple. Have that email open in another tab, you will get
confirmation messages.

===============================================================================
PART 1: GET YOUR COMPUTER READY
===============================================================================

You need two free things: a tool called Git, and a code editor. If you are
not sure whether you have them, just follow along, the steps check for you.

## Step 1.1: Open the Terminal

The Terminal is an app on your Mac where you type commands.

1. Press Command and the Spacebar at the same time. A search box appears.
2. Type: Terminal
3. Press Return.

A small window opens with text in it. This is the Terminal. Leave it open.
When this guide says "run" a command, it means: click the Terminal window,
type the command, and press Return.

## Step 1.2: Check if you have Git

In the Terminal, run this:

    git --version

Two things can happen:

- It prints something like "git version 2.39.0". You have Git. Skip to
  Step 1.4.
- A window pops up offering to install "command line developer tools". Click
  "Install" and wait for it to finish (a few minutes). When it is done,
  continue to Step 1.3.

## Step 1.3: Confirm Git installed

After the install finishes, run this again:

    git --version

It should now print a version number. If it does, good.

## Step 1.4: Download a code editor

You need an editor to make one small change to a file later. We will use VS
Code. It is free.

1. Open your web browser.
2. Go to: https://code.visualstudio.com
3. Click the big blue download button. It should say "Download for Mac".
4. When the download finishes, open your Downloads folder.
5. You will see a file that unzips to an app called "Visual Studio Code".
   Drag that app into your Applications folder.
6. Open it once from Applications so your Mac trusts it. If a box asks "are
   you sure you want to open it", click "Open".

You now have everything your computer needs.

## Step 1.5: Unzip the project

1. Find the file `burnout-pulse-v11.zip` (the one you downloaded).
2. Double-click it. A folder called `burnout-pulse` appears next to it.
3. Move that `burnout-pulse` folder somewhere you will remember. Your
   Documents folder is fine.

Keep note of where it is. In the next part you will need to find it.

===============================================================================
PART 2: PUT YOUR CODE ON GITHUB
===============================================================================

GitHub is a website that stores code. Vercel reads your code from GitHub to
build your site. Think of GitHub as the shelf your code sits on, and Vercel
as the thing that reads from that shelf.

## Step 2.1: Create a GitHub account

1. Go to: https://github.com
2. Click "Sign up".
3. Enter your email, make a password, pick a username. Write the username
   and password down somewhere safe.
4. GitHub will email you a code to confirm. Get it from your email and enter
   it.
5. If it asks questions about team size or how you plan to use GitHub, pick
   anything, it does not matter. Choose the free plan if asked.

## Step 2.2: Create a new repository

A "repository" (or "repo") is one project's folder on GitHub.

1. Once signed in, look at the top right. Click the "+" icon.
2. Click "New repository".
3. In "Repository name", type: burnout-pulse
4. Leave it set to "Public" (this is fine, your secret key is NOT in the
   code, it goes into Vercel later).
5. Do NOT check "Add a README file". Leave all the checkboxes empty.
6. Click the green "Create repository" button.

You now see a page with setup instructions. Leave this page open. You will
copy something from it shortly.

## Step 2.3: Upload your code the simple way

GitHub lets you drag files in through the browser. This is the easiest way
and needs no commands.

1. On that repository page, look for a link that says "uploading an existing
   file". It is in the text in the middle of the page. Click it.
   - If you cannot find it, go to this address in your browser, replacing
     YOUR-USERNAME with your GitHub username:
     https://github.com/YOUR-USERNAME/burnout-pulse/upload/main
2. Now open the `burnout-pulse` folder on your Mac (the one you unzipped).
3. Select everything inside it. Click one file, then press Command and A to
   select all. You should have these selected: index.html, README.md,
   PRIVACY.md, package.json, vercel.json, the `api` folder, and the
   `supabase` folder.
4. Drag all of them into the GitHub upload area in your browser.
5. Wait for the files to finish uploading. The `api` and `supabase` folders
   will upload with their contents inside them.
6. Below the upload area, find the green "Commit changes" button. Click it.

After a moment, your repository page reloads and you see your files listed:
index.html, README.md, an `api` folder, and so on. Your code is now on
GitHub.

===============================================================================
PART 3: DEPLOY TO VERCEL
===============================================================================

Vercel takes the code from GitHub and turns it into a live website. This is
the step that gives you a real web address.

## Step 3.1: Create a Vercel account

1. Go to: https://vercel.com
2. Click "Sign Up".
3. Choose "Hobby" if it asks what plan. Hobby is free.
4. It will offer ways to sign up. Click "Continue with GitHub". This links
   the two accounts, which is what we want.
5. A GitHub window appears asking to authorize Vercel. Click the green
   "Authorize Vercel" button.
6. Vercel may ask for your name. Enter it and continue.

## Step 3.2: Import your project

1. Once in Vercel, you land on a dashboard. Look for a button that says
   "Add New..." or "Import Project" or "New Project". Click it, then choose
   "Project".
2. Vercel shows a list of your GitHub repositories. Find "burnout-pulse" in
   the list.
   - If the list is empty or burnout-pulse is missing, click the
     "Adjust GitHub App Permissions" or "Configure GitHub App" link, and
     give Vercel access to your repositories. Then come back.
3. Next to "burnout-pulse", click "Import".

## Step 3.3: Deploy

1. You now see a "Configure Project" page. It has a "Framework Preset"
   setting. It should say "Other". If it does not, click it and choose
   "Other".
2. Do NOT change anything else. Do not touch the build settings.
3. Ignore the "Environment Variables" section for now. We add the key in
   Part 5.
4. Click the big "Deploy" button.
5. Wait. Vercel shows a progress screen with logs scrolling. This takes one
   to two minutes. When it finishes you see a "Congratulations" screen,
   often with confetti.

## Step 3.4: See your live site

1. On the success screen, click the screenshot of your site, or click
   "Continue to Dashboard" and then "Visit".
2. Your app opens at a real web address, something like
   `burnout-pulse-xxxx.vercel.app`.
3. Try it: create an account, do a check-in. It all works.

Your site is live. The AI coach will still be in basic local mode until we
do the next two parts. The note under the coach message box tells you which
mode it is in.

Write down your web address. That is your app now.

===============================================================================
PART 4: GET AN ANTHROPIC API KEY
===============================================================================

The API key is what lets your coach use real AI. It is a long secret string
of letters and numbers. Treat it like a password.

## Step 4.1: Create an Anthropic account

1. Go to: https://console.anthropic.com
2. Sign up with your email. Confirm with the code they email you.

## Step 4.2: Add billing

The coach is billed by use. There is no monthly fee, but Anthropic needs a
payment method on file before it will give you a working key. At low personal
use the cost is small, but the exact price per message depends on the model
and changes over time. Check the current rates here before you commit:
https://www.anthropic.com/pricing

To add billing:

1. In the console, find "Billing" or "Plans" in the menu (often a left
   sidebar or under your account).
2. Add a payment method.
3. Many accounts can add a small amount of starting credit, for example 5
   dollars, which is plenty to test the coach for a long time. Add a small
   amount, not a large one.

If you are not ready to add billing, you can stop here. Your app is already
live from Part 3, the coach just stays in basic local mode until a key is
added. You can come back to this any time.

## Step 4.3: Create the key

1. In the console, find "API Keys" in the menu.
2. Click "Create Key".
3. Give it a name, for example: burnout-pulse
4. It shows you the key. It starts with `sk-ant-`.
5. IMPORTANT: copy it now and paste it somewhere safe and temporary, like a
   note. Once you close this box, you cannot see the key again. If you lose
   it, you simply delete it and make a new one, no harm done.

Do not put this key in your code. Do not upload it to GitHub. It goes into
Vercel only, which is the next part.

===============================================================================
PART 5: ADD THE KEY TO VERCEL (TURNS THE COACH ON)
===============================================================================

## Step 5.1: Open your project settings

1. Go to https://vercel.com and sign in.
2. Click your "burnout-pulse" project.
3. Along the top, click the "Settings" tab.
4. In the settings menu, click "Environment Variables".

## Step 5.2: Add the key

An environment variable is a secret value Vercel keeps for your app, separate
from your code.

1. You see fields for adding a variable. In the "Key" or "Name" field, type
   exactly this, with no spaces:

       ANTHROPIC_API_KEY

   It must be spelled exactly like that, all capital letters, with
   underscores. This is the name your code looks for.

2. In the "Value" field, paste your actual key, the `sk-ant-...` string from
   Part 4.

3. If it asks which environments, make sure all of them are checked
   (Production, Preview, Development). Usually they all are by default.

4. Click "Save".

## Step 5.3: Redeploy so the key takes effect

Adding the key does not update the live site by itself. You must redeploy.

1. In your project, click the "Deployments" tab at the top.
2. You see a list. The top one is your current live site.
3. On the right of that top row, click the "..." menu (three dots).
4. Click "Redeploy".
5. A box appears. Click "Redeploy" again to confirm.
6. Wait one to two minutes for it to finish.

## Step 5.4: Test the real coach

1. Open your live site again (your `.vercel.app` address).
2. Sign in.
3. Go to the Coach tab.
4. Send a message, something real, like: "today was long and I am drained".
5. The reply should now be a genuine, thoughtful answer that responds to
   exactly what you said. The small note under the message box should now
   say "Live coach".

If it still says local mode, see Troubleshooting at the end of this guide.

Your AI coach is now live. If you only wanted the coach, you are done. Part 6
is optional.

===============================================================================
PART 6 (OPTIONAL): SET UP SUPABASE, THE REAL DATABASE
===============================================================================

Right now, accounts and chat are saved only in each person's browser. That is
fine for one person testing on one device. Supabase makes them real: stored
in a proper database, working across devices, with friends chat that actually
reaches another person.

This part is more involved. Skip it if you just wanted the app and the coach
working. You can do it later.

Be aware of one honest limit. This guide and the included `schema.sql` set up
the database itself completely. Connecting the app's screens to that database
is a further coding step that is not just copy and paste, it is described as a
focused task in `supabase/SUPABASE_SETUP.md`. So Part 6 below gets the
database fully built and ready. Wiring the app to it is the step after.

## Step 6.1: Create a Supabase account

1. Go to: https://supabase.com
2. Click "Start your project".
3. Sign up. Signing up with your GitHub account is the simplest option.

## Step 6.2: Create a project

1. Click "New project".
2. If asked about an organisation, create one, any name is fine.
3. Project name: burnout-pulse
4. It asks for a database password. Click "Generate a password", then copy
   it and save it somewhere safe. You may need it later.
5. Choose a region close to where you live.
6. Choose the free plan.
7. Click "Create new project".
8. Wait. Setting up the database takes a couple of minutes. Let it finish.

## Step 6.3: Run the database script

1. When the project is ready, look at the left sidebar for an icon called
   "SQL Editor". Click it.
2. Click "New query".
3. On your Mac, open the `burnout-pulse` folder, go into the `supabase`
   folder, and open the file `schema.sql` with VS Code (right-click the
   file, "Open With", "Visual Studio Code").
4. In VS Code, select all the text: click in the file, press Command and A.
   Copy it: Command and C.
5. Go back to the Supabase SQL Editor in your browser. Click in the empty
   query area and paste: Command and V.
6. Click "Run" (a button at the bottom right of the editor, or press Command
   and Return).
7. It should say "Success" with no rows returned. That is correct, this
   script builds tables, it does not return data.

If you see a red error, read Troubleshooting at the end.

## Step 6.4: Get your Supabase keys

1. In the left sidebar, click the "Settings" gear icon.
2. Click "API" in the settings menu.
3. You see two things you need:
   - "Project URL", a web address ending in `.supabase.co`
   - "Project API keys", and under it a key labelled "anon" and "public"
4. Copy both into your safe note. Label them clearly. The `anon` `public`
   key is safe to use in app code, that is its purpose. Do NOT copy or use
   the `service_role` key, that one is dangerous in a browser.

## Step 6.5: Turn on email sign-up

1. In the left sidebar, click "Authentication".
2. Click "Providers" (or "Sign In / Up").
3. Make sure "Email" is enabled.
4. While testing, you can turn off "Confirm email" so test sign-ups are
   instant. Turn it back on before real users join.

## Step 6.6: The database is ready

The database now exists with all its security rules. The remaining step,
connecting the app screens to it, is the focused coding task described in
`supabase/SUPABASE_SETUP.md`. You have everything that task needs: the
Project URL and the anon key from Step 6.4.

===============================================================================
HOW TO MAKE A CHANGE LATER
===============================================================================

When you want to change something in the app:

1. Edit the file on GitHub directly (open the file on your repo page, click
   the pencil icon, edit, click "Commit changes"); or edit on your Mac and
   re-upload through the GitHub upload page like in Part 2.
2. Vercel notices the change on GitHub and redeploys automatically within a
   minute or two.

You do not touch Vercel to ship a change. You change GitHub, Vercel follows.

===============================================================================
TROUBLESHOOTING
===============================================================================

## The coach still says "local mode" after Part 5

- Check the variable name in Vercel is exactly ANTHROPIC_API_KEY, all caps,
  underscores, no spaces, no quotes around it.
- Check you redeployed after adding the key (Step 5.3). Adding the key
  without redeploying does nothing.
- Check the key value is the full string starting with sk-ant- and has no
  extra spaces at the start or end.
- Check that billing is set up on the Anthropic account (Part 4.2). Without
  it, the key exists but will not work.

## Vercel cannot find my repository

- In Vercel, on the import screen, click "Adjust GitHub App Permissions" and
  grant access to the burnout-pulse repository, then return.

## The GitHub upload is missing the api or supabase folder

- Re-do Step 2.3 and make sure you drag the FOLDERS themselves, not just
  loose files. The folders carry their contents.

## The Supabase SQL script showed a red error

- Make sure you copied the entire `schema.sql` file, from the very first
  line to the very last.
- If it complains that something "already exists", the script was already
  run once. That is usually harmless.

## I lost my API key

- No problem. In the Anthropic console, delete the old key and create a new
  one (Part 4.3), then update it in Vercel (Part 5.2) and redeploy.

## My site shows an old version

- Vercel updates a minute or two after GitHub changes. Wait, then refresh.
  In your browser you can also do a hard refresh: hold Shift and click the
  reload button.

===============================================================================
A NOTE ON COST AND SAFETY
===============================================================================

- GitHub: free for this.
- Vercel: the Hobby plan is free and is enough for this app.
- Supabase: the free plan is enough to start.
- Anthropic: billed by use. Add only a small amount of credit. Watch your
  usage in the console. There is no monthly fee, you spend only what the
  coach actually uses.

Never put your API key into the code or onto GitHub. It belongs only in
Vercel's Environment Variables. If you ever paste it somewhere public by
accident, delete that key in the Anthropic console immediately and make a
new one.
