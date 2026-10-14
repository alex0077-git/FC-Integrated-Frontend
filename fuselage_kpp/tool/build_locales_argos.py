"""Offline locale ARB generation via Argos Translate."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import argostranslate.package
import argostranslate.translate

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"
EN_PATH = L10N / "app_en.arb"

LOCALES = ("es", "ar", "hi")

GLOSSARY = [
    "Fuselage-K++",
    "K++",
    "GPS",
    "IMU",
    "RC",
    "USB",
    "COM",
    "PWM",
    "AB",
    "RTK",
    "MAVLink",
    "JIYI",
    "WiFi",
    "Bluetooth",
    "RTL",
    "Guided",
    "Loiter",
    "ARMED",
    "HDOP",
    "PMU",
    "ESC",
    "FRAME",
    "SHAPE",
    "Documents\\Fuselage-K++\\logs",
    "JIYI221014",
    "网络备案",
]

PLACEHOLDER_RE = re.compile(r"\{[a-zA-Z_]+\}")


def ensure_package(from_code: str, to_code: str) -> None:
    try:
        argostranslate.translate.translate("ok", from_code, to_code)
        return
    except Exception:
        pass
    argostranslate.package.update_package_index()
    available = argostranslate.package.get_available_packages()
    package = next(p for p in available if p.from_code == from_code and p.to_code == to_code)
    download_path = package.download()
    argostranslate.package.install_from_path(download_path)


def protect(text: str) -> tuple[str, list[str]]:
    tokens: list[str] = []

    def stash(match: re.Match[str]) -> str:
        tokens.append(match.group(0))
        return f"ZZZPH{len(tokens) - 1}ZZZ"

    protected = PLACEHOLDER_RE.sub(stash, text)
    for i, term in enumerate(GLOSSARY):
        protected = protected.replace(term, f"ZZZG{i}ZZZ")
    return protected, tokens


def restore(text: str, placeholders: list[str]) -> str:
    for i, term in enumerate(GLOSSARY):
        text = text.replace(f"ZZZG{i}ZZZ", term)
    for i, ph in enumerate(placeholders):
        text = text.replace(f"ZZZPH{i}ZZZ", ph)
    return text


def translate(text: str, to_code: str, cache: dict[tuple[str, str], str]) -> str:
    key = (to_code, text)
    if key in cache:
        return cache[key]
    protected, placeholders = protect(text)
    translated = argostranslate.translate.translate(protected, "en", to_code)
    result = restore(translated, placeholders)
    cache[key] = result
    return result


def build(locale: str, en: dict, existing: dict, cache: dict[str, str]) -> dict:
    message_keys = [k for k in en if not k.startswith("@")]
    out: dict = {"@@locale": locale}
    for key in en:
        if key.startswith("@"):
            out[key] = en[key]
    for key in message_keys:
        en_val = en[key]
        if key in existing and existing[key] != en_val:
            out[key] = existing[key]
        elif key == "appName":
            out[key] = en_val
        else:
            out[key] = translate(en_val, locale, cache)
    return out


def main() -> None:
    en = json.loads(EN_PATH.read_text(encoding="utf-8"))
    cache: dict[tuple[str, str], str] = {}
    targets = sys.argv[1:] if len(sys.argv) > 1 else list(LOCALES)
    for locale in targets:
        ensure_package("en", locale)
        path = L10N / f"app_{locale}.arb"
        existing = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
        print(f"Building {locale}…", flush=True)
        loc = build(locale, en, existing, cache)
        loc["@@locale"] = locale
        path.write_text(json.dumps(loc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        missing = [k for k in en if not k.startswith("@") and k not in loc]
        print(f"  {path.name}: missing {len(missing)}", flush=True)


if __name__ == "__main__":
    main()
