#!/usr/bin/env python3
"""Check shipping translation structure; editorial quality is reviewed separately."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
from html.parser import HTMLParser

ROOT = Path(__file__).resolve().parent.parent
REGISTRY = json.loads((ROOT / 'Config/localizations.json').read_text())
CATALOGS = [ROOT / 'App/PadelScoreWatch/Localizable.xcstrings', ROOT / 'App/PadelScoreLauncher/Localizable.xcstrings']
TOKEN = re.compile(r'%(?:(\d+)\$)?(lld|ld|d|@|f)')

def tokens(value):
    return Counter(kind for _, kind in TOKEN.findall(value))

def load(path):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f'{path}: duplicate key {key}')
            result[key] = value
        return result
    return json.loads(path.read_text(), object_pairs_hook=unique)

def units(node):
    if isinstance(node, dict):
        if 'stringUnit' in node:
            yield node['stringUnit']
        for key, value in node.items():
            if key != 'stringUnit':
                yield from units(value)

def validate_locale(locale):
    row = next(r for r in REGISTRY['locales'] if r['id'] == locale)
    folder = ROOT / 'AI/localization' / locale
    allow = load(folder / 'unchanged.json')
    for path in CATALOGS:
        catalog = load(path)
        assert catalog['sourceLanguage'] == 'en', path
        for key, entry in catalog['strings'].items():
            if entry.get('shouldTranslate') is False:
                continue
            source = entry['localizations']['en']
            target = entry.get('localizations', {}).get(locale)
            assert target, f'{locale}: missing {key}'
            for unit in units(target):
                assert unit.get('state') == 'translated' and unit.get('value', '').strip(), f'{locale}: unfinished {key}'
            assert tokens(source['stringUnit']['value']) == tokens(target['stringUnit']['value']), f'{locale}: parameters {key}'
            source_sub = source.get('substitutions', {})
            target_sub = target.get('substitutions', {})
            assert set(source_sub) == set(target_sub), f'{locale}: substitutions {key}'
            for name, substitution in source_sub.items():
                translated = target_sub[name]
                for attribute in ['argNum', 'formatSpecifier']:
                    assert translated[attribute] == substitution[attribute], f'{locale}: {key}: {attribute}'
                assert f'%#@{name}@' in target['stringUnit']['value'], f'{locale}: missing substitution reference {key}'
                categories = set(translated['variations']['plural'])
                required = {'one', 'few', 'many', 'other'} if locale == 'ru' else {'one', 'other'}
                if locale.split('-')[0] in {'es','fr','it','pt'}:
                    required.add('many')
                assert required <= categories, f'{locale}: plural forms {key}: {required-categories}'
                for form in translated['variations']['plural'].values():
                    assert '%arg' in form['stringUnit']['value'], f'{locale}: plural argument {key}'
            if target == source or target.get('stringUnit', {}).get('value') == source.get('stringUnit', {}).get('value'):
                assert key in allow and allow[key].strip(), f'{locale}: unexplained English match {key}'
    for page in ['', 'privacy/', 'terms/', 'support/']:
        html = (ROOT / 'Web/public' / row['route'] / page / 'index.html').read_text()
        assert f'lang="{locale}"' in html, f'{locale}: page lang {page}'
        assert f'https://padel-score-wrist.pages.dev/{row["route"]}/{page}' in html, f'{locale}: canonical {page}'
        assert '/styles.css' in html
        if page == 'terms/':
            assert 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/' in html
    store = load(folder / 'app-store.json')
    assert set(store) == set(row['store']), f'{locale}: store locales'
    for identifier, fields in store.items():
        for key, limit in [('name',30),('subtitle',30),('promotionalText',170),('description',4000),('iapName',30),('iapDescription',55)]:
            assert 0 < len(fields[key]) <= limit, f'{identifier}: {key} limit ({len(fields[key])})'
        assert 0 < len(fields['keywords'].encode('utf-8')) <= 100, f'{identifier}: keywords byte limit'
        assert fields['name'] == 'Padel Score — Wrist'
    assert (folder/'review.md').is_file(), f'{locale}: missing glossary and review'
    return len(load(CATALOGS[0])['strings']) + len(load(CATALOGS[1])['strings'])

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--locale', action='append')
    parser.add_argument('--all', action='store_true')
    args=parser.parse_args()
    available = set(load(CATALOGS[0])['strings'][next(iter(load(CATALOGS[0])['strings']))]['localizations'])-{'en'}
    locales = args.locale or ([r['id'] for r in REGISTRY['locales']] if args.all else sorted(available))
    for locale in locales:
        count=validate_locale(locale)
        print(f'{locale}: {count} catalog keys, four pages, store drafts, glossary checked')
    print(f'Localization validation: {len(locales)} added locales checked')
if __name__ == '__main__':
    main()
