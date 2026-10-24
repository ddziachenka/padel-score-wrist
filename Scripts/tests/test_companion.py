"""Mutation tests for independent Watch and real iPhone distribution packaging."""
import importlib.util
from pathlib import Path
import plistlib
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location("companion", Path(__file__).parents[1] / "verify-companion.py")
companion = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(companion)


class CompanionPackagingTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="padel-companion-")
        self.addCleanup(self.temporary.cleanup)
        self.phone = Path(self.temporary.name) / "PadelScore.app"
        self.watch = self.phone / "Watch/PadelScoreWatch.app"
        self.watch.mkdir(parents=True)
        self.phone_info = {"CFBundleIdentifier": companion.PHONE_ID, "CFBundleExecutable": "PadelScore",
                           "CFBundleVersion": "2", "CFBundleShortVersionString": "1.0", "CFBundlePackageType": "APPL", "UIDeviceFamily": [1]}
        self.watch_info = {"CFBundleIdentifier": companion.WATCH_ID, "CFBundleExecutable": "PadelScoreWatch",
                           "CFBundleVersion": "2", "CFBundleShortVersionString": "1.0", "CFBundlePackageType": "APPL",
                           "WKApplication": True, "WKRunsIndependentlyOfCompanionApp": True,
                           "WKCompanionAppBundleIdentifier": companion.PHONE_ID}
        (self.phone / "PadelScore").write_bytes(b"iOS executable")
        (self.watch / "PadelScoreWatch").write_bytes(b"Watch executable")
        self.save()

    def save(self):
        (self.phone / "Info.plist").write_bytes(plistlib.dumps(self.phone_info))
        (self.watch / "Info.plist").write_bytes(plistlib.dumps(self.watch_info))

    def check(self):
        return companion.validate_phone(self.phone, run_launcher=False)

    def test_valid_real_phone_and_independent_watch(self):
        self.assertEqual(self.check()["CFBundleIdentifier"], companion.PHONE_ID)

    def test_watch_only_stub_and_prohibited_phone_are_rejected(self):
        for flag in ("ITSWatchOnlyContainer", "LSApplicationLaunchProhibited"):
            with self.subTest(flag=flag):
                self.phone_info[flag] = True
                self.save()
                with self.assertRaises(ValueError):
                    self.check()
                self.phone_info.pop(flag)

    def test_watch_dependency_or_wrong_identity_is_rejected(self):
        for key, value in (("WKRunsIndependentlyOfCompanionApp", False), ("WKWatchOnly", True),
                           ("WKCompanionAppBundleIdentifier", "com.wrong.app"), ("CFBundleVersion", "1")):
            with self.subTest(key=key):
                before = self.watch_info.copy()
                self.watch_info[key] = value
                self.save()
                with self.assertRaises(ValueError):
                    self.check()
                self.watch_info = before

    def test_missing_executable_or_embedded_watch_is_rejected(self):
        (self.phone / "PadelScore").unlink()
        with self.assertRaises(ValueError):
            self.check()
        (self.phone / "PadelScore").write_bytes(b"iOS executable")
        self.watch.rename(self.phone / "detached-watch.app")
        with self.assertRaises(ValueError):
            self.check()

    def test_test_host_and_local_storekit_config_cannot_ship(self):
        for name in ("Lifetime.storekit", "PadelScorePhoneStoreKitHost.app", "Tests.xctest"):
            with self.subTest(name=name):
                leaked = self.phone / name
                leaked.touch()
                with self.assertRaises(ValueError):
                    self.check()
                leaked.unlink()


if __name__ == "__main__":
    unittest.main()
