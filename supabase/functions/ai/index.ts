// ÍslandFit — AI proxy (Supabase Edge Function, Deno).
// The Anthropic API key lives ONLY here (a Supabase secret), never in the public HTML.
// The browser calls this function with the signed-in user's Supabase JWT; Supabase verifies
// it (verify_jwt defaults to true), so only logged-in users can reach it.
//
// DEPLOY (dashboard, no CLI needed):
//   Supabase → Edge Functions → Deploy a new function → name it "ai" → paste this file → Deploy
//   Then Supabase → Project Settings → Edge Functions → Secrets → add  ANTHROPIC_API_KEY = sk-ant-...
// DEPLOY (CLI):
//   supabase functions deploy ai
//   supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
//
// Get an API key at https://console.anthropic.com  (Billing → add a little credit).

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";

// Quality vs. cost. Opus 4.8 is the most capable (and priciest: ~$5/$25 per 1M tokens).
// For a high-volume free app, switch to "claude-sonnet-4-6" (~2x cheaper) or
// "claude-haiku-4-5" (~5x cheaper) — every prompt below works on all three.
const MODEL = "claude-opus-4-8";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "content-type": "application/json" },
  });
}

async function callClaude(
  system: string,
  user: string,
  opts: { maxTokens?: number; schema?: unknown } = {},
): Promise<{ text?: string; error?: string }> {
  const key = Deno.env.get("ANTHROPIC_API_KEY");
  if (!key) return { error: "ANTHROPIC_API_KEY is not set on the server." };
  const body: Record<string, unknown> = {
    model: MODEL,
    max_tokens: opts.maxTokens ?? 1024,
    thinking: { type: "disabled" }, // fast + cheap; system prompts ask for the final answer only
    system,
    messages: [{ role: "user", content: user }],
  };
  if (opts.schema) {
    body.output_config = { format: { type: "json_schema", schema: opts.schema } };
  }
  let r: Response;
  try {
    r = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": key,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(body),
    });
  } catch (e) {
    return { error: "Could not reach Anthropic: " + (e as Error).message };
  }
  const data = await r.json().catch(() => ({}));
  if (!r.ok) return { error: data?.error?.message || ("Anthropic error " + r.status) };
  const text = (data.content || [])
    .filter((b: { type: string }) => b.type === "text")
    .map((b: { text: string }) => b.text)
    .join("");
  return { text };
}

const langLine = (lang: string) =>
  lang === "is"
    ? "Reply in Icelandic (íslenska)."
    : "Reply in English.";

// ── ACTION: weekly coaching summary (plain prose) ─────────────────────────────
async function doSummary(p: Record<string, unknown>) {
  const system =
    "You are an experienced, encouraging strength & conditioning coach. " +
    "Given a JSON snapshot of one athlete's recent training, write a short weekly check-in: " +
    "what went well, one thing to watch, and one concrete suggestion for next week. " +
    "Reference their actual numbers (e1RM changes, RPE trend, sessions logged). " +
    "Use the RPE trend, readiness check-ins, and per-lift e1RM trajectory to judge fatigue and spot stalls: " +
    "rising RPE at the same load or repeated 'low' readiness = ease off; a flat lift trajectory = change something. " +
    "Compare sessions logged vs planned_days_per_week for adherence. " +
    "ALWAYS respect any listed injuries — never suggest movements that would aggravate them. " +
    "Be specific and motivating, not generic. Use at most ~120 words, plain text with short lines or bullets. " +
    langLine(String(p.lang || "en")) +
    " Respond with the summary only — no preamble, headings, or meta-commentary.";
  const user =
    "Athlete training snapshot (JSON):\n" +
    JSON.stringify(p.data ?? {}, null, 2) +
    "\n\nWrite this week's coaching check-in.";
  return await callClaude(system, user, { maxTokens: 700 });
}

// ── ACTION: explain / coach chat (plain prose) ────────────────────────────────
async function doExplain(p: Record<string, unknown>) {
  const system =
    "You are the athlete's personal strength coach inside their training app. " +
    "Answer their question clearly and briefly using the supplied context about their program and progress. " +
    "If they ask why a weight or week looks the way it does, explain the app's logic (percentage-of-1RM waves, " +
    "RPE auto-regulation, planned deloads) in plain language. " +
    "Respect any injuries listed in the context, and factor in their readiness and recent RPE when relevant. " +
    "Be accurate and practical; never give medical advice — if something sounds like an injury, suggest seeing a professional. ~120 words max. " +
    langLine(String(p.lang || "en")) +
    " Respond with the answer only.";
  const user =
    "Context (JSON):\n" + JSON.stringify(p.context ?? {}, null, 2) +
    "\n\nQuestion: " + String(p.question || "");
  return await callClaude(system, user, { maxTokens: 700 });
}

// ── ACTION: conversational onboarding (structured JSON) ───────────────────────
const ONBOARD_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    sport: { type: "string", description: "Closest match from the provided sports list" },
    experience_level: { type: "string", enum: ["beginner", "intermediate", "advanced"] },
    primary_goal: { type: "string", description: "e.g. strength, muscle, fat loss, sport performance, general fitness" },
    equipment: { type: "string", description: "e.g. full gym, dumbbells only, bodyweight, home gym" },
    days_per_week: { type: "integer" },
    injuries: { type: "array", items: { type: "string" }, description: "Injuries or limitations mentioned; empty if none" },
    summary: { type: "string", description: "One friendly sentence summarising the plan, in the requested language" },
  },
  required: ["sport", "experience_level", "primary_goal", "equipment", "days_per_week", "injuries", "summary"],
};

async function doOnboard(p: Record<string, unknown>) {
  const sports = Array.isArray(p.sports) ? (p.sports as string[]) : [];
  const system =
    "Extract a structured training profile from the user's free-text self-description. " +
    "Map 'sport' to the single closest entry in this exact list (copy it verbatim): " +
    JSON.stringify(sports) + ". If nothing fits, use \"General\". " +
    "Infer experience_level, primary_goal, equipment, and days_per_week sensibly from what they wrote; " +
    "if days_per_week is unstated, estimate a reasonable 3 or 4. List any injuries/limitations they mention. " +
    "Write 'summary' as one friendly sentence. " + langLine(String(p.lang || "en"));
  const user = "User description:\n" + String(p.text || "");
  const res = await callClaude(system, user, { maxTokens: 500, schema: ONBOARD_SCHEMA });
  if (res.error) return res;
  try {
    return { data: JSON.parse(res.text || "{}") };
  } catch {
    return { error: "Could not parse the AI response." };
  }
}

// ── ACTION: coach adjustments (structured) ──
const ACTIONS_SCHEMA = {
  type: "object", additionalProperties: false,
  properties: {
    actions: {
      type: "array",
      items: {
        type: "object", additionalProperties: false,
        properties: {
          type: { type: "string", enum: ["deload", "swap", "load_adjust", "note"] },
          exercise: { type: "string", description: "exact current exercise name (or empty)" },
          to: { type: "string", description: "replacement exercise for a swap (or empty)" },
          pct: { type: "integer", description: "load change for load_adjust, -10..+5 (else 0)" },
          label: { type: "string" },
          reason: { type: "string" },
        },
        required: ["type", "exercise", "to", "pct", "label", "reason"],
      },
    },
  },
  required: ["actions"],
};
async function doActions(p: Record<string, unknown>) {
  const system =
    "You are the athlete's strength coach. From their training snapshot, propose 0 to 4 concrete, SAFE adjustments for the coming week. " +
    "Types: 'deload' (whole week ~15% lighter — ONLY with clear fatigue: rising RPE at the same load, repeated 'low' readiness, or missed sessions); " +
    "'swap' (set 'exercise' to the exact current name and 'to' to a replacement — ONLY to respect an injury or missing equipment); " +
    "'load_adjust' (one lift, 'pct' -10..+5, for a lift clearly too hard/easy); 'note' (advice only). " +
    "Be conservative — return an empty list if things look fine. ALWAYS respect listed injuries. " +
    "For unused fields use an empty string or 0. Each action: a short 'label' (<=6 words) + a one-line 'reason' grounded in their data. " +
    langLine(String(p.lang || "en"));
  const user = "Training snapshot (JSON):\n" + JSON.stringify(p.context ?? {}, null, 2) + "\n\nPropose this week's adjustments.";
  const res = await callClaude(system, user, { maxTokens: 800, schema: ACTIONS_SCHEMA });
  if (res.error) return res;
  try { return { data: JSON.parse(res.text || "{}") }; } catch { return { error: "Could not parse the AI response." }; }
}

// ── ACTION: compose a full program (structured) ──
const PROGRAM_SCHEMA = {
  type: "object", additionalProperties: false,
  properties: {
    name: { type: "string" },
    days_per_week: { type: "integer" },
    weeks: { type: "integer" },
    days: {
      type: "array",
      items: {
        type: "object", additionalProperties: false,
        properties: {
          title: { type: "string" }, focus: { type: "string" },
          exercises: {
            type: "array",
            items: {
              type: "object", additionalProperties: false,
              properties: {
                name: { type: "string" }, sets: { type: "integer" }, reps: { type: "string" },
                target_weight: { type: "string", description: "kg as string, or '-' for bodyweight" },
                rest_seconds: { type: "integer" },
              },
              required: ["name", "sets", "reps", "target_weight", "rest_seconds"],
            },
          },
        },
        required: ["title", "focus", "exercises"],
      },
    },
  },
  required: ["name", "days_per_week", "weeks", "days"],
};
async function doProgram(p: Record<string, unknown>) {
  const lib = Array.isArray(p.exercises) ? (p.exercises as string[]) : [];
  const system =
    "You are an expert strength & conditioning coach. Compose a practical, evidence-based training program for this athlete. " +
    "Honor their sport, experience level, days/week, equipment, goal, and ANY injuries (never include movements that aggravate them). " +
    "Prefer exercise names from the provided library so the app can show demos; a standard name is fine if needed. " +
    "Build EXACTLY days_per_week training days. Each day: title, focus, and 4-7 exercises with sets (int), reps (string like '5', '8-12', or '30 s'), " +
    "a starting target_weight (kg as a string, or '-' for bodyweight), and rest_seconds. A warm-up may be the first item. " +
    langLine(String(p.lang || "en"));
  const user = "Athlete:\n" + JSON.stringify(p.profile ?? {}, null, 2) +
    "\n\nExercise library (prefer these names):\n" + lib.slice(0, 180).join(", ") + "\n\nCompose the program.";
  const res = await callClaude(system, user, { maxTokens: 3500, schema: PROGRAM_SCHEMA });
  if (res.error) return res;
  try { return { data: JSON.parse(res.text || "{}") }; } catch { return { error: "Could not parse the AI response." }; }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);
  let p: Record<string, unknown>;
  try {
    p = await req.json();
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }
  const action = String(p.action || "");
  try {
    if (action === "summary") return json(await doSummary(p));
    if (action === "explain") return json(await doExplain(p));
    if (action === "onboard") return json(await doOnboard(p));
    if (action === "actions") return json(await doActions(p));
    if (action === "program") return json(await doProgram(p));
    return json({ error: "Unknown action: " + action }, 400);
  } catch (e) {
    return json({ error: (e as Error).message }, 500);
  }
});
