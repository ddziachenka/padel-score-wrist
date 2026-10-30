#!/usr/bin/env python3
"""Require six unmodified XCTest captures for every additional shipping locale."""
import hashlib
import json
from pathlib import Path
import re
import struct
from html.parser import HTMLParser

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / 'AI/store-assets'
EXPECTED = ['01-match', '02-golden-point', '03-americano', '04-edit-score', '05-result', '06-history']
rows = json.loads((ROOT / 'Config/localizations.json').read_text())['locales']

class Images(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.images = []
        self.feed(html)

    def handle_starttag(self, tag, attributes):
        if tag == 'img':
            self.images.append(dict(attributes))

count = 0
for locale in rows:
    manifest = json.loads((ASSETS / locale['id'] / 'manifest.json').read_text())
    assert manifest['locale'] == locale['id']
    assert re.fullmatch(r'[0-9a-f]{40}', manifest['source_sha']), 'exact source SHA required'
    assert manifest['device_udid'] and manifest['result_bundle'] and manifest['test']
    assert manifest['configuration_delta'] == {'SIMULATOR_DEVICE_TYPE': {'from': 'com.apple.CoreSimulator.SimDeviceType.Apple-Watch-SE-40mm-2nd-generation', 'to': 'com.apple.CoreSimulator.SimDeviceType.Apple-Watch-SE-44mm-2nd-generation'}}
    screenshots = manifest['screenshots']
    assert [Path(row['file']).stem for row in screenshots] == EXPECTED
    expected_images = []
    for row in screenshots:
        path = ASSETS / row['file']
        assert path.is_relative_to(ASSETS / locale['id']), 'capture escaped its locale'
        data = path.read_bytes()
        assert data[:8] == b'\x89PNG\r\n\x1a\n'
        assert struct.unpack('>II', data[16:24]) == (368, 448)
        assert hashlib.sha256(data).hexdigest() == row['sha256']
        web_path = '/images/' + locale['route'] + '/' + path.name
        assert (ROOT / 'Web/public' / web_path.lstrip('/')).read_bytes() == data
        expected_images.append(web_path)
        assert all(row.get(k) for k in ['attachment', 'fixture', 'actions', 'timestamp'])
        count += 1
    # Historical originals above remain byte-checked. Active pages use the full
    # current M25 narrative and must have every native capture in exact order.
    active = json.loads((ASSETS / 'm25/manifest.json').read_text())['locales'][locale['store'][0]]
    expected_images = ['/images/m25/' + locale['route'] + '/' + Path(row['file']).name for row in active['watch']]
    images = Images((ROOT / 'Web/public' / locale['route'] / 'index.html').read_text()).images
    assert [img['src'] for img in images] == expected_images
    assert all(img.get('alt', '').strip() for img in images)
print(f'Historical localized source assets: {count} original 368 × 448 captures, hashes, provenance, web copies and alt text verified')
