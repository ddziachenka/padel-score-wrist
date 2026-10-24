#!/usr/bin/env python3
"""Validate the real iOS/independent Watch distribution, never just project flags."""
import argparse
from collections import Counter
import json
import plistlib
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parent.parent
PHONE_ID = "com.dziachenka.padelscore"
WATCH_ID = PHONE_ID + ".watchkitapp"


def validate_source(project=None):
    project = project or ROOT / "App/PadelScore.xcodeproj/project.pbxproj"
    objects = json.loads(subprocess.check_output(["plutil", "-convert", "json", "-o", "-", str(project)]))["objects"]
    targets = {v["name"]: (k, v) for k, v in objects.items() if v["isa"] == "PBXNativeTarget"}
    phone_id, phone = targets["PadelScore"]
    host_id, host = targets["PadelScorePhoneStoreKitHost"]
    ui_id, ui = targets["PadelScorePhoneUITests"]
    unit_id, unit = targets["PadelScorePhoneTests"]
    require(phone["productType"] == "com.apple.product-type.application", "phone target is still a stub")
    attributes = next(v for v in objects.values() if v["isa"] == "PBXProject")["attributes"]["TargetAttributes"]
    require(attributes[ui_id]["TestTargetID"] == phone_id, "UI tests target the wrong application")
    require(attributes[unit_id]["TestTargetID"] == host_id, "StoreKit unit tests lack their isolated host")

    def sources(target):
        return Counter(objects[objects[f]["fileRef"]]["path"] for p in target["buildPhases"]
                       if objects[p]["isa"] == "PBXSourcesBuildPhase" for f in objects[p]["files"])

    expected = sources(phone)
    expected.subtract({"PadelScorePhone/PadelScorePhoneApp.swift": 1})
    expected.update({"PadelScorePhoneStoreKitHost/PhoneStoreKitTestApp.swift": 1})
    require(sources(host) == +expected, "phone test host must share production sources, replacing only its entry point")

    def settings(target):
        return {objects[c]["name"]: objects[c]["buildSettings"]
                for c in objects[target["buildConfigurationList"]]["buildConfigurations"]}

    for name, config in settings(phone).items():
        require(config["PRODUCT_BUNDLE_IDENTIFIER"] == PHONE_ID, "iPhone identifier changed")
        require(config["IPHONEOS_DEPLOYMENT_TARGET"] == "17.0", "minimum iOS must stay 17")
        require(config["TARGETED_DEVICE_FAMILY"] == "1", "phone target must remain iPhone")
        expected_settings = config.copy()
        expected_settings.update({"PRODUCT_BUNDLE_IDENTIFIER": PHONE_ID + ".phone-storekit-host",
                                  "SKIP_INSTALL": "YES", "INFOPLIST_KEY_CFBundleDisplayName": "StoreKit Test Host",
                                  "ASSETCATALOG_COMPILER_APPICON_NAME": ""})
        require(settings(host)[name] == expected_settings, "phone test host settings drifted beyond test-only identity")

    def dependencies(identity, seen=None):
        seen = set() if seen is None else seen
        if identity in seen:
            return seen
        seen.add(identity)
        for dependency in objects[identity].get("dependencies", []):
            child = objects[dependency].get("target")
            if child:
                dependencies(child, seen)
        return seen

    require(not {host_id, unit_id, ui_id} & dependencies(phone_id), "shipping app depends on phone test targets")
    return True


def require(condition, message):
    if not condition:
        raise ValueError(message)


def info(app):
    return plistlib.loads((app / "Info.plist").read_bytes())


def executable(app, data):
    name = data.get("CFBundleExecutable", "")
    require(bool(name) and Path(name).name == name, "missing or invalid executable name")
    require((app / name).is_file() and (app / name).stat().st_size > 0, "application executable is missing")


def validate_watch(app, run_launcher=True):
    data = info(app)
    require(data.get("CFBundleIdentifier") == WATCH_ID, "Watch bundle ID changed")
    require(data.get("WKWatchOnly", False) is False, "Watch still declares Watch-only packaging")
    require(data.get("WKCompanionAppBundleIdentifier") == PHONE_ID, "wrong companion bundle ID")
    require(data.get("WKRunsIndependentlyOfCompanionApp") is True, "Watch requires iPhone installation")
    require(data.get("WKApplication") is True, "not a modern Watch app")
    require(data.get("CFBundlePackageType") == "APPL", "Watch package type is invalid")
    executable(app, data)
    if run_launcher:
        subprocess.run(["python3", str(ROOT / "Scripts/verify-launcher.py"), "--built-app", str(app)], check=True)
    return data


def validate_phone(app, run_launcher=True):
    data = info(app)
    require(data.get("CFBundleIdentifier") == PHONE_ID, "iOS bundle ID changed")
    require(not data.get("ITSWatchOnlyContainer", False), "iOS product is still a Watch stub")
    require(not data.get("LSApplicationLaunchProhibited", False), "iPhone app cannot launch")
    require(data.get("CFBundlePackageType") == "APPL", "iOS package type is invalid")
    require(data.get("UIDeviceFamily") == [1], "companion must target iPhone")
    executable(app, data)
    watches = list((app / "Watch").glob("*.app"))
    require(len(watches) == 1, "iOS app must embed exactly one Watch application")
    watch = validate_watch(watches[0], run_launcher=run_launcher)
    for key in ("CFBundleVersion", "CFBundleShortVersionString"):
        require(bool(data.get(key)) and data[key] == watch.get(key), f"iOS/Watch {key} mismatch")
    forbidden = [p for p in app.rglob("*") if p.suffix in (".xctest", ".storekit") or "StoreKitHost" in p.name]
    require(not forbidden, "test host, local StoreKit config or test bundle leaked into distribution")
    return data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--watch-app", type=Path)
    group.add_argument("--phone-app", type=Path)
    group.add_argument("--source", action="store_true")
    args = parser.parse_args()
    try:
        if args.source:
            validate_source()
            print("Companion source graph: iPhone identity, test host parity and UI target verified")
            return
        data = validate_phone(args.phone_app) if args.phone_app else validate_watch(args.watch_app)
    except (OSError, ValueError, plistlib.InvalidFileException, subprocess.CalledProcessError) as error:
        raise SystemExit("Companion packaging: " + str(error)) from error
    print(f"Companion packaging verified: {data['CFBundleIdentifier']} {data.get('CFBundleShortVersionString')} ({data.get('CFBundleVersion')})")


if __name__ == "__main__":
    main()
