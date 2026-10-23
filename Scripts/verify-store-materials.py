#!/usr/bin/env python3
"""Validate the six direct captures and their byte-identical website copies."""
import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / 'AI/store-assets'
manifest = json.loads((ASSETS / 'manifest.json').read_text())
expected = ['01-match', '02-golden-point', '03-americano', '04-edit-score', '05-result', '06-history']
assert [Path(row['file']).stem for row in manifest['screenshots']] == expected, 'six screenshots in presentation order required'
assert len(manifest['source_sha']) == 40 and all(c in '0123456789abcdef' for c in manifest['source_sha']), 'full source SHA required'
for row in manifest['screenshots']:
    data = (ASSETS / row['file']).read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', row['file']
    assert struct.unpack('>II', data[16:24]) == (368, 448), row['file']
    assert hashlib.sha256(data).hexdigest() == row['sha256'], row['file']
    web_copy = ROOT / 'Web/public/images' / Path(row['file']).name
    assert web_copy.read_bytes() == data, f'{web_copy}: must be the original capture'
    assert row['attachment'] and row['fixture'] and row['actions'], 'capture provenance required'
print('Store materials: six 368 × 448 PNG captures, SHA-256 and identical site images verified')
