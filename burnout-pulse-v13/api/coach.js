// api/coach.js
//
// The conversational coach endpoint. When ANTHROPIC_API_KEY is set in
// the deployment environment, the app's coach calls this and becomes
// fully conversational. Without a key, the app falls back to its local
// context-aware coach and never calls this file.
//
// Two things matter here:
//  1. The safety check runs on the SERVER, before and around the model.
//     A live model is good but not guaranteed; the crisis response is
//     too important to leave entirely to generation.
//  2. The system prompt fixes the coach's character: gentle, honest,
//     never inventing facts about the user, never cheerful at the wrong
//     moment.

const DISTRESS = [
  'kill myself', 'end my life', 'end it all', 'want to die', 'better off dead',
  'suicide', 'suicidal', 'harm myself', 'hurt myself', 'self harm', 'self-harm',
  'cut myself', 'overdose', 'no reason to live', "can't go on", 'cant go on',
  "don't want to be here", 'dont want to be here', 'no point anymore',
  'everyone would be better without me', 'take my own life'
];

function detectDistress(text) {
  const t = ' ' + String(text).toLowerCase().replace(/[^a-z\s']/g, ' ') + ' ';
  return DISTRESS.some(p => t.indexOf(p) !== -1);
}

const CARE_REPLY =
  "I hear you, and I'm really glad you said that out loud to me rather than " +
  "carrying it alone. I'm not going to rush past it.\n\n" +
  "I'm a supportive space to think, but I'm not the right kind of help for " +
  "what you're carrying right now, and you deserve someone who is.\n\n" +
  "Please reach out to one of these. They are for doctors, free, and confidential:\n\n" +
  "\u2022 Physician Support Line: 1-888-409-0141, staffed by psychiatrists\n" +
  "\u2022 If you're in crisis right now: call or text 988\n\n" +
  "You don't have to have the right words ready. You can just call. " +
  "I'll still be here after.";

function systemPrompt(context) {
  let ctx = '';
  if (context && context.latestScore != null) {
    ctx = `\n\nThe user's most recent burnout check-in scored ${context.latestScore} ` +
      `out of 100 (${context.latestBand}; higher means more strain).`;
    if (context.strained && context.strained.length) {
      ctx += ` The dimensions they scored worst on: ${context.strained.join(', ')}.`;
    }
    if (typeof context.direction === 'number') {
      ctx += context.direction > 0
        ? ' Their score rose since the week before.'
        : context.direction < 0
          ? ' Their score fell since the week before.'
          : '';
    }
  }
  return [
    'You are the coach inside Burnout Pulse, a check-in tool for physicians.',
    'The person you are talking to is a doctor. Your job is to be a calm,',
    'honest place for them to think out loud about their work and how they',
    'are holding up.',
    '',
    'Character:',
    '- Gentle, warm, unhurried. Never clinical, never chirpy.',
    '- Honest. Do not give reassurance you cannot stand behind. Do not invent',
    '  facts about the user or their situation. If you do not know, say so.',
    '- You can reference their check-in scores when relevant, but never make',
    '  up scores or history you were not given.',
    '- Short replies. Two or three sentences usually. Ask one real question',
    '  rather than offering a list of tips.',
    '- You are not a therapist and you do not diagnose. You can say that',
    '  plainly if it comes up.',
    '',
    'If the person expresses thoughts of suicide or self-harm, do not try to',
    'counsel them through it and do not be falsely upbeat. Be brief and warm,',
    'tell them they deserve real support, and point them to the Physician',
    'Support Line (1-888-409-0141) and 988.' + ctx
  ].join('\n');
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { message, history, context } = req.body || {};
  if (typeof message !== 'string' || message.trim().length === 0) {
    return res.status(400).json({ error: 'A message is required.' });
  }
  if (message.length > 4000) {
    return res.status(400).json({ error: 'Message is too long.' });
  }

  // Safety first. If the message signals crisis, return the care reply
  // directly and do not call the model at all. The client also shows
  // its own care block; this guarantees the right response even if the
  // client check and the server check ever drift apart.
  if (detectDistress(message)) {
    return res.status(200).json({ reply: CARE_REPLY, care: true });
  }

  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    // No key: tell the client plainly so it uses its local fallback.
    return res.status(503).json({ error: 'Coach API is not configured.' });
  }

  // Build the message list from the recent history plus the new message.
  const msgs = [];
  if (Array.isArray(history)) {
    history.slice(-12).forEach(function (m) {
      if (!m || !m.text) return;
      if (m.role === 'user') msgs.push({ role: 'user', content: m.text });
      else if (m.role === 'coach') msgs.push({ role: 'assistant', content: m.text });
      // 'care' messages are not replayed to the model
    });
  }
  msgs.push({ role: 'user', content: message.trim() });

  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-6',
        max_tokens: 400,
        system: systemPrompt(context),
        messages: msgs
      })
    });

    if (!response.ok) {
      return res.status(502).json({ error: 'Coach service is unavailable.' });
    }

    const data = await response.json();

    // Read text by block type, never by position.
    const text = Array.isArray(data.content)
      ? data.content
          .filter(b => b && b.type === 'text')
          .map(b => b.text)
          .join('\n')
          .trim()
      : '';

    if (!text) {
      return res.status(502).json({ error: 'Coach service returned nothing usable.' });
    }

    // Post-generation safety net. The user's input already passed the
    // distress check above, but if the model's own reply raises the
    // subject of suicide or self-harm, make sure the resources are
    // attached rather than trusting the generation alone.
    if (detectDistress(text)) {
      return res.status(200).json({
        reply: text.trim() + '\n\n' +
          'One more thing, and I mean it gently: if any of this is ' +
          'sitting heavier than usual, the Physician Support Line ' +
          '(1-888-409-0141) and 988 are there, free and confidential.',
        care: true
      });
    }

    return res.status(200).json({ reply: text });
  } catch (err) {
    return res.status(502).json({ error: 'Coach service is unavailable.' });
  }
}
