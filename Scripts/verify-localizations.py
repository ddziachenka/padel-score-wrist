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
CATALOGS = [ROOT / 'App/PadelScoreWatch/Localizable.xcstrings', ROOT / 'App/PadelScoreLauncher/Localizable.xcstrings', ROOT / 'App/PadelScorePhone/Localizable.xcstrings']
TOKEN = re.compile(r'%(?:(\d+)\$)?(lld|ld|d|@|f)')

def tokens(value):
    result = Counter()
    implicit = 1
    for position, kind in TOKEN.findall(value):
        index = int(position) if position else implicit
        if not position:
            implicit += 1
        result[(index, kind)] += 1
    return result

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


class Page(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.links = []
        self.feed(html)

    def handle_starttag(self, tag, attributes):
        self.links.append((tag, dict(attributes)))


def validate_routes(locale, route, page, html):
    parsed = Page(html)
    origin = 'https://padel-score-wrist.pages.dev'
    rows = [{'id': 'en', 'route': ''}] + REGISTRY['locales']
    expected = {r['id']: f'{origin}/{r["route"] + "/" if r["route"] else ""}{page}' for r in rows}
    expected['x-default'] = f'{origin}/{page}'
    alternates = {a.get('hreflang'): a.get('href') for tag, a in parsed.links if tag == 'link' and a.get('rel') == 'alternate'}
    assert alternates == expected, f'{locale}: incomplete alternate routes {page}'
    canonical = [a['href'] for tag, a in parsed.links if tag == 'link' and a.get('rel') == 'canonical']
    assert canonical == [expected[locale]], f'{locale}: canonical {page}'
    navigation = {a.get('hreflang'): a.get('href') for tag, a in parsed.links if tag == 'a' and a.get('hreflang')}
    assert navigation == {k: v.removeprefix(origin) for k, v in expected.items() if k != 'x-default'}, f'{locale}: language navigation {page}'
    for tag, attributes in parsed.links:
        href = attributes.get('href', '')
        if href.startswith('/'):
            target = ROOT / 'Web/public' / href.lstrip('/').split('#')[0]
            if href.endswith('/'):
                target = target / 'index.html'
            assert target.is_file(), f'{locale}: missing linked route {href}'

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
        if all((ROOT / 'Web/public' / r['route'] / 'index.html').is_file() for r in REGISTRY['locales']):
            validate_routes(locale, row['route'], page, html)
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
    available = {locale for path in CATALOGS for entry in load(path)['strings'].values() for locale in entry.get('localizations', {})} - {'en'}
    locales = args.locale or ([r['id'] for r in REGISTRY['locales']] if args.all else sorted(available))
    if all((ROOT / 'Web/public' / r['route'] / 'index.html').is_file() for r in REGISTRY['locales']):
        for page in ['', 'privacy/', 'terms/', 'support/']:
            html = (ROOT / 'Web/public' / page / 'index.html').read_text()
            validate_routes('en', '', page, html)
    for locale in locales:
        count=validate_locale(locale)
        print(f'{locale}: {count} catalog keys, four pages, store drafts, glossary checked')
    print(f'Localization validation: {len(locales)} added locales checked')
if __name__ == '__main__':
    main()
