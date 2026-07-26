// Family Tree Viewer — service worker.
//
// Caches the app shell (this page + its manifest/icons) so the installed PWA
// still opens with no network. The real tree data lives in IndexedDB after
// import and is untouched by this file. Bump SW_VERSION whenever any shell
// file below changes, so returning visitors get the new version instead of
// being stuck on a stale cached shell forever.
const SW_VERSION = "v4";
const CACHE_NAME = `family-tree-shell-${SW_VERSION}`;
const SHELL_PATHS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./icon-192.png",
  "./icon-512.png",
  "./apple-touch-icon.png",
];
const SHELL_URLS = SHELL_PATHS.map((p) => new URL(p, self.location).href);

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(SHELL_URLS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((names) => Promise.all(
        names.filter((name) => name !== CACHE_NAME).map((name) => caches.delete(name))
      ))
      .then(() => self.clients.claim())
  );
});

// Cache-first for the app shell only. Everything else — the dev-only
// tree.json fetch, any request this file doesn't know about — passes
// straight through to the network untouched.
self.addEventListener("fetch", (event) => {
  const { request } = event;
  if (request.method !== "GET" || !SHELL_URLS.includes(request.url)) return;

  event.respondWith(
    caches.match(request).then((cached) => cached || fetch(request))
  );
});
