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

## 6. Push-tilkynningar

Appið sendir tilkynningar þegar þjálfari/skjólstæðingur sendir skilaboð, þegar prógrami er úthlutað, þegar tæknimyndband berst eða er svarað, og við vikulegt check-in.

**Þetta er þegar uppsett** — VAPID-lyklar voru búnir til og settir í `app_secrets`-töfluna, og edge function-ið `push` er komið í loftið. Ekkert þarf að gera nema notandinn kveiki á þeim í appinu.

**Hvernig það virkar:**
- Notandi fer í **Stillingar → Tilkynningar → Kveikja** og samþykkir í vafranum. Áskriftin (endapunktur + lyklar) vistast í `push_subscriptions`.
- Þegar aðgerð á sér stað kallar appið á `push` edge function-ið. Það **staðfestir tengslin** í gagnagrunninum (aðeins virkur þjálfari↔skjólstæðingur eða sami hópur), semur textann **server-megin** og sendir dulkóðaða tilkynningu.
- Service worker-inn (`sw.js`) tekur við henni og birtir hana; smellur opnar réttan skjá.

**Öryggi:**
- Einkalykillinn (VAPID) er í `app_secrets` sem hefur RLS kveikt **án nokkurra reglna** — aðeins `service_role` (edge function-ið) kemst í hann. Hann fer aldrei í vafrann; þar er bara opinberi lykillinn.
- Enginn getur sent tilkynningu á notanda sem hann er ekki tengdur. Textinn í skilaboða-tilkynningum er sóttur úr gagnagrunninum, ekki treyst frá kallandanum.
- Áskriftir sem push-þjónustan hafnar (404/410) eru sjálfvirkt hreinsaðar út.

**Stillingar notanda:** hver notandi getur slökkt á tveimur flokkum sérstaklega (`notify_messages`, `notify_coach_activity` í `profiles`).

**Ef lyklarnir þurfa að endurnýjast** (t.d. ef þeir leka): búðu til nýtt P-256 par, uppfærðu bæði `app_secrets` og `VAPID_PUBLIC_KEY` í `islandfit.html` — og athugaðu að **allar núverandi áskriftir verða ógildar**, notendur þurfa að kveikja aftur.

**iPhone:** Safari styður push aðeins þegar appið hefur verið **bætt á heimaskjáinn** (Deila → Bæta á heimaskjá). Í vafranum sjálfum birtist enginn kveikja-hnappur.

## 7. Myndbönd í báðar áttir (form checks)

Form-check kerfið er tvíhliða myndbandssamtal milli þjálfara og skjólstæðings:

- **Skjólstæðingur** hleður upp lyftu-myndbandi (Stillingar → þjálfari → Form check).
- **Þjálfari** svarar með texta, **myndbandi**, eða hvoru tveggja — og getur líka **byrjað** samtal og sent myndband að fyrra bragði (t.d. tækni-demo).
- Báðir sjá bæði myndböndin í sama þræði.

**Geymsla og aðgangur:** öll myndbönd fara í lokaða `form-checks` geymslu undir möppu **skjólstæðingsins** (`<client_id>/…`), líka svör þjálfarans. Þannig gildir sama aðgangsregla fyrir bæði: eigandi möppunnar, eða þjálfari með **virka** tengingu. Aftengist þjálfari missir hann aðganginn strax. Spilun notar tímabundna undirritaða hlekki (1 klst.).

**Vörn gegn breytingum:** trigger (`form_checks_guard`) tryggir að skjólstæðingur geti aðeins breytt sínum eigin reitum og þjálfari sínum — hvorugur getur breytt eða falsað efni hins.

**Stærðarmörk:** 100 MB á myndband (viðmótið hafnar stærri skrám með skýrum skilaboðum). Athugið að Supabase free-tier gefur 1 GB geymslu — myndbönd fylla hana fljótt, sem er ein af ástæðunum fyrir að fara á Pro fyrir alvöru rekstur.

## 8. Fasar sem breyta prógraminu

Þjálfari getur skipt prógrami í fasa (blokkir) þar sem **æfingarnar sjálfar breytast** milli fasa, og stillt hversu margar vikur hver fasi varir.

**Í prógram-smiðnum (mælaborðinu):**
1. Bættu við fösum efst — flýtihnappar fyrir Volume / Intensity / Peak / Deload, eða frjáls blokk. Stilltu vikufjölda á hverjum.
2. Dagarnir fyrir neðan raðast sjálfkrafa undir fasana. Hver fasi fær sinn „Day"-hnapp.
3. **„Every phase"** hópurinn er fyrir daga sem eiga að endurtakast í öllum fösum (t.d. fast þolpúl). Þeir bætast aftan við daga hvers fasa.
4. Færðu dag milli fasa með fellilistanum á dagakortinu.

Heildarvikur prógramsins reiknast sjálfkrafa út frá fösunum.

**Hvað skjólstæðingurinn upplifir:** appið reiknar hvaða fasa vikan hans fellur í og sækir æfingar þess fasa. Þegar hann fer úr viku 4 í viku 5 og nýr fasi tekur við breytist æfingaplanið sjálfkrafa. Tímalínan á heimaskjánum sýnir hvar hann er staddur.

**Athugið:**
- Fasar eru byggðir í **mælaborðinu** (dashboard.html), ekki í þjálfaragáttinni í símanum.
- Prógröm án fasa virka óbreytt — dagar án fasa gilda alltaf.
- Dagafjöldi má vera mismunandi eftir fösum; vikan rúllar á fjölda daga í virkum fasa.
- Sé íþróttamaður kominn fram úr síðasta fasa heldur hann áfram í honum.

---

## 9. In-season match calendar (leikjaplan)

Lets an athlete (or their coach) enter the fixture list so training load is
planned around matches instead of running blind through a season.

### Database
Run `migrations/19_fixtures.sql`. It creates the `fixtures` table with RLS:
the athlete owns their calendar, and a coach can read **and write** it only
while `coach_clients.status = 'active'` — disconnect and the access is gone.
A trigger makes `client_id` and `created_by` immutable, so a fixture can never
be moved onto someone else's calendar.

### How the load adapts
Standard MD-coding from team-sport S&C, applied as one more multiplier inside
`getPrescription()` alongside the existing week phase, experience level and
readiness factors:

| Day | Code | Load |
|---|---|---|
| Day of the match | MD | 0.50 + "skip the gym" flag |
| Day before | MD-1 | 0.55 (0.50 for a key match, 0.70 for a minor one) |
| Two days before | MD-2 | 0.85 (0.75 for a key match) |
| Day after | MD+1 | 0.60 |
| Two days after | MD+2 | 0.90 |
| Anything else | open | 1.00 |

Two matches within seven days of each other caps the week at 0.85 regardless.
The window looks **backward as well as forward** — standing between Saturday's
match and Wednesday's is the fatiguing case.

The athlete can turn the whole thing off in **Settings → Match calendar**;
their fixtures stay listed but loads are left alone.

### AI load analysis
`Analyse my load around these matches` calls the `loadplan` action on the `ai`
edge function. It is told the automatic per-match taper is already handled, so
it comments only on what that rule cannot see — multi-week pile-ups, a key match
landing on a heavy block, or a fixture-free gap worth training *harder* through.
Its recommendations apply through the same mechanism as the existing coach
actions, so there is nothing new for the athlete to learn.

Redeploy the `ai` function after pulling this change, or the button returns
"Unknown action: loadplan".

---

## 10. Coaches working together

Run `migrations/20_coach_collaboration.sql`.

### Colleague connections
A coach connects with another coach by email (**Coach Portal → Colleagues**).
Both sides consent: the invitee sees the request and accepts or declines. Only
approved coaches can send or resolve an invitation, and the lookup returns just
a user id — it cannot be used to enumerate athletes.

### Sharing a client
On a client, **Coaches on this client** shares them with a connected colleague
at one of two levels:

* **Full** — an equal coach: programs, phases, fixtures, nutrition targets,
  form-check feedback.
* **Read-only** — sees everything, changes nothing. Still able to message the
  athlete, since a physio or head coach who cannot reply is useless.

This reuses `coach_clients`, which was already `UNIQUE(coach_id, client_id)`, so
every existing "active coach of this client" read policy started working for the
second coach with no rewrite. The read-only restriction is enforced by RLS on
the write paths (`coach_can_edit()`), not by hiding buttons.

Per the product decision, the athlete is **not** asked to approve a co-coach.
They instead get **Settings → Who can see my data**, listing every coach with
access and at what level.

### Sharing a group
In the dashboard's group modal, **Coaches on this group** works the same way.
Only the group owner manages staff. Sharing widens `is_group_coach()`, the
single gate the group policies already route through, so members and chat follow
automatically; `is_group_editor()` is the separate write gate.

A coach who has a group shared with them does not coach those athletes
individually, so the dashboard resolves roster and chat names through
`group_people()` rather than from their own client list. Read-only staff have
the member-removal, add-member and bulk-assign controls hidden as well as
blocked, so the UI matches what the database will actually allow.

### Two traps this hit, worth remembering
1. `coach_groups` and `coach_group_staff` policies that query each other cause
   `infinite recursion detected in policy`. Both sides must go through a
   SECURITY DEFINER helper, which bypasses RLS.
2. A `FOR ALL` policy checks only `USING` on DELETE. A single policy with
   `using(is_group_coach)` + `with check(is_group_editor)` let a read-only coach
   delete group members. The member policies are split per command for this reason.
