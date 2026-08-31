// ÍslandFit service worker — offline app shell + installability.
// Strategy: never touch Supabase (always network); navigations are network-first
// (so the app always updates after a deploy); static CDN assets are cache-first.
const CACHE = 'islandfit-v29';
const SHELL = [
  './',
  './index.html',
  './islandfit.html',
  './coaches.html',
  './dashboard.html',
  './privacy.html',
  './terms.html',
  './icon-192.png',
  './icon-512.png',
  './icon-badge.png',
  'https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Inter:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600;700&display=swap',
  'https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2',
  'https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(SHELL).catch(() => {})).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

// ── PUSH NOTIFICATIONS ──
// The payload is written by the push edge function: {title, body, url, tag}.
self.addEventListener('push', e => {
  let d = {};
  try { d = e.data ? e.data.json() : {}; } catch (_) { d = { body: e.data && e.data.text() }; }
  const title = d.title || 'ÍslandFit';
  e.waitUntil(self.registration.showNotification(title, {
    body: d.body || '',
    tag: d.tag || 'islandfit',
    renotify: true,
    badge: './icon-badge.png',
    icon: './icon-192.png',
    data: { url: d.url || './islandfit.html' },
    vibrate: [60, 30, 60]
  }));
});

// Focus an already-open tab when possible instead of opening a duplicate.
self.addEventListener('notificationclick', e => {
  e.notification.close();
  const target = (e.notification.data && e.notification.data.url) || './islandfit.html';
  e.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
      const wanted = new URL(target, self.location.origin);
      for (const c of list) {
        if (new URL(c.url).pathname === wanted.pathname && 'focus' in c) {
          if ('navigate' in c && c.url !== wanted.href) c.navigate(wanted.href);
          return c.focus();
        }
      }
      return self.clients.openWindow(wanted.href);
    })
  );
});

// A subscription can be rotated by the browser; tell any open tab to re-save it.
self.addEventListener('pushsubscriptionchange', e => {
  e.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then(list => list.forEach(c => c.postMessage({ type: 'push-resubscribe' })))
  );
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET' || url.hostname.endsWith('supabase.co')) return;

  if (e.request.mode === 'navigate') {
    e.respondWith(
      fetch(e.request)
        .then(r => { const copy = r.clone(); caches.open(CACHE).then(c => c.put(e.request, copy)); return r; })
        .catch(() => caches.match(e.request).then(r =>
          r || caches.match('./islandfit.html').then(a => a || caches.match('./')))
        )
    );
    return;
  }

  e.respondWith(
    caches.match(e.request).then(cached =>
      cached || fetch(e.request).then(r => {
        if (r && r.ok) { const copy = r.clone(); caches.open(CACHE).then(c => c.put(e.request, copy)); }
        return r;
      })
    )
  );
});
