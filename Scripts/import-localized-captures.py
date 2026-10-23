#!/usr/bin/env python3
"""Import unmodified xcresulttool PNG exports and preserve their provenance."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct

ROOT = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser()
parser.add_argument('--exports', type=Path, required=True)
parser.add_argument('--source-sha', required=True)
parser.add_argument('--result', required=True)
parser.add_argument('--locale', action='append', help='Import only explicitly selected locales; default is all')
args = parser.parse_args()
assert re.fullmatch('[0-9a-f]{40}', args.source_sha)
export = json.loads((args.exports / 'manifest.json').read_text())
registry = json.loads((ROOT / 'Config/localizations.json').read_text())['locales']
fixtures = ['storeMatch', 'storeGoldenPoint', 'storeAmericano', 'storeMatch', 'storeResult', 'storeHistory']
actions = ['launch live score; capture before award/Undo check', 'launch at 40–40; capture', 'launch 13–10 of 32; capture', 'Game menu → Edit score; capture', 'launch saved three-set Match result; capture', 'New game → History; capture']
stems = ['01-match', '02-golden-point', '03-americano', '04-edit-score', '05-result', '06-history']
assert not args.locale or set(args.locale) <= {r['id'] for r in registry}
selected = [r for r in registry if not args.locale or r['id'] in args.locale]
for locale in selected:
    identifier = 'testLocalized' + locale['id'].replace('-', '') + 'Screens'
    tests = [test for test in export if identifier in test['testIdentifier']]
    assert len(tests) == 1, (locale['id'], tests)
    test = tests[0]
    screenshots = []
    devices = set()
    for stem, fixture, action in zip(stems, fixtures, actions):
        prefix = 'l10n-' + locale['id'] + '-' + stem
        matches = [a for a in test['attachments'] if a['suggestedHumanReadableName'].startswith(prefix) and a['exportedFileName'].endswith('.png')]
        assert len(matches) == 1, (locale['id'], stem, matches)
        attachment = matches[0]
        assert not attachment['isAssociatedWithFailure']
        data = (args.exports / attachment['exportedFileName']).read_bytes()
        assert data[:8] == b'\x89PNG\r\n\x1a\n' and struct.unpack('>II', data[16:24]) == (368, 448)
        relative = Path(locale['id']) / 'watch-44mm' / (stem + '.png')
        dest = ROOT / 'AI/store-assets' / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(data)
        web = ROOT / 'Web/public/images' / locale['route'] / dest.name
        web.parent.mkdir(parents=True, exist_ok=True)
        web.write_bytes(data)
        devices.add(attachment['deviceId'])
        screenshots.append({'file': str(relative), 'sha256': hashlib.sha256(data).hexdigest(), 'fixture': fixture, 'actions': action, 'attachment': attachment['exportedFileName'], 'timestamp': attachment['timestamp']})
    assert len(devices) == 1
    manifest = {'locale': locale['id'], 'source_sha': args.source_sha, 'device_udid': next(iter(devices)), 'device': 'Apple Watch SE (2nd generation), 44 mm', 'runtime': 'watchOS 26.1 (23S36)', 'dimensions': [368,448], 'result_bundle': args.result, 'test': test['testIdentifier'], 'configuration_delta': {'SIMULATOR_DEVICE_TYPE': {'from': 'com.apple.CoreSimulator.SimDeviceType.Apple-Watch-SE-40mm-2nd-generation', 'to': 'com.apple.CoreSimulator.SimDeviceType.Apple-Watch-SE-44mm-2nd-generation'}}, 'screenshots': screenshots}
    (ROOT / 'AI/store-assets' / locale['id'] / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+'\n')
print(f'Imported {6 * len(selected)} raw XCTest captures with SHA-256 provenance and identical website copies')
