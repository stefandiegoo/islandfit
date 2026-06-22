# ÍslandFit — uppsetning

## Skrár
- **`islandfit.html`** — appið (núgildandi útgáfa, v5: enska + onboarding + 18 íþróttagreinar). Opnaðu í vafra.
- `islandfit_pre_v5_backup.html` — eldri íslenska útgáfan (afrit, má eyða þegar þú ert ánægð/ur).
- `migrations/` — gagnagrunns-migrations í réttri keyrsluröð (númeraðar).

## 1. Keyra SQL í Supabase (í þessari röð)
Opnaðu **Supabase → SQL Editor** og keyrðu skrárnar úr `migrations/` í númeraröð. Grunnurinn (`00_supabase_setup.sql`) er **þegar keyrður** — slepptu honum (hann notar `create table` án `if not exists` og gefur villu ef endurkeyrt).

| Röð | Skrá í `migrations/` | Gerir |
|----|------|-------|
| ~~00~~ | ~~`00_supabase_setup.sql`~~ | ~~grunntöflur~~ (þegar gert) |
| 01 | `01_migration_v2.sql` | + `workout_sets.rpe` |
| 02 | `02_programs_migration.sql` | býr til `programs`, `program_workouts`, `program_exercises` + profiles-dálka |
| 03 | `03_migration_v3_english.sql` | enska + `units`/`language`, endurstillir prógram-gögn |
| 04 | `04_migration_v4.sql` | onboarding-dálkar (position, goal, equipment, o.fl.) |
| 05 | `05_migration_v5_iceland_sports.sql` | seed: 18 íþróttagreinar |
| 06 | `06_migration_v6_general_athletic.sql` | "Athletic Performance" (General) — 4 jafnvægis-dagar (styrkur · sprengikraftur · hraði · úthald) |
| 07 | `07_migration_v7_sport_programs_batch1.sql` | Djúp íþrótta-prógrömm (advanced): handbolti · körfubolti · fótbolti · powerlifting · hlaup · MMA |
| 08 | `08_migration_v8_sport_programs_batch2.sql` | Athletics · Swimming · Golf · Volleyball · Tennis (advanced) |
| 09 | `09_migration_v9_sport_programs_batch3.sql` | CrossFit · Cycling · Ice Hockey · Gymnastics · Rock Climbing (advanced) |
| 10 | `10_migration_v10_sport_programs_batch4.sql` | Equestrian · Strongman · Glíma · Badminton · Winter Sports (advanced) |
| 11 | `11_fix_crossfit_casing.sql` | lagar `Crossfit`→`CrossFit` (forðast tvöfalda onboarding-flís) — idempotent |
| 12 | `12_supersets.sql` | + `program_exercises.superset_group` + demo-supersett í General-prógramminu (dagar 1 & 4) — idempotent |
| 13 | `13_nsca_strength_foundations.sql` | "Strength Foundations" (General, NSCA-principles línuleg periodization, 4 dagar) — varið/idempotent |
| 14 | `14_general_programs.sql` | 5 almenn prógrömm: Push Pull Legs · Full Body Starter · Dumbbell Only Home · Bodyweight · Powerbuilding — varið/idempotent |
| 15 | `15_fix_encoding.sql` | **Encoding-viðgerð** — lagar `‚Äî`/`¬∑`/`¬∞`/`√≠` mojibake (sjá ⚠️ að neðan). 100% ASCII (U&escapes), idempotent, óhætt að endurkeyra |

> ⚠️ **Encoding-gildra:** þegar SQL með íslenskum stöfum eða `·`/`—`/`°` er **límt inn í Supabase SQL Editor spillast þeir** (UTF-8 lesið sem MacRoman → t.d. `Glíma`→`Gl√≠ma`, `—`→`‚Äî`). Þetta er Supabase-megin, ekki í skránum (þær eru hreinar). **Keyrðu `15_fix_encoding.sql` eftir hverja migration sem inniheldur slíka stafi** til að hreinsa. (15 er 100% ASCII svo hún spillist ekki sjálf.)

> ⚠️ **Keyrðu 01→11 EINU SINNI, í réttri röð.** `02` og `03` byrja á `delete from programs` (þurrka ÖLL prógram-gögn) og `05` setur inn án varnar — svo **ef þú endurkeyrir 02/03/05 eftir á tapast eða tvöfaldast gögnin** (þ.m.t. v6–v11). `06`–`14` eru varðar (guards / idempotent) og óhætt að endurkeyra hvenær sem er.

## 2. Email-staðfesting
Verkefnið krefst email-staðfestingar. Appið ræður núna við hvort tveggja:
- **Til prófunar (mælt með):** Supabase → Authentication → Sign In / Providers → Email → afhakaðu **"Confirm email"**. Þá skráir nýskráning þig strax inn.
- **Annars:** nýskráning sýnir "📩 Confirmation email sent" — staðfestu í tölvupósti, svo skráðu þig inn.

## 3. Keyra lókalt
```
python3 -m http.server 4173 --directory "$(pwd)"
```
Opnaðu http://127.0.0.1:4173/islandfit.html

## 4. Hýsing (deploy) & PWA
Appið er ein static skrá → hýstu á **HTTPS** (þarf fyrir service worker, "install", og Supabase email-redirects).

**Auðveldast:** [Netlify Drop](https://app.netlify.com/drop) — dragðu möppuna (`islandfit.html` + `sw.js` + `manifest`/icon eru í hausnum) beint inn. Aðrir: Vercel, Cloudflare Pages, GitHub Pages.

**Eftir hýsingu — mikilvægt:** Supabase → Authentication → **URL Configuration** → settu hýsingar-slóðina sem **Site URL** + bættu við **Redirect URLs** (annars virkar staðfestingar-/innskráningar-redirect ekki í alvöru léni).

**PWA staða:** `manifest` + íkon + apple-meta eru þegar í `<head>`. `sw.js` bætir við **offline + "Add to Home Screen"**. Service worker skráist **bara á HTTPS** (ekki í `http://127.0.0.1` dev → engin stale-cache vandræði meðan þú debuggar). Navigations eru network-first svo appið uppfærist alltaf eftir deploy; Supabase-köll fara alltaf á netið.

**(Valkvætt) Android install-borði:** Chrome vill helst PNG-íkon (192px + 512px). Núverandi manifest notar SVG (virkar á iOS/flestum). Til að fá full Android install-prompt: flyttu út 192/512 PNG og skiptu data-URI manifestinu út fyrir `manifest.webmanifest` skrá sem vísar í þau.

## 5. AI-eiginleikar (valkvætt en mælt með)
Appið er með þrjá AI-eiginleika: **vikulega þjálfara-samantekt** (Progress), **"Ask your coach"-spjall**, og **AI-onboarding** ("describe yourself"). Þeir kalla á Claude í gegnum **Supabase Edge Function** (`supabase/functions/ai/index.ts`) — API-lykillinn er geymdur **server-megin** (aldrei í HTML-inu, sem er opinbert).

**Skref:**
1. **Náðu í Anthropic API-lykil** á [console.anthropic.com](https://console.anthropic.com) → Billing → settu inn smá inneign → API Keys → Create (`sk-ant-...`).
2. **Deploya edge function-ið** (tvær leiðir):
   - **Dashboard (engin CLI):** Supabase → **Edge Functions** → *Deploy a new function* → nefndu hana **`ai`** → límdu innihald `supabase/functions/ai/index.ts` → Deploy.
   - **CLI:** `supabase functions deploy ai`
3. **Settu leyndarmálið (secret):**
   - **Dashboard:** Supabase → Project Settings → **Edge Functions → Secrets** → bættu við `ANTHROPIC_API_KEY = sk-ant-...`
   - **CLI:** `supabase secrets set ANTHROPIC_API_KEY=sk-ant-...`

Þá virka eiginleikarnir strax (⌘R). Þangað til sýna þeir vingjarnleg "AI not set up yet" skilaboð — appið virkar áfram án þeirra.

**Kostnaður / model:** efst í `index.ts` er `const MODEL`. Sjálfgefið `claude-opus-4-8` (besta gæði, dýrast). Fyrir ókeypis app með mörgum notendum: skiptu í `claude-sonnet-4-6` (~2× ódýrara) eða `claude-haiku-4-5` (~5× ódýrara) — sömu prompt virka á öllum. Köllin eru fá og stutt (samantekt einu sinni á viku per notanda, cache-uð í `localStorage`).

**Öryggi:** lykillinn er aldrei í HTML/appinu — bara sem Supabase secret. Edge function-ið er JWT-varið (bara innskráðir notendur ná í það). Engin AI-svör eru geymd nema vikusamantektin (í `localStorage` notandans).
