#!/usr/bin/env python3
"""Validate M16's unmodified, permanent iPhone store gallery and provenance."""
import hashlib
import json
from pathlib import Path
import re
import struct

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "AI/store-assets/iphone-m16"
LOCALES = ["en-US", "es-ES", "es-MX", "it", "fr-FR", "pt-PT", "pt-BR",
           "nl-NL", "de-DE", "sv", "da", "fi", "no", "ru"]
ORDER = ["01-start", "02-match", "03-americano", "04-access"]


def validate():
    manifest = json.loads((ASSETS / "manifest.json").read_text())
    assert re.fullmatch(r"[0-9a-f]{40}", manifest["source_sha"]), "full capture source SHA required"
    assert manifest["capture_kind"] == "native-xcuiscreen-unmodified"
    assert manifest["appearance"] == "dark"
    assert manifest["access_state"] == "StoreKit-verified lifetime; no temporary price"
    assert all(manifest.get(k) for k in ["device_udid", "runtime", "result_bundle", "test", "storekit_fixture_sha256"])
    assert list(manifest["locales"]) == LOCALES, "four captures for every ASC locale required"
    paths = set()
    for locale, rows in manifest["locales"].items():
        assert [Path(row["file"]).stem for row in rows] == ORDER, locale
        for row in rows:
            path = ASSETS / row["file"]
            assert path.parent == ASSETS / locale and not path.is_symlink(), "unsafe capture path"
            data = path.read_bytes()
            assert data[:8] == b"\x89PNG\r\n\x1a\n", row["file"]
            assert struct.unpack(">II", data[16:24]) == (1320, 2868), row["file"]
            assert data[25] == 2, "opaque RGB PNG required"
            offset = 8
            while offset < len(data):
                length = struct.unpack(">I", data[offset:offset + 4])[0]
                kind = data[offset + 4:offset + 8]
                assert kind != b"tRNS", "transparency must not be present"
                offset += length + 12
            assert offset == len(data), "invalid PNG chunk boundary"
            assert hashlib.sha256(data).hexdigest() == row["sha256"], row["file"]
            assert all(row.get(k) for k in ["attachment", "timestamp", "language", "region", "state"])
            paths.add(path)
    assert set(ASSETS.glob("*/*.png")) == paths, "unexpected or missing gallery image"
    print("iPhone store materials: 56 native opaque 1320 × 2868 captures, 14 locales, order, hashes and provenance verified")


if __name__ == "__main__":
    validate()
