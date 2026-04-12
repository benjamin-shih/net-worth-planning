#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "Net Worth.xlsx"
  "AGENTS.md"
  "CLAUDE.md"
  "net-worth-workbook-handoff.md"
  "career-financial-planning-memo.md"
  "progress-log.md"
  "todo.md"
  "tasks/lessons.md"
)

for path in "${required_files[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

python3 - <<'PY'
from pathlib import Path
from zipfile import BadZipFile, ZipFile

path = Path("Net Worth.xlsx")
try:
    with ZipFile(path) as workbook:
        workbook.getinfo("xl/workbook.xml")
except (BadZipFile, KeyError) as exc:
    raise SystemExit(f"{path} is not a valid .xlsx workbook: {exc}")

print("Workbook package is readable.")
PY

echo "Validation passed."
