#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

dist=termbox2-dist.tar.gz

if [[ -f "$dist" ]]; then
    backup="termbox2-dist-$(date +%s).tar.gz"
    mv "$dist" "$backup"
    echo "Existing $dist moved to $backup"
fi

git ls-files --cached --others --exclude-standard -z \
    | while IFS= read -r -d '' file; do
          [[ "$file" == termbox2-dist-*.tar.gz ]] && continue
          [[ -e "$file" ]] || continue
          printf '%s\0' "$file"
      done \
    | tar --null -czf "$dist" -T -

echo "Created $dist"
