// ÍslandFit push sender.
// Implements VAPID (RFC 8292) + aes128gcm payload encryption (RFC 8291/8188)
// directly on Web Crypto so there is no third-party dependency to break.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const enc = new TextEncoder();

// ── base64url helpers ──
function b64uToBytes(s: string): Uint8Array {
  const pad = s.replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(pad + '='.repeat((4 - (pad.length % 4)) % 4));
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}
function bytesToB64u(b: Uint8Array): string {
  let s = '';
  for (const x of b) s += String.fromCharCode(x);
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}
function concat(...arrs: Uint8Array[]): Uint8Array {
  const len = arrs.reduce((n, a) => n + a.length, 0);
  const out = new Uint8Array(len);
  let o = 0;
  for (const a of arrs) { out.set(a, o); o += a.length; }
  return out;
}

// ── HKDF pieces (single-block expand is all Web Push needs) ──
async function hmac(key: Uint8Array, data: Uint8Array): Promise<Uint8Array> {
  const k = await crypto.subtle.importKey('raw', key, { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  return new Uint8Array(await crypto.subtle.sign('HMAC', k, data));
}
async function hkdf(salt: Uint8Array, ikm: Uint8Array, info: Uint8Array, len: number): Promise<Uint8Array> {
  const prk = await hmac(salt, ikm);
  const okm = await hmac(prk, concat(info, new Uint8Array([1])));
  return okm.slice(0, len);
}

// ── VAPID JWT (ES256) ──
async function vapidHeader(endpoint: string, pubB64u: string, privB64u: string, subject: string) {
  const aud = new URL(endpoint).origin;
  const header = bytesToB64u(enc.encode(JSON.stringify({ typ: 'JWT', alg: 'ES256' })));
  const payload = bytesToB64u(enc.encode(JSON.stringify({
    aud, exp: Math.floor(Date.now() / 1000) + 12 * 3600, sub: subject,
  })));
  const unsigned = `${header}.${payload}`;

  const pub = b64uToBytes(pubB64u); // 0x04 || x(32) || y(32)
  const jwk = {
    kty: 'EC', crv: 'P-256', ext: true,
    x: bytesToB64u(pub.slice(1, 33)),
    y: bytesToB64u(pub.slice(33, 65)),
    d: privB64u,
  };
  const key = await crypto.subtle.importKey('jwk', jwk, { name: 'ECDSA', namedCurve: 'P-256' }, false, ['sign']);
  const sig = new Uint8Array(await crypto.subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, key, enc.encode(unsigned)));
  return { authorization: `vapid t=${unsigned}.${bytesToB64u(sig)}, k=${pubB64u}` };
}

// ── aes128gcm body ──
async function encryptPayload(plaintext: string, uaPubB64u: string, authB64u: string): Promise<Uint8Array> {
  const uaPub = b64uToBytes(uaPubB64u);
  const authSecret = b64uToBytes(authB64u);

  const eph = await crypto.subtle.generateKey({ name: 'ECDH', namedCurve: 'P-256' }, true, ['deriveBits']);
  const asPub = new Uint8Array(await crypto.subtle.exportKey('raw', eph.publicKey));
  const uaKey = await crypto.subtle.importKey('raw', uaPub, { name: 'ECDH', namedCurve: 'P-256' }, false, []);
  const shared = new Uint8Array(await crypto.subtle.deriveBits({ name: 'ECDH', public: uaKey }, eph.privateKey, 256));

  // IKM = HKDF(auth_secret, ecdh_secret, "WebPush: info" || 0 || ua_pub || as_pub, 32)
  const keyInfo = concat(enc.encode('WebPush: info'), new Uint8Array([0]), uaPub, asPub);
  const ikm = await hkdf(authSecret, shared, keyInfo, 32);

  const salt = crypto.getRandomValues(new Uint8Array(16));
  const cek = await hkdf(salt, ikm, concat(enc.encode('Content-Encoding: aes128gcm'), new Uint8Array([0])), 16);
  const nonce = await hkdf(salt, ikm, concat(enc.encode('Content-Encoding: nonce'), new Uint8Array([0])), 12);

  const aesKey = await crypto.subtle.importKey('raw', cek, 'AES-GCM', false, ['encrypt']);
  const body = concat(enc.encode(plaintext), new Uint8Array([2])); // 0x02 = last record delimiter
  const ct = new Uint8Array(await crypto.subtle.encrypt({ name: 'AES-GCM', iv: nonce, tagLength: 128 }, aesKey, body));

  const rs = new Uint8Array(4);
  new DataView(rs.buffer).setUint32(0, 4096);
  return concat(salt, rs, new Uint8Array([asPub.length]), asPub, ct);
}

// ── notification copy, generated server-side (never trusted from the client) ──
function copyFor(type: string, senderName: string, preview: string | null) {
  const who = senderName || 'Þjálfarinn þinn';
  switch (type) {
    case 'message':      return { title: who, body: preview || 'Sendi þér skilaboð', url: 'islandfit.html#messages' };
    case 'group_message':return { title: `${who} · hópur`, body: preview || 'Ný skilaboð í hópnum', url: 'islandfit.html#groups' };
    case 'form_check':   return { title: 'Nýtt tæknimyndband', body: `${who} sendi myndband til yfirferðar`, url: 'dashboard.html' };
    case 'form_review':  return { title: 'Tæknisvar komið', body: `${who} fór yfir myndbandið þitt`, url: 'islandfit.html' };
    case 'checkin':      return { title: 'Vikulegt check-in', body: `${who} skilaði check-in`, url: 'dashboard.html' };
    case 'program':      return { title: 'Nýtt prógram', body: `${who} úthlutaði þér nýju prógrami`, url: 'islandfit.html' };
    default:             return null;
  }
}
// which preference gates which type
const PREF: Record<string, 'notify_messages' | 'notify_coach_activity'> = {
  message: 'notify_messages', group_message: 'notify_messages',
  form_check: 'notify_coach_activity', form_review: 'notify_coach_activity',
  checkin: 'notify_coach_activity', program: 'notify_coach_activity',
};

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
const json = (b: unknown, status = 200) =>
  new Response(JSON.stringify(b), { status, headers: { ...CORS, 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  try {
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { auth: { persistSession: false } },
    );

    // caller identity
    const token = (req.headers.get('Authorization') || '').replace('Bearer ', '');
    const { data: { user }, error: authErr } = await admin.auth.getUser(token);
    if (authErr || !user) return json({ error: 'unauthorized' }, 401);
    const me = user.id;

    const { to, type, group_id } = await req.json();
    if (!type || !copyFor(type, '', null)) return json({ error: 'bad type' }, 400);

    // ── work out the allowed recipient list ──
    let recipients: string[] = [];
    if (type === 'group_message') {
      if (!group_id) return json({ error: 'group_id required' }, 400);
      const { data: grp } = await admin.from('coach_groups').select('coach_id').eq('id', group_id).maybeSingle();
      const { data: mem } = await admin.from('group_members').select('client_id').eq('group_id', group_id);
      const all = [grp?.coach_id, ...(mem || []).map((m: any) => m.client_id)].filter(Boolean) as string[];
      if (!all.includes(me)) return json({ error: 'forbidden' }, 403);
      recipients = all.filter((id) => id !== me);
    } else {
      if (!to) return json({ error: 'to required' }, 400);
      // caller and target must share an active coach link, in either direction
      const { data: link } = await admin
        .from('coach_clients')
        .select('coach_id')
        .eq('status', 'active')
        .or(`and(coach_id.eq.${me},client_id.eq.${to}),and(coach_id.eq.${to},client_id.eq.${me})`)
        .maybeSingle();
      if (!link) return json({ error: 'forbidden' }, 403);
      recipients = [to];
    }
    if (!recipients.length) return json({ sent: 0 });

    // sender display name
    const { data: meProfile } = await admin.from('profiles').select('name').eq('id', me).maybeSingle();
    const senderName = meProfile?.name || 'ÍslandFit';

    // message preview comes from the stored row, never from the request body
    let preview: string | null = null;
    if (type === 'message') {
      const { data: msg } = await admin.from('coach_messages')
        .select('body').eq('sender_id', me).order('created_at', { ascending: false }).limit(1).maybeSingle();
      preview = msg?.body ? String(msg.body).slice(0, 120) : null;
    } else if (type === 'group_message') {
      const { data: msg } = await admin.from('group_messages')
        .select('body').eq('group_id', group_id).eq('sender_id', me)
        .order('created_at', { ascending: false }).limit(1).maybeSingle();
      preview = msg?.body ? String(msg.body).slice(0, 120) : null;
    }

    const copy = copyFor(type, senderName, preview)!;
    const prefCol = PREF[type];

    // drop recipients who turned this category off
    const { data: prefs } = await admin.from('profiles').select(`id, ${prefCol}`).in('id', recipients);
    const allowed = recipients.filter((id) => {
      const p: any = (prefs || []).find((x: any) => x.id === id);
      return !p || p[prefCol] !== false;
    });
    if (!allowed.length) return json({ sent: 0 });

    const { data: subs } = await admin.from('push_subscriptions').select('*').in('user_id', allowed);
    if (!subs?.length) return json({ sent: 0 });

    const { data: secretRows } = await admin.from('app_secrets').select('key,value')
      .in('key', ['vapid_private_key', 'vapid_public_key', 'vapid_subject']);
    const secrets = Object.fromEntries((secretRows || []).map((r: any) => [r.key, r.value]));
    const payload = JSON.stringify({ ...copy, tag: type });

    let sent = 0;
    const stale: string[] = [];
    await Promise.all(subs.map(async (s: any) => {
      try {
        const [body, vapid] = await Promise.all([
          encryptPayload(payload, s.p256dh, s.auth),
          vapidHeader(s.endpoint, secrets.vapid_public_key, secrets.vapid_private_key, secrets.vapid_subject),
        ]);
        const res = await fetch(s.endpoint, {
          method: 'POST',
          headers: {
            'Content-Encoding': 'aes128gcm',
            'Content-Type': 'application/octet-stream',
            'TTL': '86400',
            'Authorization': vapid.authorization,
          },
          body,
        });
        if (res.status === 404 || res.status === 410) stale.push(s.endpoint);
        else if (res.ok) sent++;
      } catch (_e) { /* one bad endpoint must not fail the batch */ }
    }));

    if (stale.length) await admin.from('push_subscriptions').delete().in('endpoint', stale);
    if (sent) {
      await admin.from('push_subscriptions')
        .update({ last_success_at: new Date().toISOString() })
        .in('user_id', allowed);
    }
    return json({ sent, pruned: stale.length });
  } catch (e) {
    return json({ error: String((e as Error).message || e) }, 500);
  }
});
