#!/bin/sh
# Shared scanner for the privacy hooks. See .githooks/README.md.
#
# Two independent gates, because they fail in different ways:
#   1. STRUCTURAL — file paths that are tree content by their very nature.
#      .gitignore already lists these, but .gitignore does nothing about
#      `git add -f`, and nothing at all about commit messages.
#   2. TERMS — real names, places and source titles, greped from a denylist that
#      lives OUTSIDE the repo (it is itself tree content). Regenerate with:
#          swift run FamilyHistory --privacy-names
#
# Nothing in this file may contain a real name: it is committed.

TERMS_FILE="${FH_PRIVACY_TERMS:-$HOME/Library/Application Support/FamilyHistory/privacy-guard-terms.txt}"
GUARD_DIR="$(git rev-parse --show-toplevel)/.githooks"
ALLOW_FILE="$GUARD_DIR/allow.txt"
SCAN_AWK="$GUARD_DIR/scan.awk"

# Paths that are tree content whatever they contain.
STRUCTURAL='(^|/)tree\.json$|\.familyweb$|(^|/)img/|\.ged$|\.gedcom$|\.sqlite($|-wal$|-shm$)|privacy-guard-terms\.txt$'

# Print offending paths from a newline-separated list on stdin.
guard_paths() {
  grep -Ei "$STRUCTURAL" || true
}

# Scan text on stdin for denylisted terms. Prints each term found, once.
# See scan.awk — this deliberately does NOT use `grep -o`, which fails open on
# macOS when combined with -i -F -f.
guard_terms() {
  [ -s "$TERMS_FILE" ] || return 0
  [ -f "$ALLOW_FILE" ] || ALLOW_FILE=/dev/null
  awk -v termsfile="$TERMS_FILE" -v allowfile="$ALLOW_FILE" \
      -f "$SCAN_AWK" "$TERMS_FILE" "$ALLOW_FILE" - | sort
}

fail_banner() {
  echo ""
  echo "⛔️  BLOCKED: this looks like real family-tree content."
  echo "    pwa-viewer/NOTES.md, THE RULE: the repo carries the viewer SHELL only."
  echo ""
}

terms_missing_warning() {
  [ -s "$TERMS_FILE" ] && return 0
  echo "⚠️  privacy guard: no denylist at"
  echo "    $TERMS_FILE"
  echo "    Only structural checks ran. Generate the full list with:"
  echo "      swift run FamilyHistory --privacy-names"
}
