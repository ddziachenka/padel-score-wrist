#!/usr/bin/env python3
"""Regression tests for the checks guarding shipped translation resources."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('localizations', Path(__file__).with_name('verify-localizations.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class LocalizationValidationTests(unittest.TestCase):
    def test_reordered_positional_arguments_preserve_identity(self):
        self.assertEqual(module.tokens('%@ %lld'), module.tokens('%2$lld %1$@'))

    def test_swapped_argument_types_are_rejected(self):
        self.assertNotEqual(module.tokens('%@ %lld'), module.tokens('%1$lld %2$@'))

    def test_lost_or_duplicated_arguments_are_rejected(self):
        self.assertNotEqual(module.tokens('%@ %lld'), module.tokens('%@'))
        self.assertNotEqual(module.tokens('%@ %lld'), module.tokens('%@ %lld %lld'))

    def test_substitution_tokens_are_not_positional_arguments(self):
        self.assertEqual(module.tokens('%#@total@, %2$lld'), module.tokens('%2$lld / %#@total@'))

    def test_nested_plural_units_are_included(self):
        node={'stringUnit':{'value':'%#@total@'},'substitutions':{'total':{'variations':{'plural':{'one':{'stringUnit':{'value':'%arg point'}},'other':{'stringUnit':{'value':'%arg points'}}}}}}}
        self.assertEqual([r['value'] for r in module.units(node)], ['%#@total@','%arg point','%arg points'])

    def test_duplicate_catalog_keys_are_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            path=Path(folder)/'catalog.json'
            path.write_text('{"key":1,"key":2}')
            with self.assertRaisesRegex(ValueError,'duplicate key'):
                module.load(path)

if __name__ == '__main__':
    unittest.main()
