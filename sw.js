// ÍslandFit service worker — offline app shell + installability.
// Strategy: never touch Supabase (always network); navigations are network-first
// (so the app always updates after a deploy); static CDN assets are cache-first.
const CACHE = 'islandfit-v1';
const SHELL = [
  './',
  './islandfit.html',
  'https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Inter:wght@400;500;600;700;800;900&display=swap',
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

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);
  // Bypass Supabase API/auth and any non-GET request — these must always hit the network.
  if (e.request.method !== 'GET' || url.hostname.endsWith('supabase.co')) return;

  // Navigations: network-first, fall back to the cached app shell when offline.
  if (e.request.mode === 'navigate') {
    e.respondWith(
      fetch(e.request)
        .then(r => { const copy = r.clone(); caches.open(CACHE).then(c => c.put('./islandfit.html', copy)); return r; })
        .catch(() => caches.match('./islandfit.html').then(r => r || caches.match('./')))
    );
    return;
  }

  // Static assets (fonts, CDN libs): cache-first, then network (and cache the result).
  e.respondWith(
    caches.match(e.request).then(cached =>
      cached || fetch(e.request).then(r => {
        if (r && r.ok) { const copy = r.clone(); caches.open(CACHE).then(c => c.put(e.request, copy)); }
        return r;
      })
    )
  );
});
