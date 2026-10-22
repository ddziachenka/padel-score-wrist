"""Mutation checks: broken packaging cannot silently pass the launcher gate."""
import contextlib
import copy
import importlib.util
import io
import json
from pathlib import Path
import plistlib
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("launcher", Path(__file__).parents[1] / "verify-launcher.py")
launcher = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(launcher)


class LauncherGateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.project = json.loads(subprocess.check_output(["plutil", "-convert", "json", "-o", "-", str(launcher.PROJECT)]))

    def check_rejected(self, change):
        project = copy.deepcopy(self.project)
        objects = project["objects"]
        targets = {v.get("name"): v for v in objects.values() if v["isa"] == "PBXNativeTarget"}
        change(objects, targets["PadelScoreWatch"], targets["PadelScoreLauncher"])
        with tempfile.TemporaryDirectory(prefix="padel-launcher-test-") as temporary:
            path = Path(temporary) / "project.plist"
            path.write_bytes(plistlib.dumps(project))
            with patch.object(launcher, "PROJECT", path), self.assertRaises(SystemExit):
                launcher.verify()

    def test_real_graph_passes(self):
        with contextlib.redirect_stdout(io.StringIO()):
            launcher.verify()

    def test_missing_dependency_is_rejected(self):
        self.check_rejected(lambda objects, app, widget: app.update(dependencies=[]))

    def test_missing_embedding_is_rejected(self):
        def remove(objects, app, widget):
            app["buildPhases"] = [p for p in app["buildPhases"] if objects[p]["isa"] != "PBXCopyFilesBuildPhase"]
        self.check_rejected(remove)

    def test_version_drift_is_rejected(self):
        def change(objects, app, widget):
            config = objects[widget["buildConfigurationList"]]["buildConfigurations"][0]
            objects[config]["buildSettings"]["CURRENT_PROJECT_VERSION"] = "999"
        self.check_rejected(change)

    def test_shared_container_entitlement_is_rejected(self):
        def change(objects, app, widget):
            config = objects[widget["buildConfigurationList"]]["buildConfigurations"][0]
            objects[config]["buildSettings"]["CODE_SIGN_ENTITLEMENTS"] = "Shared.entitlements"
        self.check_rejected(change)

    def test_session_source_in_extension_is_rejected(self):
        def change(objects, app, widget):
            source = next(objects[p] for p in widget["buildPhases"] if objects[p]["isa"] == "PBXSourcesBuildPhase")
            file = objects[source["files"][0]]["fileRef"]
            objects[file]["path"] = "PadelScoreWatch/Services/SessionStore.swift"
        self.check_rejected(change)


if __name__ == "__main__":
    unittest.main()
