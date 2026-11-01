# M29 physical validation — owner-accepted manual scope

Started 2026-11-01. Historical Builder observations and owner reports are retained
below; they do not constitute an independent audit or release approval.

## Current manual acceptance and automatic-gate status

All manual physical inventory rows are **OWNER_ACCEPTED_BY_DECISION**, following
the owner's explicit “все засчитываем” clarification. The canonical
[decision and full question/answer](owner-physical-acceptance.md) cover gestures/
play and the remaining VoiceOver, native-name, storage/recovery, Sandbox purchase/
Restore/revocation and other manual scenarios. No repeat manual tests are requested.

Exact per-team denominators, recognition percentages, elapsed play hour/zero-event
counts and real Watch video were not recorded/supplied. Watch6 About was not
independently read back. Acceptance does not manufacture those facts or convert
them to measured passes; they are disclosures, not renewed manual blockers.

M29 remains IN_PROGRESS. The full unchanged `make milestone ID=M29` has not run:
final frozen material captures and domain records are being prepared before a
clean REVIEW/main candidate. No M25 exception is inherited; no full-gate pass,
independent audit or release/submission/distribution approval is claimed.

## Historical observation log

The owner initially selected testing together and then instructed the agent to
use iPhone Mirroring wherever possible, involving the owner only where physical
action is necessary. Earlier pending/blocked requests below describe their time
in this log and are superseded for manual acceptance by the current decision.

## Candidate and environment

- Session baseline: `d92b9e9e9250e309a074953faa10ed4c06eddffb` on clean `main`.
- `git diff --stat 5eb65bbc17e9540d3922a520b44d3c8731947432 HEAD -- App Config Scripts`
  exited 0 with no output: shipping/verification inputs match the M25 candidate.
- iPhone 17 Pro Max, iOS 27.0.1 (24A446), connected by USB.
- Apple Watch Ultra 3, watchOS 27.0.1 (24R365), paired; direct CoreDevice tunnel
  unavailable. Device discovery is not proof of installed Watch build or a test.
- Inventory and details: `.artifacts/M29/devices-initial.json`,
  `iphone-details-initial.json`, `watch-details-initial.json`.
- iPhone initially had 1.0 (2). Updated in place to locally development-signed
  Release 1.0 (3), with no uninstall or erase. Confirmed via CoreDevice app listing
  and launched successfully. This is local installation, not TestFlight/upload.

## Commands and outcomes

| Command | Exit | Evidence / meaning |
| --- | --- | --- |
| `xcrun devicectl list devices --timeout 20` (sandbox) | 1 | CoreDeviceService initialization timeout; no device test executed |
| `xcrun devicectl list devices --filter "Reality = 'physical'" --timeout 20 --json-output .artifacts/M29/devices-initial.json` (outside sandbox) | 0 | Physical phone and paired Watch discovered |
| `xcrun devicectl device info details --device 00008310-000823642660E01E --timeout 25 --json-output .artifacts/M29/watch-details-initial.json` | 0 | Partial cached Watch information with network warning; not a successful live connection |
| `xcodebuild -project App/PadelScore.xcodeproj -scheme PadelScorePhone -configuration Release -destination 'generic/platform=iOS' -derivedDataPath .artifacts/M29/device-derived-data DEVELOPMENT_TEAM=WW8JPY8B94 CODE_SIGN_STYLE=Automatic build` | 0 | `.artifacts/M29/device-build.log`, BUILD SUCCEEDED; phone plus embedded Watch and launcher |
| `xcrun devicectl device install app --device 00008150-000104A10284401C --timeout 90 --json-output .artifacts/M29/iphone-install.json .artifacts/M29/device-derived-data/Build/Products/Release-iphoneos/PadelScore.app` | 0 | `.artifacts/M29/iphone-install.log`; data-preserving phone update |
| `xcrun devicectl device info apps --device 00008150-000104A10284401C --filter "bundleIdentifier CONTAINS 'padelscore'" --timeout 20 --json-output .artifacts/M29/iphone-apps-after.json` | 0 | Phone version 1.0, build 3 |
| `xcrun devicectl device process launch --device 00008150-000104A10284401C --timeout 20 --json-output .artifacts/M29/iphone-launch.json com.dziachenka.padelscore` | 0 | Actual companion opened through iPhone Mirroring |
| `xcrun devicectl device info apps --device 00008310-000823642660E01E --filter "bundleIdentifier CONTAINS 'padelscore'" --timeout 20 --json-output .artifacts/M29/watch-apps-before.json` | 1 | Bluetooth L2CAP open channel failed; no installed Watch version established |
| `xcrun devicectl device install app --device 00008310-000823642660E01E --timeout 30 --json-output .artifacts/M29/watch-install-direct.json .artifacts/M29/device-derived-data/Build/Products/Release-watchos/PadelScoreWatch.app` | 1 | Same Bluetooth tunnel error; `.artifacts/M29/watch-install-direct.log`; no successful Watch update claimed |

The build and connection commands run no tests; xcresult counts are inapplicable.
At this historical checkpoint, the full gate had not run because manual coverage
was incomplete. That blocker is superseded by the current owner decision above;
the unchanged full gate now awaits final material/domain preparation.

## Agent-observed phone checks

Current Release build through iPhone Mirroring, English, ordinary text, Light:

- Start renders the Watch requirement, primary demo, centered recovery links and
  persistent Start/Demo/Access navigation. Capture `phone-start-light.png`.
- Gesture guide explicitly labels simulation, describes one/two/third series,
  three-second save, opt-in and supported-Watch restrictions.
- One simulated activation shows Pending: US with unchanged 0:0, then settles
  to 1:0 with no remaining preview. Capture `phone-gesture-one-settled.png`.
- Two simulated activations show Pending: THEM with unchanged 1:0, then settle
  to 1:1. Capture `phone-gesture-two-settled.png`.
- Three successive simulated activations cancel the preview, leaving 1:1.
  A later single activation followed immediately by Home and subsequent reopen
  also leaves 1:1 with no delayed award. Capture `phone-gesture-background.png`.

## Watch installation follow-up

Owner initially observed About 1.0 (1), with no gesture feature. Therefore no
current-Watch behavior was inferred from that old installation. Direct connection
still failed. In the physical phone's Watch app, search for Padel → Apps showed
Padel Score under Available Apps. Agent selected INSTALL without uninstalling or
deleting anything. Progress completed: Padel Score moved into installed Apps,
and its detail shows Show App on Apple Watch ON. Captures
`watch-install-via-phone.png` (progress) and `watch-installed-via-phone.png` (ON).
Final current Watch build confirmation and gesture checks remain pending.

Owner then confirmed Watch About **1.0 (3)** and that Gesture scoring appeared.
This confirms the paired-phone installation reached the physical Watch.

## Gesture recognition investigation — contact terminology resolved

Owner's first qualitative observation: gestures appear to work only after
tapping Serving, which displays the hourglass. No exact attempt denominators or
per-team successful-command outcomes were supplied, so the recognition criteria
are not credited as passed. The physical meaning remains under investigation:
the Serving control itself intentionally starts the same three-second proposal;
its timer can award a point even with no native gesture.

Agent checked the actual paired Watch app's Gestures settings through iPhone
Mirroring: Gestures ON, Tap Gestures ON, Ignore Tap Gestures (Vision Pro) OFF.
No system gesture setting was changed. Capture `watch-system-tap-gestures-on.png`.
Apple Watch Mirroring in phone Accessibility was briefly enabled to attempt
agent-operated Watch inspection; no Watch video/control surface appeared. It was
restored to its original OFF state before owner recognition trials.

Requested discriminating observations: Serving tap with no subsequent gesture;
then one native series after wake without touching the screen, including the
system Double Tap icon's behavior. No speculative app fix or product change made.

Owner subsequently confirmed that tapping Serving alone awards US after the
timer, and that a gesture after this tap can change the proposal to THEM. Owner
also observed one finger contact highlights Serving, while two contacts award US.
On explicit clarification, “two taps” meant **two total finger contacts**, not
two Double Tap series. This is the expected one-series US command. The initial
observation does not establish an application defect; no source change was made.
Repeated per-team recognition, cancellation counts, wrist/racket hand, haptics,
one-hour play and video are still pending. Planned numeric trials have been sent
to the owner: 40 US, 40 THEM, 10 cancellations; actual denominators will be used.

Owner's next observation: two, three and four total finger contacts all award US.
This does not pass the two-series THEM requirement. Exact denominators were not
reported. A bounded differential test is pending: two quick contacts, approximately
0.7 seconds pause, two quick contacts, first in visible Watch practice and then
live scoring, observing whether the proposal changes US → THEM. This separates
native event delivery/recognizer grouping from the app's ordinary input reducer.
No claim that this is fixed, a platform limitation, or a pre-existing failure.
Owner explicitly states the one-hour test will happen **later**; only short trials
are available now. M29 therefore cannot reach DONE in the present coverage state.

Primary-source API check: Apple's
[Double Tap integration guide](https://developer.apple.com/documentation/watchos-apps/enabling-double-tap)
and [handGestureShortcut contract](https://developer.apple.com/documentation/swiftui/view/handgestureshortcut(_:isenabled:)).
Only one primary action per scene is permitted; visible control activation should
be equivalent to direct interaction. The physical delivery/availability of that
action cannot be established by XCUITest tapping its button. Retrieved official
Markdown is retained under `.artifacts/M29/apple-*.md`.

## Additional agent-observed phone journeys

English, ordinary text, Light, actual installed Release 1.0 (3):

- Match: 40–30 / games 2–2 / server You → THEM gives Golden point 40–40;
  US completes the game, games 3–2, server Opponent 1; Undo restores Golden
  point and You; Reset restores 40–30 with Undo disabled.
- Americano: 10–10, four rallies remaining, Partner / first of two → US then
  THEM gives 11–11 and changes server to Opponent 2 / first of two → US then
  THEM ends at 12–12, Draw, no rallies remaining. Undo reopens 12–11 with one
  rally and Opponent 2 / second of two. Reset restores 10–10.
- Historical correction: original four winners US/THEM/US/THEM, points 0–15,
  games 3–2; changing the first winner to THEM previews points 15–15 and games
  2–3 while preserving the later three winners. Cancel preserves the original.
  Review again → Apply shows the exact preview; one Undo restores original score
  and all four original winners. Close returns to the reset Americano demo.
- Known-score Match: games 6–2 is rejected with explicit example-rules message;
  correcting to 1–2 produces a valid 40–30 / You preview and clears the problem.
  Start preserves that score, earlier rallies are unknown and Undo is disabled.
  US advances to games 2–2 / 0–0 / Opponent 1; Undo restores 1–2 / 40–30 / You
  and is disabled again at the starting boundary.
- Access initially has an existing verified lifetime. Restore enters its pending
  state and then displays “Purchase restored. Unlimited games are available.”
  No credentials were entered, fresh acquisition attempted, account switched,
  data erased or reinstall performed. This is an existing-install restore only;
  native purchase/price/currency, fresh-install restore and Sandbox adverse states
  remain unverified. The account environment is not shown in this UI.

Captures: `phone-match-complete.png`, `phone-americano-draw.png`,
`phone-correction-applied.png`, `phone-correction-undone.png`,
`phone-known-score-invalid.png`, `phone-known-score-undo-boundary.png`,
`phone-existing-verified-access.png`, `phone-restore-existing-success.png`.
All are raw current Mirroring captures under `.artifacts/M29/`. Runtime
observation is not an automated test count.

- Each Access link opened its actual public destination in the physical phone's
  default Chrome: Support, Privacy Policy and Terms of Use. All rendered usable
  text and the intended site. Captures `phone-support-destination.png`,
  `phone-privacy-destination.png`, `phone-terms-destination.png`. No external form
  was submitted and no legal agreement accepted.
- Actual Dark Mode was explicitly switched ON from the physical Control Center
  (original OFF). Start, Access, gesture guide and both demos display correct
  dark surfaces, legible text and unchanged actions. Leaving the gesture guide's
  tab reset its isolated score to 0:0. Captures `phone-*-dark*.png`.
- Original display preferences: Increase Contrast ON, Differentiate Without
  Colour ON, Bold Text OFF, Reduce Transparency OFF. Larger Accessibility Sizes
  OFF with the ordinary slider's middle/fourth tick. Reference captures
  `phone-original-display-preferences.png`, `phone-original-text-size.png`.
- Temporarily enabled Reduce Transparency and Larger Accessibility Sizes, dragged
  the actual text-size slider to its maximum, and inspected actual Dark output.
  Match uses stacked US/THEM, service wraps, completion/Undo remain reachable by
  scrolling; scoring then Undo restores 40–30, games 2–2. Start's heading and
  explanation wrap, but Mirroring wheel attempts did not advance its ScrollView;
  full largest-text Start traversal is not credited as a pass. Captures
  `phone-largest-text-setting.png`, `phone-largest-match-dark.png`,
  `phone-largest-start-dark.png`.

## Temporary setting restoration — complete after owner approval

Mirroring slider drags overshot when attempting restoration. Larger Accessibility
Sizes has been returned OFF. Read-only native query
`xcrun devicectl device info appearance --device 00008150-000104A10284401C --timeout 20 --json-output .artifacts/M29/phone-appearance-before-restore.json`
exited 0, showing the **post-test** current values: Dark, Extra Small, Reduce
Transparency ON, Increase Contrast ON, Reduce Motion OFF. This JSON is not the
owner's initial pre-test preferences.

The intended restore is Light, Large (original fourth/middle tick), Larger
Accessibility Sizes OFF, Reduce Transparency OFF, preserving Increase Contrast ON.
Its native `devicectl device settings appearance` invocation was rejected twice
by automatic approval review before execution. The first rejection treated the
post-test snapshot as original; the second required owner-provided confirmation
despite re-inspection of original screenshots. No command ran, no workaround was
used. Owner has been asked to approve these exact values or restore manually.
Dependent settings changes remain stopped until that answer arrives.

Owner explicitly approved the exact values: “Восстановить указанные настройки”.
The same command then ran and exited 0:
`xcrun devicectl device settings appearance --device 00008150-000104A10284401C --text-size large --larger-accessibility-sizes off --reduce-transparency off --mode light --timeout 20 --json-output .artifacts/M29/phone-appearance-restore.json`.
Readback `device info appearance` exited 0 and confirms Light, Large, larger
sizes OFF, transparency OFF, Increase Contrast ON, Reduce Motion OFF. Evidence:
`phone-appearance-restored-readback.json`, `phone-settings-restored.png`.
The earlier rejections remain part of the record; no bypass was used.

Temporary phone appearance/text settings are restored and confirmed.
No VoiceOver audio, physical Watch accessibility, Reduce Motion, fresh acquisition,
fresh-install restore, revocation or one-hour outcome has been verified yet.

`codesign --verify --deep --strict --verbose=2 .artifacts/M29/device-derived-data/Build/Products/Release-iphoneos/PadelScore.app`
first failed in the sandbox with CSSMERR_TP_NOT_TRUSTED (exit 1); the same command
outside the sandbox passed (exit 0), valid on disk and designated requirement.
Candidate source/input/executable hashes: `.artifacts/M29/candidate-identity.json`
(242 tracked App/Config/Scripts files).

These phone simulations do not count toward actual Watch recognition thresholds.
Capture paths above are under `.artifacts/M29/` and originate from the live
Mirroring window. No real Watch gesture video exists yet.

## Historical build 4 correction and paired installation

The setup practice navigation defect is reproduced and corrected at
`0d535ac26a543d37333f3c457bbfba1316663d90`; see
[before/after evidence](setup-practice-regression.md). The signed Release build
command above ran again with `.artifacts/M29/device-build-4.log`, exit 0. The
same phone install command with `iphone-install-build4.json` / `.log` exited 0;
native app readback `iphone-build4-readback.json` confirms phone **1.0 (4)**.
Source and both executable hashes are in `candidate-identity-build4.json`.
Embedded Watch app is also 1.0 (4), but this does not prove transfer to the Watch.

Owner subsequently reports Watch still **1.0 (3)**. Paired-phone Watch settings
showed the app installed with Show App on Apple Watch ON, without an explicit
update action. Owner explicitly authorized discarding application data because
the app is not released. Agent then turned Show App on Apple Watch OFF to remove
the old test installation and enable a fresh paired-phone install. Completion
and Watch build readback remain pending; no new physical behavior is credited.
This narrow authorization does not authorize device erase, unpairing, account
changes, or an App Store submission.

Mirroring could not scroll the Watch app's Apps list to Available Apps, so the
agent requested only that manual installation step. Owner completed it and
confirmed Watch About **1.0 (4)**. Physical setup-practice and spaced-two-series
diagnostic trials on that build are now requested; their outcomes are pending.

Owner's build-4 diagnostic response: two series are recognized, **but not always**;
owner asks whether THEM should use another gesture. There are still no numeric
attempt/success/miss denominators or wrong-team counts. This establishes that a
second native activation can reach the app, but does not establish the ≥95%
criterion, comfort or safety in play. No large recognition trial is requested
until the input-mechanic decision is settled. One-hour play/video remain postponed
by the owner; neither is passed. The setup navigation outcome was not reported
separately from the gesture response.

## Historical original physical trial protocol — acceptance superseded

This original measurement protocol is retained for traceability, not requested
again. Its manual evidence clauses are superseded for M29 by
[OWNER_ACCEPTED_BY_DECISION](owner-physical-acceptance.md); none of the planned
counts, duration or video below is relabelled as collected evidence.

Use a confirmed current Watch installation and an identified disposable test game;
preserve owner history and existing purchase state. Record actual wrist and racket
hand, OS/build, language, settings, timing, environment and operator. A stopped or
incomplete trial is recorded as such, never assumed successful.

1. Confirm every new-game path defaults OFF; enable on one active test game.
2. Run 40 intended US commands (one native series each) and 40 THEM commands
   (two native series each). Record each outcome, exact successes/misses and
   wrong-team/duplicate awards. Each team must reach at least 95%; no wrong-team
   awards. Denominators are actual attempts, not the planned count.
3. Run 10 third-series cancellations and 10 touch/menu/Undo interruption trials,
   including near the deadline; record no delayed awards.
4. During one full hour of ordinary recreational play/movements, record elapsed
   time, intended commands/misses and every unintended point; required result is
   zero unintended points and zero wrong-team awards.
5. Record actual haptic distinction and comfort, lowered wrist/Always On/lock/
   competing app behavior, native player entry and Crown/touch use. Agent-operated
   mirroring cannot establish tactile comfort or recognition.
6. Complete every remaining scenario in
   [the physical inventory](../M25/M29-hardware-inventory.md), with exact current
   observations. Sandbox/account authorization and irreversible owner-data actions
   require owner involvement. No real-money purchase or data erasure is implied.
7. Capture continuous real Watch video with gesture and actual score visible:
   opt-in, one/two/third series, fixed deadline, touch override and Undo.

At that earlier checkpoint all physical rows remained PENDING until actual
results were recorded. Current manual outcomes are OWNER_ACCEPTED_BY_DECISION.
Final six-domain records must distinguish accepted manual scope from measured
digital evidence. No M25 exception carries into M29, M26 or release.
