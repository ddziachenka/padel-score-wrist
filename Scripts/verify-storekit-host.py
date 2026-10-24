#!/usr/bin/env python3
"""Reject drift between the local StoreKit host and the shipping Watch sources."""
from collections import Counter
import json
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / "App/PadelScore.xcodeproj"
objects = json.loads(subprocess.check_output([
    "/usr/bin/plutil", "-convert", "json", "-o", "-", str(PROJECT / "project.pbxproj")
]))["objects"]
targets = {v["name"]: (k, v) for k, v in objects.items() if v["isa"] == "PBXNativeTarget"}
shipping_id, shipping = targets["PadelScoreWatch"]
host_id, host = targets["PadelScoreStoreKitHost"]
tests_id, tests = targets["PadelScoreStoreKitTests"]


def require(condition, message):
    if not condition:
        raise SystemExit("StoreKit test host: " + message)


def members(target, kind):
    return Counter(objects[f]["fileRef"] for p in target["buildPhases"]
                   if objects[p]["isa"] == kind for f in objects[p]["files"])


# Only @main is replaced: it must not create a second entitlement owner or
# call StoreKit before the test session exists. All production behavior is shared.
expected_sources = members(shipping, "PBXSourcesBuildPhase")
expected_sources.subtract({"6F00D188ECAA809FBCE9F612": 1})
expected_sources.update({"A039DCC85BE50368425A1D003": 1})
require(members(host, "PBXSourcesBuildPhase") == +expected_sources,
        "PBXSourcesBuildPhase may replace only the shipping @main entry point")
for kind in ("PBXResourcesBuildPhase", "PBXFrameworksBuildPhase"):
    require(members(host, kind) == members(shipping, kind),
            f"{kind} must contain exactly the shipping target's files")


def settings(target):
    return {objects[c]["name"]: objects[c]["buildSettings"]
            for c in objects[target["buildConfigurationList"]]["buildConfigurations"]}


shipping_settings, host_settings = settings(shipping), settings(host)
require(shipping_settings.keys() == host_settings.keys(), "configuration sets differ")
for name, actual in host_settings.items():
    expected = shipping_settings[name].copy()
    require(expected["PRODUCT_BUNDLE_IDENTIFIER"].endswith(".watchkitapp"),
            "shipping Watch identifier must retain its standard suffix")
    expected["PRODUCT_BUNDLE_IDENTIFIER"] = expected["PRODUCT_BUNDLE_IDENTIFIER"].removesuffix(".watchkitapp")
    expected["INFOPLIST_KEY_CFBundleDisplayName"] = "StoreKit Test Host"
    # The test-only Watch host is independently installable in the canonical container
    # namespace. Production now embeds an independent Watch counterpart in a real iOS app.
    if expected.pop("INFOPLIST_KEY_WKCompanionAppBundleIdentifier", None):
        expected.pop("INFOPLIST_KEY_WKRunsIndependentlyOfCompanionApp", None)
        expected["INFOPLIST_KEY_WKWatchOnly"] = "YES"
    require(actual == expected, f"{name} settings may differ only in test-host identity/name")
    require(actual["SKIP_INSTALL"] == "YES", "test host must not be installed by an archive")

scheme = ET.parse(PROJECT / "xcshareddata/xcschemes/PadelScore.xcscheme").getroot()
entries = scheme.findall("./BuildAction/BuildActionEntries/BuildActionEntry")
for identity in (host_id, tests_id):
    matching = [e for e in entries if e.find("BuildableReference").get("BlueprintIdentifier") == identity]
    require(len(matching) == 1, "test-only target must appear once in the scheme")
    entry = matching[0]
    require(entry.get("buildForTesting") == "YES", "test target is not enabled")
    for action in ("Running", "Profiling", "Archiving", "Analyzing"):
        require(entry.get("buildFor" + action) == "NO", f"test host included in {action}")


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


for name in ("PadelScore", "PadelScoreWatch"):
    require(not {host_id, tests_id} & dependencies(targets[name][0]),
            "shipping build must not depend on local testing targets")
plan = json.loads((ROOT / "App/PadelScore.xctestplan").read_text())
require(plan["defaultOptions"]["targetForVariableExpansion"]["identifier"] == host_id,
        "local StoreKit plan must configure the canonical container namespace")
require(any(t["target"]["identifier"] == tests_id and t.get("parallelizable") is False
            for t in plan["testTargets"]), "StoreKit tests must run serially in the shared plan")
print("StoreKit test host: shipping-source parity and archive isolation verified")
