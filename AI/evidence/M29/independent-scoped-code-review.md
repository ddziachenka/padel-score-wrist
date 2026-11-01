# M29 independent scoped code review

Date: 2026-11-01. Policy: `solo-workflow/2`.

## Identity and scope

- Baseline: `d92b9e9e9250e309a074953faa10ed4c06eddffb`.
- Reviewed committed candidate: `1367217b30ce0c5ffa2c464ea977786e28139439`.
- Initial source review used `445859bde0740737ccd580ca0fb95dba429fb534` plus
  the pending `StoreMaterialsUITests.swift` timing/assertion correction. The
  candidate above commits that correction; the only intervening files were that
  test and its evidence note. The checkout was clean at the final identity check.
- Separate delegated reviewer, with no implementation authorship. Read-only
  source review; only this report was written. No UI, simulator, hardware,
  build/test execution, Git mutation, or external operation was performed.
- Read the operating contract, workflow, project status, M29 milestone,
  approved gesture plan, and relevant architecture contract. Applied the
  `engineering:code-review` skill.

## Result

**No actionable findings in the reviewed implementation and test diff.**

The bounded review covered the five-second prototype, the first-recognition cue,
practice navigation, localization, and their regression tests:

- `GestureInput.window` is five seconds. The first activation fixes the deadline;
  a second activation changes US to THEM without extending it; a third cancels.
  At/after the deadline, activation clears the expired input rather than
  reinterpreting it. `takeDue` consumes at most once.
- Live scoring still binds the pending input to the game ID and session revision,
  checks the expected timer identity, and uses the ordinary award/save path.
  Navigation, inactive/reduced-luminance state, editing, and other actions retain
  their cancellation guards. The longer interval introduces no additional timer,
  persistence, permission, motion-data, or network path.
- Setup opens practice through `NewGameFlow.path`, matching both the standalone
  and result-origin navigation stacks. The draft stays in setup; practice owns
  in-memory scores and does not mutate a real match.
- The cue reaches Watch teaching/practice/accessibility and the phone simulation.
  Native shortcut availability, minimum touch target, disabled state, and
  supported-device/awake-screen guidance remain intact.
- Tests preserve the boundary and negative assertions: second activations after
  the old three-second limit, fixed deadline, exact expiry, cancellation, stale
  timer/revision protection, isolation from real scores, and both result-origin
  setup routes. Post-deadline waits moved to the approved five-second contract.
  The gallery correction adds pending-preview and unavailable-Undo assertions
  before waiting, then requires an undoable committed point.

## Read-only checks

- `git diff --check d92b9e9e9250e309a074953faa10ed4c06eddffb HEAD`:
  exit 0 at the reviewed candidate.
- Python JSON consistency check of both `Localizable.xcstrings` catalogs:
  exit 0; all 13 locales have matching cue/rule/pending coverage, each cue quotes
  its locale's exact `Pending: US` value, and the changed gesture strings match
  between Watch and phone.
- Source search found the remaining 3.2-second UI waits in the two intentional
  pre-expiry assertions, which then continue through the five-second deadline.

No result bundles were produced by this review; test definitions/invocations
rerun by this reviewer: 0/0. Builder-reported native results were not represented
as an independent rerun.

## Limits

This is an independent **scoped source review**, not the workflow's complete
Reviewer validation, M29 milestone verification, physical-device evidence, or
release approval. It does not establish real gesture recognition accuracy,
haptics, wrist-down behavior, battery/play endurance, StoreKit behavior, or the
visual quality of every localized screen. The Builder still owns exact-candidate
validation, evidence, handoff, and any authorized acceptance decisions.

## Subsequent bounded preparation review

The canonical [owner acceptance](owner-physical-acceptance.md) and current
WORKFLOW/gesture-plan/M29 manual amendment were reviewed. They consistently
accept all manual physical inventory rows by the owner's decision while preserving
unrecorded percentages, attempts, elapsed hour/zero-event counts, continuous video
and independent Watch6 readback as unrecorded. No automatic verification, material
provenance or release/submission requirement is waived. This does not turn source
review into measured physical-device evidence.

The baseline `d92b9e9e9250e309a074953faa10ed4c06eddffb` to frozen candidate
`1367217b30ce0c5ffa2c464ea977786e28139439` source/test and approved-document
changes were rechecked for missed scope. Additional read-only assertions exited0:
all26 localized landing/support diffs are exactly their approved feature-paragraph
replacement with headings/recovery unchanged, and the project.pbxproj diff is
exclusively exact build3-to6 replacements. Composer tuple localization joins the
same approved rule/cue strings within unchanged boxes/minimum typography.
The separate material-copy review already records all13 cross-platform translation
sets and14 metadata descriptions/budgets. No new P0/P1 finding was identified.

Config/release-requirements.v3.tsv REL-1302 still has historical three-second
prose at the frozen candidate. The approved product contract is five seconds;
the Builder has queued the corresponding requirement-prose correction after both
frozen gallery captures. It is not an authorization or implementation defect.
Fresh native materials and the full automatic gate remain pending; no existing
failure is relabelled. No simulator, test, build, Git or external action was taken.
