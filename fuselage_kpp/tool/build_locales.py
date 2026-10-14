"""Build app_{locale}.arb from app_en.arb with machine-assisted translations."""
from __future__ import annotations

import json
import re
import sys
import time
from pathlib import Path

import urllib.error
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"
EN_PATH = L10N / "app_en.arb"

LOCALES = {
    "de": "de",
    "es": "es",
    "ar": "ar",
    "hi": "hi",
}

# Keep these substrings unchanged during translation (case-sensitive where noted).
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
    "M1",
    "M2",
    "M3",
    "M4",
    "M5",
    "M6",
    "M7",
    "M8",
    "CH1",
    "CH2",
    "CH3",
    "CH4",
    "CH5",
    "CH6",
    "CH7",
    "CH8",
    "CH9",
    "CH10",
    "CH11",
    "CH12",
    "FRAME",
    "SHAPE",
    "GPS1",
    "GPS2",
    "FWVERSION",
    "BATT_VOLT_MULT",
    "Documents\\Fuselage-K++\\logs",
    "JIYI221014",
    "网络备案",
    "Quad X",
    "Quad +",
    "Hexa X",
    "Hexa +",
    "Octo X",
    "Octo +",
    "Y6",
]

PLACEHOLDER_RE = re.compile(r"\{[a-zA-Z_]+\}")
HTML_TAG_RE = re.compile(r"<[^>]+>")


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
    text = HTML_TAG_RE.sub("", text)
    for i, term in enumerate(GLOSSARY):
        text = text.replace(f"ZZZG{i}ZZZ", term)
    for i, ph in enumerate(placeholders):
        text = text.replace(f"ZZZPH{i}ZZZ", ph)
    return text


def translate_text(text: str, target: str, cache: dict[tuple[str, str], str]) -> str:
    key = (target, text)
    if key in cache:
        return cache[key]
    protected, placeholders = protect(text)
    if not protected.strip():
        cache[key] = text
        return text
    langpair = f"en|{target}"
    query = urllib.parse.urlencode({"q": protected, "langpair": langpair})
    url = f"https://api.mymemory.translated.net/get?{query}"
    last_error: Exception | None = None
    for attempt in range(10):
        try:
            with urllib.request.urlopen(url, timeout=30) as response:
                payload = json.loads(response.read().decode("utf-8"))
            if payload.get("responseStatus") != 200:
                raise RuntimeError(payload.get("responseDetails", "translation failed"))
            out = payload["responseData"]["translatedText"]
            if not str(out).strip():
                raise RuntimeError("empty translation")
            result = restore(str(out), placeholders)
            cache[key] = result
            time.sleep(2.5)
            return result
        except urllib.error.HTTPError as error:
            last_error = error
            if error.code == 429:
                time.sleep(90.0 * (attempt + 1))
            else:
                time.sleep(5.0 * (attempt + 1))
        except Exception as error:
            last_error = error
            time.sleep(5.0 * (attempt + 1))
    raise last_error  # type: ignore[misc]


def ordered_en_keys(en: dict) -> list[str]:
    keys = [k for k in en if not k.startswith("@")]
    meta_first = ["@@locale"]
    return meta_first + keys


def build_locale(en: dict, locale: str, target: str, existing: dict, cache: dict) -> dict:
    out: dict = {"@@locale": locale}
    for key in en:
        if key.startswith("@"):
            out[key] = en[key]
            continue
        en_val = en[key]
        if key in existing and existing[key] != en_val and locale != "en":
            out[key] = existing[key]
            continue
        if key == "appName":
            out[key] = en_val
            continue
        out[key] = translate_text(en_val, target, cache)
    return out


def count_untranslated(en: dict, loc: dict) -> int:
    n = 0
    for key in en:
        if key.startswith("@"):
            continue
        if loc.get(key) == en[key] and key not in ("appName",):
            n += 1
    return n


def main() -> None:
    en = json.loads(EN_PATH.read_text(encoding="utf-8"))
    cache: dict[tuple[str, str], str] = {}
    only = sys.argv[1:] if len(sys.argv) > 1 else list(LOCALES.keys())
    for locale in only:
        target = LOCALES[locale]
        path = L10N / f"app_{locale}.arb"
        existing = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
        message_keys = [k for k in en if not k.startswith("@")]
        need = [
            k
            for k in message_keys
            if k not in existing or existing.get(k) == en.get(k)
        ]
        print(f"Translating {locale}: {len(need)} keys…", flush=True)
        loc: dict = {"@@locale": locale}
        for key in en:
            if key.startswith("@"):
                loc[key] = en[key]
        for key in message_keys:
            if key in existing and existing.get(key) != en.get(key) and key not in need:
                loc[key] = existing[key]
            elif key not in loc:
                loc[key] = en[key]
        for i, key in enumerate(need):
            if key == "appName":
                loc[key] = en[key]
                continue
            loc[key] = translate_text(en[key], target, cache)
            if (i + 1) % 20 == 0:
                path.write_text(json.dumps(loc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
                print(f"  checkpoint {i + 1}/{len(need)}", flush=True)
        loc["@@locale"] = locale
        path.write_text(json.dumps(loc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        missing = [k for k in message_keys if k not in loc]
        untrans = count_untranslated(en, loc)
        print(
            f"  wrote {path.name}, missing keys: {len(missing)}, same as en: {untrans}",
            flush=True,
        )


if __name__ == "__main__":
    main()
