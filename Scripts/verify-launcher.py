#!/usr/bin/env python3
"""Validate the launcher target graph and (optionally) its built Watch package."""
import argparse
import json
from pathlib import Path
import plistlib
import subprocess

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / "App/PadelScore.xcodeproj/project.pbxproj"


def require(condition, message):
    if not condition:
        raise SystemExit("Watch launcher: " + message)


def verify(built_app=None):
    objects = json.loads(subprocess.check_output([
        "plutil", "-convert", "json", "-o", "-", str(PROJECT)
    ]))["objects"]
    targets = {v["name"]: (k, v) for k, v in objects.items() if v["isa"] == "PBXNativeTarget"}
    identity, widget = targets["PadelScoreLauncher"]
    _, app = targets["PadelScoreWatch"]
    require(widget["productType"] == "com.apple.product-type.app-extension", "target is not an extension")
    require(any(objects[d].get("target") == identity for d in app["dependencies"]), "Watch app must build the launcher")
    phases = [objects[p] for p in app["buildPhases"]]
    copies = [p for p in phases if p["isa"] == "PBXCopyFilesBuildPhase" and p["dstSubfolderSpec"] == "13"]
    require(len(copies) == 1 and [objects[f]["fileRef"] for f in copies[0]["files"]] == [widget["productReference"]],
            "Watch app must embed exactly its launcher in PlugIns")
    def configurations(target):
        return {objects[c]["name"]: objects[c]["buildSettings"]
                for c in objects[target["buildConfigurationList"]]["buildConfigurations"]}
    app_settings = configurations(app)
    widget_settings = configurations(widget)
    require(widget_settings.keys() == app_settings.keys(), "extension must build in every app configuration")
    for name, settings in widget_settings.items():
        for key in ("MARKETING_VERSION", "CURRENT_PROJECT_VERSION", "WATCHOS_DEPLOYMENT_TARGET"):
            require(settings[key] == app_settings[name][key], f"{name} {key} differs from Watch app")
        require(settings["WATCHOS_DEPLOYMENT_TARGET"] == "10.0", "minimum watchOS must stay 10")
        require(settings["APPLICATION_EXTENSION_API_ONLY"] == "YES", "extension-safe APIs required")
        require(settings["SKIP_INSTALL"] == "YES", "extension must ship only inside the app")
        require(not settings.get("CODE_SIGN_ENTITLEMENTS"), "static launcher needs no shared-container entitlement")
        require(settings["PRODUCT_BUNDLE_IDENTIFIER"] == app_settings[name]["PRODUCT_BUNDLE_IDENTIFIER"] + ".launcher",
                "extension identifier must belong to Watch app")
    sources = [objects[objects[f]["fileRef"]]["path"] for p in widget["buildPhases"]
               if objects[p]["isa"] == "PBXSourcesBuildPhase" for f in objects[p]["files"]]
    require(set(sources) == {"PadelScoreLauncher/LauncherWidget.swift", "PadelScoreLauncher/LauncherBundle.swift"},
            "launcher must remain isolated from session/purchase code")
    if built_app:
        def plist(path):
            with path.open("rb") as source:
                return plistlib.load(source)
        app_plist = plist(built_app / "Info.plist")
        extensions = list((built_app / "PlugIns").glob("*.appex"))
        require([p.name for p in extensions] == ["PadelScoreLauncher.appex"], "built extension missing or unexpected extension")
        launcher = extensions[0]
        info = plist(launcher / "Info.plist")
        for key in ("CFBundleShortVersionString", "CFBundleVersion", "MinimumOSVersion", "CFBundleSupportedPlatforms"):
            require(info[key] == app_plist[key], f"built {key} mismatch")
        require(info["CFBundleIdentifier"] == app_plist["CFBundleIdentifier"] + ".launcher", "built extension identifier mismatch")
        require(info["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.widgetkit-extension", "wrong extension point")
        require((launcher / info["CFBundleExecutable"]).is_file(), "extension executable missing")
        require(not any("StoreKitHost" in p.name or p.suffix == ".xctest" for p in built_app.rglob("*")),
                "shipping package contains a test host or test bundle")
    print("Watch launcher: target graph" + (" and built package" if built_app else "") + " verified")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--built-app", type=Path)
    verify(parser.parse_args().built_app)
