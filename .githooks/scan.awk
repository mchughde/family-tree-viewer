# Reports which denylisted terms appear in the text on stdin, one per line.
#
#   awk -v termsfile=T -v allowfile=A -f scan.awk T A -
#
# Written in awk rather than `grep -oiwF -f`, which is what this used to be:
# BSD grep on macOS silently returns NOTHING for -o combined with -i -F -f, so
# the guard reported clean while matching perfectly well without -o. A guard that
# fails open is worse than no guard, so the matching is explicit here.
#
# Words are compared after normalising punctuation to spaces, so a name is caught
# whether it is followed by a comma, a full stop or a bracket. Bytes >= 0x80 are
# treated as word characters, so an accented surname stays one word; the terms
# file is already lower-cased by Swift (which lower-cases Unicode properly), and
# awk's ASCII tolower() then matches it — the one gap being an ALL-CAPS
# accented word. Multi-word terms (a full place string) are matched
# as a normalised substring, so a phrase is caught even when its parts are
# individually generic.

function normalise(s) {
  s = tolower(s)
  gsub(/[][ \t.,;:!?(){}"<>\/\\|@#$%^&*=+~`_-]+/, " ", s)
  gsub(/^ +| +$/, "", s)
  return s
}

FILENAME == termsfile {
  if ($0 ~ /^#/ || $0 ~ /^[ \t]*$/) next
  t = normalise($0)
  if (t == "") next
  if (index(t, " ")) phrases[++nphrase] = t; else words[t] = 1
  next
}

FILENAME == allowfile {
  if ($0 ~ /^#/ || $0 ~ /^[ \t]*$/) next
  a = normalise($0)
  if (a != "") allow[a] = 1
  next
}

{
  line = normalise($0)
  n = split(line, part, " ")
  for (i = 1; i <= n; i++)
    if (part[i] in words && !(part[i] in allow)) hit[part[i]] = 1
  for (j = 1; j <= nphrase; j++)
    if (index(line, phrases[j]) && !(phrases[j] in allow)) hit[phrases[j]] = 1
}

END { for (h in hit) print h }
