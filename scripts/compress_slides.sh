#!/usr/bin/env bash
# compress_slides.sh ------------------------------------------------------
# Compress PDFs under teaching/*/slides/ using ghostscript /ebook (150 dpi).
# Typical reduction is 60-85% for image-heavy slide decks coming from
# PowerPoint / Keynote / Quarto Reveal.
#
# Usage:
#   bash scripts/compress_slides.sh                 # compress all >5MB PDFs
#   bash scripts/compress_slides.sh --dry-run       # show what would change
#   bash scripts/compress_slides.sh --min-mb 10     # only compress > 10MB
#   bash scripts/compress_slides.sh teaching/mfc    # restrict to one course
#
# Safety:
# - Writes the compressed PDF to a temp file first, then atomically replaces.
# - Skips files whose compressed version would be larger than the original.
# - Skips already-small PDFs (configurable threshold, default 5 MB).
#
# Requirements: ghostscript (`brew install ghostscript` on macOS).
# -------------------------------------------------------------------------

set -euo pipefail

# ---- defaults --------------------------------------------------------------
MIN_MB=5
DRY_RUN=0
TARGET="teaching"

# ---- args ------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)   DRY_RUN=1; shift ;;
    --min-mb)    MIN_MB="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,21p' "$0"; exit 0 ;;
    *)           TARGET="$1"; shift ;;
  esac
done

# ---- preflight -------------------------------------------------------------
if ! command -v gs >/dev/null 2>&1; then
  echo "❌  ghostscript (gs) not found." >&2
  echo "    macOS:  brew install ghostscript" >&2
  echo "    Linux:  sudo apt-get install ghostscript" >&2
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "❌  directory not found: $TARGET" >&2
  exit 1
fi

# bytes threshold
MIN_BYTES=$(( MIN_MB * 1024 * 1024 ))

# stdin helper
human() {
  local b=$1
  if   (( b > 1048576 )); then printf "%.1fM" "$(echo "$b/1048576" | bc -l)"
  elif (( b > 1024 ));    then printf "%.1fK" "$(echo "$b/1024" | bc -l)"
  else                         printf "%dB" "$b"
  fi
}

# ---- main loop -------------------------------------------------------------
echo "Scanning $TARGET for PDFs > ${MIN_MB} MB ..."
total_before=0
total_after=0
n_done=0
n_skip=0

# Loop over PDFs found under */slides/ subfolders (handles spaces)
while IFS= read -r -d '' pdf; do
  size_before=$(stat -f%z "$pdf" 2>/dev/null || stat -c%s "$pdf")
  if (( size_before < MIN_BYTES )); then
    continue
  fi

  total_before=$(( total_before + size_before ))

  printf "• %-60s  %s  " "$pdf" "$(human "$size_before")"

  if (( DRY_RUN == 1 )); then
    echo "[dry-run]"
    n_skip=$(( n_skip + 1 ))
    continue
  fi

  tmp="${pdf}.gs.tmp"
  if gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH \
        -sOutputFile="$tmp" "$pdf" 2>/dev/null; then

    size_after=$(stat -f%z "$tmp" 2>/dev/null || stat -c%s "$tmp")
    # Sanity: only replace if smaller AND non-empty (>10KB to catch truncation)
    if (( size_after < size_before )) && (( size_after > 10240 )); then
      mv "$tmp" "$pdf"
      reduction=$(( 100 - (size_after * 100 / size_before) ))
      printf "→  %s  (-%d%%)\n" "$(human "$size_after")" "$reduction"
      total_after=$(( total_after + size_after ))
      n_done=$(( n_done + 1 ))
    else
      rm -f "$tmp"
      echo "→  skip (no gain or output too small)"
      total_after=$(( total_after + size_before ))
      n_skip=$(( n_skip + 1 ))
    fi
  else
    rm -f "$tmp"
    echo "→  gs failed"
    total_after=$(( total_after + size_before ))
    n_skip=$(( n_skip + 1 ))
  fi
done < <(find "$TARGET" -path "*/slides/*.pdf" -print0)

# ---- summary ---------------------------------------------------------------
echo
echo "================================================================"
echo "Compressed:  $n_done file(s)"
echo "Skipped:     $n_skip file(s)"
echo "Total size:  $(human "$total_before")  →  $(human "$total_after")"
if (( total_before > 0 )); then
  saved=$(( 100 - (total_after * 100 / total_before) ))
  echo "Saved:       ${saved}%"
fi
