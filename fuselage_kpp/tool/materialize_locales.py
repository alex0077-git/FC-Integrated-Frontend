"""Materialize app_{locale}.arb from app_en.arb + optional overrides JSON."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"
BUNDLE = ROOT / "tool" / "bundles"


def materialize(locale: str) -> None:
    en = json.loads((L10N / "app_en.arb").read_text(encoding="utf-8"))
    override_path = BUNDLE / f"{locale}.json"
    overrides = json.loads(override_path.read_text(encoding="utf-8")) if override_path.exists() else {}
    existing_path = L10N / f"app_{locale}.arb"
    existing = json.loads(existing_path.read_text(encoding="utf-8")) if existing_path.exists() else {}

    out: dict = {"@@locale": locale}
    for key, value in en.items():
        if key.startswith("@"):
            out[key] = value
            continue
        if key in overrides:
            out[key] = overrides[key]
        elif key in existing and existing[key] != value:
            out[key] = existing[key]
        elif key in existing:
            out[key] = existing[key]
        else:
            out[key] = value
    (L10N / f"app_{locale}.arb").write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    missing = [k for k in en if not k.startswith("@") and k not in out]
    print(locale, "keys", len([k for k in out if not k.startswith("@")]), "missing", len(missing))


if __name__ == "__main__":
    for loc in sys.argv[1:] or ["es", "ar", "hi"]:
        materialize(loc)
