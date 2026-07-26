# Family Tree Viewer

A read-only, offline web viewer for a personal family tree, built to be used on an
iPad. It is fed by a bundle exported from a separate macOS app; **this repository
and the site published from it contain the viewer only — never any family data.**

## The rule this repo exists to keep

The site starts up **empty**. Tree content reaches it in exactly one way: the
owner exports a `.familyweb` bundle from the Mac app, AirDrops it to their iPad,
and imports it into the viewer, where it lives in that device's local storage.
Nothing is uploaded, and there is no server involved.

So nothing here — no fixture, no screenshot, no commit message — may contain a
real name, date, place, source or photograph. **The sample data is entirely
fictional**, invented for this demo.

A privacy guard enforces that mechanically rather than by memory. See
[`.githooks/README.md`](.githooks/README.md). Enable it once per clone:

```sh
git config core.hooksPath .githooks
```

It blocks tree content from diffs *and* commit messages at commit time, and
re-checks every commit in the range at push time.

## Status

The originally-scoped feature set is complete. Working: the person list with
search and surname grouping, the identity header (with a profile photo when
one's set, falling back to initials), generated life-story prose, the
timeline, family relationships (distinguishing a recorded marriage from an
unmarried union), sources with their records and transcriptions, a "Photos &
Documents" gallery with a lightbox for every attached photo/PDF, and an
interactive **Family Explorer** — an hourglass tree centred on a focus person,
ancestors above and descendants below, that you expand and collapse by
tapping. All of it renders from a bundle-shaped object, so the sample and a
real import take exactly the same path.

Import: the "Import a tree…" button reads a `.familyweb`/`.zip` file, unzips
it in-page (a small hand-rolled zip reader — `DataView` walking the archive's
directory table, no library), and stores the tree and its images in IndexedDB,
where they persist across visits. Decompression prefers the native
`DecompressionStream("deflate-raw")` but falls back to a hand-rolled pure-JS
RFC 1951 decoder on browsers that lack it entirely (iPadOS 15 and earlier —
confirmed on a real device), so an older iPad isn't locked out. A stored tree
always takes priority over the sample fixture; a wrong-schema or corrupt file
is rejected with a plain-language message and the previous tree stays in
place. Re-importing is a full replace, matching the schema's "no incremental
sync" rule.

Installable and offline-capable: a web app manifest + icon set, and a service
worker that caches the app shell so it opens with no network once visited.

Nothing is currently queued.

## Layout

- `index.html` — the whole viewer, self-contained: no build step, no dependencies,
  no external requests.
- `sw.js` — the service worker (app-shell offline caching).
- `manifest.webmanifest`, `icon-192.png`, `icon-512.png`, `apple-touch-icon.png` —
  installability.
- `.githooks/` — the privacy guard.
