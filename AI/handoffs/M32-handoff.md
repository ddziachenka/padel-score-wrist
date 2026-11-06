# Milestone handoff

**Policy status:** current

## Milestone

`M32` — Next serve side; status `DONE`.

## Summary

Match and Americano show the next serving side beside the server. Ordinary games
start right, deuce is right, advantage left; both deciding-point rules show L/R
and receivers’ choice. Tie-breaks use point parity. Americano starts each server's
block right and uses the saved rallyInBlock after corrections. Finished and
unconfirmed-set states hide the hint. No extra input, stored field or migration.
Watch live/demo/recovery and iPhone demo/recovery agree. All thirteen app locales
have full spoken side names and viewpoint/Americano help; L/R stays literal.

The owner-withdrawn build 7 is recorded as DEVELOPER_REJECTED, submission COMPLETE,
IAP READY_TO_SUBMIT. The existing hourly monitor has a priority read-only hold and
cannot start the withdrawn build's promotion. No resubmission occurred.

## Changed files

- MatchState/ScoreBoard — pure derived ServeSide and presentation visibility.
- Watch score, serving block, gesture actions, announcements, demos and journal —
  readable name/side with existing layout fallback and full accessible speech.
- Phone demo/recovery/help and both localization catalogs — equivalent hints,
  server accessibility value and translated explanations.
- Domain/store/speech/UI tests — scoring boundaries, replay/correction, saving,
  long names, compact Watch, maximum text, Always On and both phone appearances.
- Product/design/workflow/status/M32/M33 contracts and M32 evidence — approved scope,
  actual failures/corrections and separate release-readiness ownership.
- Store captures, compositions, provenance and local site copies — fresh corrected-
  source materials required by the unchanged shipping-fingerprint guard.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `793268631ce273284b8bbd67b1dc0179ae9fe3f5`, clean REVIEW/main |
| Exact command | `make milestone ID=M32` |
| Exit code | 0 (Make/verifier; both Debug builds and all three native suites also 0) |
| Timestamp | 2026-11-06T14:56:22Z–2026-11-06T21:20:58Z |
| Report | `.artifacts/milestone/M32/20261106T145621Z-96942/report.md`; [durable evidence](../evidence/M32/milestone-verification.md) |
| Counts | Watch 650/650 definitions/1104 invocations; phone unit 21/21/30; phone UI 22/22/22. Aggregate 693/693 definitions/1156 invocations, all Passed, zero failed/skipped/expected/native runtime warnings. Two Debug builds and both packaging guards pass. |

The full command ran unchanged, with fresh suites and no verification exception,
component reuse or filters. Native exporter exit 0; exact summaries/trees/counts
in `.artifacts/M32/full-native-counts/`. Post-DONE static/status/continuity results
are recorded after execution in the durable evidence; no pending check is called a pass.

## Tests

Coverage includes the ordinary score table, repeated deuce/advantage, both golden
point rules, tie-break serving and game/set boundaries; Americano blocks 1/3/4,
shortened final block, corrected position and changed block length; Undo,
selective replay, known score, restart, Finish/Resume and failed saves.

Builder self-review corrected two actual findings: long custom names could hide
the trailing side (strict UI test failed before/passed after), and the phone
recovery one-letter accessibility element failed native text-clipping audits.
Full side speech now belongs to the server's accessibility value. The unchanged
six-category audit passes both themes in the full gate and verifies pending/right/
Undo-left speech. Earlier failed/interrupted full runs remain failed.
[Exact development evidence and visual contacts](../evidence/M32/development.md).

Final galleries use 424a7e2019d4d033e92866ab00819f94d477bc86: Watch 14/14 and phone 2/2,
zero adverse results; same shipping inputs at the verified candidate. Strict
import/composition/provenance/site checks pass for 112 Watch+98 phone originals,
28 creatives, 14 Store locales and 104 local web copies. These remain local materials.

## Known issues

No known blocking M32 issue. Fresh physical VoiceOver/readability acceptance belongs
to M33 before release readiness; Simulator evidence does not claim it. Previous
App Review 4.3(a) is not guaranteed to be resolved by this feature. Build identity
is still 1.0(7); no new candidate was uploaded. No public site deployment.
Builder self-review is not independent audit or release approval.

## Next step

Complete the required post-DONE static/status/continuity checks and stop this
Builder session. A new Builder session owns `M33`: affected materials and Release
Readiness Revalidation, with its full milestone and exact-SHA release gates.
App Review resubmission requires a separate explicit instruction.
