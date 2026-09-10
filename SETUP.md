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

---

## 11. Coaching organisations

Run `migrations/23_organisations.sql`. Everything here lives on the **coach
website** (`dashboard.html`), which is the coach's main control tool — the app's
coach portal is the pocket version.

> Migration 22 built corporate wellness — a company whose *employees* are the
> athletes, with HR reading aggregate participation. That was a misreading of the
> requirement and is dropped by migration 23. The members of an organisation are
> the **coaches**.

### The model
A gym, club or coaching business buys access. `organisations.seats` is the
licensed coach count, and `redeem_org_invite()` refuses the next coach once the
seats are full — that is what "buys access" actually enforces.

* **Roles** — `owner`, `admin`, `coach`. Admins invite and manage; a coach cannot
  promote themselves, and the last owner cannot demote themselves and strand the
  organisation with nobody able to administer it.
* **Teams** (`org_teams`) group coaches inside the organisation — a strength
  staff, a rehab team, an age group.
* **Invite codes** are `TEAM-XXXXX` and carry the role the joiner receives.

### Why this makes collaboration work
`are_peers()` now returns true for two coaches in the **same organisation**, as
well as for an accepted one-to-one connection. Every co-coaching and
group-sharing path from section 10 already routes through that one function, so
a coach who joins the gym can immediately be put on a client or a group with no
invitation exchanged. A coach outside the organisation is still refused.

`share_client_with_team()` puts an entire team on one client in a single action,
at full or read-only access, using the same insert path as a manual co-coach —
so the access rules are identical however the coach got there.

### On the website
The dashboard gains an **Organisation** panel (roster, teams, seats, invite
codes) and a **Colleagues** panel for connecting to a coach outside the
organisation. Every client now shows **Coaches on this client** with sharing to
either a colleague or a whole team.

---

## 12. Recovery day

A suggestion, never an imposition. The app watches the usual fatigue signals and
offers an easier session; the athlete accepts it or trains as planned. Nothing is
forced and nothing is silent.

**When it is offered** — any of: low readiness logged today · three or more days
trained in a row · the day after a match (MD+1) · a programme deload week ·
recent sets averaging RPE 8.5 or higher. The reasons are shown, not just the
verdict, so the athlete can judge whether the app has it right.

**What it changes when accepted**
* `recoveryFactor()` eases prescribed loads to 70%, applied in `getPrescription()`
  alongside the week phase, readiness, match week and coach adjustments.
* `recommendForNextSet()` stops progressing. This is the point of the feature: a
  recovery day that still adds 2.5 kg every set is not a recovery day, so the
  next set holds the same load and reps instead.

**Scope and escape hatches** — stored against a single date, so tomorrow starts
clean. Declining hides the offer for that day without switching anything on, and
an accepted recovery day can be switched back to the normal session at any time
from the same card.

### Removing coaches and clients

Migration 23 shipped an incomplete removal: ending a coach's membership only set
`status='left'`, so every client the gym had shared with them stayed in their
list — a coach could leave and keep coaching the gym's roster. Clients also had
no relationship to an organisation, so there was nothing to remove them from.
Migration 24 closes both.

**The rule: delegated access ends when the basis for the delegation ends.** A
`coach_clients` row with `source='cocoach'` exists because someone in the
organisation handed it over, so it is withdrawn when the coach leaves or the
client comes off the roster. A link the coach won themselves — their own invite
code, a client they added by email — is never touched, because the athlete
agreed to *that* relationship directly.

* `org_clients` is the gym's client roster. `share_client_with_team()` now adds
  to it automatically, since sharing a client with the gym's staff is what makes
  them a client of the gym.
* `org_remove_member(org, coach)` — admin only. Ends membership and withdraws
  that coach's delegated links to this organisation's clients. Delegated links
  to clients *outside* the roster (a private one-to-one share) survive.
* `org_remove_client(org, client)` — admin only. Withdraws every org coach's
  delegated link; the coach who brought them in keeps them.
* `org_leave(org)` — a coach leaving of their own accord clears exactly the same
  access, so walking out is not a way to keep the gym's clients.
* Both refuse to strip the last owner, and both return the number of links
  withdrawn so the UI can say what actually happened.

### Deleting a team (migration 26)
`org_delete_team(team)` and `org_rename_team(team, name)` are admin-only.
Deleting dissolves the staff group and its memberships (the `org_team_members`
foreign key cascades) and returns how many coaches were unassigned.

It deliberately does **not** touch `coach_clients`. A client shared through a
team was shared with those coaches, not with the team object, and a coach may
hold the same client through another team or their own invite code — so
deleting a team must not silently cut athletes off from their coach. Ending
client access stays with `org_remove_client` and `org_remove_member`, and the
confirmation dialog says so.

> Migration 26 also revokes the `anon` EXECUTE on `same_org(a, b)`. Unlike the
> other helpers it takes user ids as parameters rather than reading
> `auth.uid()`, so an anonymous caller could probe whether two ids work at the
> same gym. Checked first that no RLS policy references it — only `team_org` is,
> by `org_team_members_read`/`_write`, and that keeps its grant. See the warning
> in section 10 about what revoking a policy-referenced function does.

---

## 13. Cancelling and recalling

Four things could be created but never undone. Migration 25 and the surrounding
interface close all four.

| What | Where | Rule |
|---|---|---|
| A client request the person never accepted | Coach website, on the Pending row | `cancel_client_request()` only touches `status='pending'`, so a mis-click cannot sever a live coaching relationship — that is what the separate disconnect is for |
| A colleague invitation | Coach website **and** the app's coach portal | Only removes a `pending` row; an accepted connection is untouched |
| A client invite code | Coach website, under Live codes | The portal used to show only the newest code while older ones stayed redeemable. It now lists every live code, each revocable. Clients who already joined with a revoked code stay connected |
| A coach application that is not approved | Admin panel in the app | `admin_delete_coach_application()` removes the row and clears `coach_status`, so the person can apply again from scratch. It refuses on an approved coach — withdrawing coaching status is the review action's job, not a delete's |

The admin delete needs a function because admins deliberately hold only SELECT on
`coach_applications`. The other three were already permitted by RLS (both parties
can delete a `coach_clients` or `coach_peers` row, and a coach owns their own
invites), so they needed interface rather than schema.

---

## 14. Comments on a single exercise (migration 27)

A coach reading a session wants to say something about **one lift**, not the
workout as a whole. `coach_workout_notes` is the private per-session note; this
is the opposite — a message the athlete actually receives.

Rather than a second messaging table, `coach_messages` gained an optional
reference (`ref_type`, `ref_id`, `ref_label`). Threads stay one list, and a
message with no reference renders exactly as it always did. A second inbox
nobody checks would be worse than no feature.

* **Posting** — coach website, session detail: expand *Sets*, then the speech
  bubble beside any exercise. `coach_comment_exercise()` gates on
  `coach_can_edit()`, the same check used everywhere else, so a **read-only
  co-coach cannot post**. Empty bodies are refused.
* **Reading** — the exercise name appears as a small label above the message
  bubble, in both the coach website thread and the athlete's app.
* The athlete gets the normal `message` push notification.

---

## 15. Main coach and assistants in a group (migration 28)

`org_team_members` recorded only *that* a coach belongs to a group. A club needs
to say **who runs it**. The role lives on the join row, not on the coach, because
the same person can lead one group and assist in another.

* `role` is `lead` or `assistant`, defaulting to `assistant`.
* A partial unique index (`org_team_members_one_lead`) states "at most one lead
  per group" as a database fact rather than something the app must remember.
  `org_team_set_lead()` demotes the incumbent and promotes the new lead in a
  single UPDATE — verified safe, because Postgres checks a unique index at end
  of statement, so the swap never trips it.
* `org_team_clear_lead()` steps the lead down without removing them.
* `team_coaches()` gained `team_role` and orders the lead first;
  `org_team_list()` gained `lead_name`. Both **gain a column**, and
  `create or replace` cannot change a function's return type — they must be
  dropped and rebuilt, which drops their grants too, so the migration reissues
  them. Watch for this whenever an RPC's shape changes.

> **This is not an access grant.** `share_client_with_team()` gives every coach
> in the group the same access to a shared athlete. Who leads is responsibility
> and display order; tying access to it would silently change who can edit an
> athlete's program.
