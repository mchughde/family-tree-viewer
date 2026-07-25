# Privacy guard — keeping tree content out of the repo

`pwa-viewer/NOTES.md` (THE RULE) says the repository, and the GitHub Pages site
built from it, carry the viewer **shell** only: no `tree.json`, no bundle, no
thumbnails, and **no real name, date, place, source or transcription anywhere —
including fixtures, screenshots and commit messages.**

`.gitignore` only covers whole files. It does nothing about a real name pasted
into a design note, and nothing at all about a commit message. Both have already
nearly happened here: real source names and a person id went into
`SCHEMA-v1.md`, and a real first name into a commit body. Both were caught by
someone choosing to look, which is not a safeguard.

These hooks make it mechanical.

## Setup (once per clone)

```sh
git config core.hooksPath .githooks          # hooks live in the repo, so they're versioned
swift run FamilyHistory --privacy-names      # build the denylist (written OUTSIDE the repo)
```

Re-run `--privacy-names` after adding people or places to the tree. It reads a
read-only copy of the live store and writes to
`~/Library/Application Support/FamilyHistory/privacy-guard-terms.txt`. That file
**is** tree content, so it lives outside any working tree and the exporter
refuses to write it anywhere else.

## What runs when

| Hook | Checks | On failure |
|---|---|---|
| `pre-commit` | staged file paths, staged added lines | blocks the commit; warns (doesn't block) if no denylist |
| `commit-msg` | the commit message | blocks the commit, message preserved in `.git/COMMIT_EDITMSG` |
| `pre-push` | every commit in the pushed range — messages, diffs and paths | blocks the push; **fails closed** with no denylist |

`pre-push` is the one that matters. A bad local commit can be amended; a push to
GitHub cannot be taken back, and history is published in full — a leak twenty
commits back is exactly as public as one in the tip.

Two independent gates run each time:

1. **Structural** — paths that are tree content whatever they hold:
   `tree.json`, `*.familyweb`, `img/`, `*.ged`, `*.sqlite`, the denylist itself.
   This catches `git add -f`, which `.gitignore` does not.
2. **Terms** — real names, places, occupations, source titles and attachment
   filenames, matched whole-word and case-insensitively.

## Escape hatches

`git commit --no-verify` and `git push --no-verify` skip the hooks. They exist
for genuine false positives; if you find yourself reaching for them twice, add
the offending word to `allow.txt` instead and note why.

## What this does NOT protect against

Worth being straight about, because a guard you over-trust is worse than none:

- **Prose that names nobody.** "She moved to the coast after her husband died" is
  private and contains no denylisted term.
- **New people.** Someone added to the tree after the last `--privacy-names` run
  isn't in the list yet.
- **Screenshots.** An image of the app is unreadable to `grep`. Never commit one
  taken against the real tree.
- **Dates.** Too collision-prone to block — a date of birth is identifying, but
  so is every version number and copyright year.

The containment that doesn't depend on any of this is **publishing the viewer
from a separate repository** that contains only the shell. Then the Swift app,
its design notes and this history never go near GitHub at all, and a mistake here
cannot become public. These hooks are the second line, not the first.
