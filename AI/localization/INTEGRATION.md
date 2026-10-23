# Multilingual integration — in progress

Base: `809aa64036c4027d7aba141e889e90d97669e9e6`.
First combined source: `ec49b053b17a5bfe15863c18a8f8b9c897d08b84`.

Scope: 11 new languages, 12 added locales, 13 total locales. 330 Watch + 4 launcher keys per added locale (4,008 added entries), including the 31 offline About strings discovered during extraction. Four pages per locale; 13 App Store draft variants because Spanish has Spain and Mexico. Nothing is published or uploaded.

## Language inputs

| Locale | Language commit | Worktree |
| --- | --- | --- |
| es | `a3b6161e7b05a2391aaa86b7584a64dd316a5537` | `/private/tmp/padel-l10n-es` |
| it | `d87c2c08d8046c2941af4dc7f355748ffbfb278a` | `/private/tmp/padel-l10n-it` |
| fr | `1dcf9fe8eacf21af80ecece67ca3823f0a529345` | `/private/tmp/padel-l10n-fr` |
| pt-PT | `f32092741356f46c29337a4fdc39b232bdccadc3` | `/private/tmp/padel-l10n-pt-pt` |
| pt-BR | `75a839a04c30e716480db419d397e21bed42c2b5` | `/private/tmp/padel-l10n-pt-br` |
| nl | `fa49af8c0cc903273258c4710ccc7c7b05213bb5` | `/private/tmp/padel-l10n-nl` |
| de | `b0c2e312231fd57507998ea6e64c7ad445984a15` | `/private/tmp/padel-l10n-de` |
| sv | `ae20e0790b93401fd58bc654d9cfbbc82ec35930` | `/private/tmp/padel-l10n-sv` |
| da | `7e3da467c1b2fa7cee4fe287f50b8032504a3d39` | `/private/tmp/padel-l10n-da` |
| fi | `c3cb82c24b4911c513d697ae0a15b482ae72ef64` | `/private/tmp/padel-l10n-fi` |
| nb | `3121bc4973a7766b69a82e36332571502c466fbc` | `/private/tmp/padel-l10n-nb` |
| ru | `d7e7eacaa42595ee79f88f42fdb51f662c386b73` | `/private/tmp/padel-l10n-ru` |

Catalogs were combined structurally, preserving every language and English source values. Locale-only files were copied from their recorded commits. Original language branches are retained. Coordinator corrections are in the main checkout after fan-in.

## Editorial review

The coordinator read every catalog value and plural variant, all four pages, all store fields and launcher labels for every locale. Reviewed readability before comparison with source meaning. Individual glossaries and correction examples are in each locale’s `review.md`. Numeric proof for both pluralized messages is in `plural-review.txt`, generated from compiled catalogs using `Scripts/probe-localized-plurals.swift`.

This is the coordinator’s own editorial audit, not independent review or certification by an invited native speaker. UI labels, VoiceOver sentences, scoring rules, the five-completed-game limit, lifetime access, data deletion and privacy claims were checked separately. Final shared runtime evidence must still pass before translation completion is recorded.

## Baseline validation

`make fast` on `809aa64036c4027d7aba141e889e90d97669e9e6`: exit 0, 472 passed, 0 failed, 0 skipped, 0 expected failures. Report: `.artifacts/fast/20261023T082819Z-88791/report.md`; bundle: `fast.xcresult` in that directory. Command log: `/private/tmp/padel-localization-baseline-fast-clean.log`.

The first attempt failed packaging because this checkout’s reused DerivedData still contained test hosts from an earlier test run (`.artifacts/fast/20261023T082651Z-84768/build.log`). Cleaning only the checkout-owned DerivedData resolved it; the unchanged exact baseline then passed. No test or packaging check was weakened.

## Capture and targeted evidence

Capture source: `615a98d7e5d549bd4574f07537b3eefb50c14d69`.
`AI/localization/evidence/capture-command.txt` records UDID-targeted `xcodebuild test` through the managed lease wrapper, with all 12 `testLocalized<locale>Screens` selectors plus `testCaptureSixStoreScreens`. Exit 0; 13 passed, 0 failed, 0 skipped. Summary: `AI/localization/evidence/captures-summary.json`. The only capture-checkout configuration delta is the recorded 40→44-mm device type; manifests preserve source SHA, device, fixture/action, raw exported attachment, timestamp and SHA-256.

72 new localized PNGs and six refreshed English PNGs are stored under `AI/store-assets`; site copies are byte-identical. No image text was composited or edited. English was refreshed because the common result header changed. `Scripts/verify-store-materials.py` validates all 78 images and linked alt text. See `runtime-findings.md` for failed attempts and corrections; none was omitted from the findings.

Russian creation and installed resources on the capture source passed the targeted 40-mm recheck: 6 test definitions / 17 invocations, zero failures/skips. German and Russian largest-text journeys passed earlier targeted checks. The final exact integration gate still covers all locales and all original tests.

## Validation still in progress

- Each language stream: exact `make static` and `make fast`; build queue owns isolated simulators.
- 72 raw 44-mm XCTest screenshots; capture checkout changes only the managed device type from 40 to 44 mm. Capture source SHA and configuration delta must be recorded in manifests.
- Final 40-mm shared test scheme: all languages, largest text, creation, scoring/Undo, correction, finish, replay/history, legal links, restore, save error and deletion.
- Final `make integration CANDIDATE=<full-SHA>` after assets and corrections, with zero failed/skipped tests.

## Release boundary

M10 remains BLOCKED. Real-Watch spoken VoiceOver, on-court use, Always On/Low Power, oldest-device performance, adverse-network StoreKit and the launcher still need hardware evidence. No release readiness, M10 completion, App Store upload, site publication or App Review submission is claimed. `make milestone ID=M10` and `make release` require the hardware audit on one final candidate; they have not been run for this localization integration.
