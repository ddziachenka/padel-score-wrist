# Danish banner correction proof

Candidate: `8dd50d72b04689da93bfaed2599eb28bd26e3591`.
Catalog SHA-256: `d0ad1247309f02aa8e20aa967eddf38759324fd18398456e2bc3af061917cbd3`.

The final context audit found object-form OS/DEM used as sentence subjects. The Danish language agent confirmed the grammar issue read-only. Coordinator changed exactly four Danish values; short scoreboard labels remain OS/DEM. No model or rule changes.

Compiled with `xcrun xcstringstool compile App/PadelScoreWatch/Localizable.xcstrings --output-directory /private/tmp/padel-danish-final-catalogs` (exit 0). A small Foundation `Bundle.localizedString(forKey:value:table:)` probe compiled with `xcrun swiftc /private/tmp/padel-danish-banner-probe.swift -o /private/tmp/padel-danish-banner-probe` (exit 0), then executed `/private/tmp/padel-danish-banner-probe /private/tmp/padel-danish-final-catalogs` (exit 0):

```text
US won: Vi vandt
THEM won: De vandt
US ahead: Vi er foran
THEM ahead: De er foran
```

Coordinator re-read each sentence against its score/result meaning. All twelve numeric proof files were regenerated from the same compiled catalog, 22 lines per locale, preserving the previous grammatical outputs. `make static` exit 0 before candidate commit. Exact integration passed: exit 0, 510/510 definitions, 884 invocations, 0 failed/skipped/expected; `integration-final.md`. Fresh Danish creation test passed, all three original frames individually inspected: Match result, round result with readable `Vi vandt`, and empty new-game state. Corrected sentence and short OS/DEM labels are consistent. No image text or pixels edited.

## Fresh original attachments

Export command (exit 0): `xcrun xcresulttool export attachments --test-id 'StoreMaterialsUITests/testLocalizeddaCreation()' --path .artifacts/integration/20261023T161643Z-52611/integration.xcresult --output-path .artifacts/integration/20261023T161643Z-52611/danish-correction-attachments`.

- `l10n-da-data-deleted_0_BFFACCE4-200D-44AA-8F6C-B7EBB16F4923.png` — source `8dd50d72b04689da93bfaed2599eb28bd26e3591`, timestamp `1792775786.733`, file `.artifacts/integration/20261023T161643Z-52611/danish-correction-attachments/3CD373FC-2B4B-41E4-BC4E-18BCEB9C3357.png`, SHA-256 `2be02d6054e7a8ac4c1b6335dfa2c4d328a8efb52701462be7c0c697840e6331`.
- `l10n-da-created-round-finished_0_ECC16314-223B-491C-8EA8-F1427298FF66.png` — source `8dd50d72b04689da93bfaed2599eb28bd26e3591`, timestamp `1792775748.175`, file `.artifacts/integration/20261023T161643Z-52611/danish-correction-attachments/5C18A7BC-F102-401D-B813-616B6C51BF9B.png`, SHA-256 `57ae83c22934604e5bdbf9bf22300628e11f89a2cde673725f0695224b30eccb`.
- `l10n-da-created-match-finished_0_531410AE-3920-4F76-94AE-7A855A639227.png` — source `8dd50d72b04689da93bfaed2599eb28bd26e3591`, timestamp `1792775682.988`, file `.artifacts/integration/20261023T161643Z-52611/danish-correction-attachments/7B680E11-E029-4386-B6E6-C507E51D2177.png`, SHA-256 `0b8a00122eb2577e9fe46e339034983e3428825a8d672329ad8e1d693cfd0c62`.
