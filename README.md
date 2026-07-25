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

Working: the person list with search and surname grouping, the identity header,
generated life-story prose, the timeline, family relationships (distinguishing a
recorded marriage from an unmarried union), and sources with their records and
transcriptions. All of it renders from a bundle-shaped object, so the sample and
a real import take exactly the same path.

Import is now real: the "Import a tree…" button reads a `.familyweb` file,
unzips it in-page (a small hand-rolled zip reader — `DataView` + a built-in
`DecompressionStream("deflate-raw")`, no library), and stores the tree and its
images in IndexedDB, where they persist across visits. A stored tree always
takes priority over the sample fixture; a wrong-schema or corrupt file is
rejected with a plain-language message and the previous tree stays in place.
Re-importing is a full replace, matching the schema's "no incremental sync"
rule.

Not built yet: the service worker for true offline use, the web app manifest
and icons, and photo and document display (thumbnails are already stored in
IndexedDB on import; nothing renders them yet).

## Layout

- `index.html` — the whole viewer, self-contained: no build step, no dependencies,
  no external requests.
- `.githooks/` — the privacy guard.
