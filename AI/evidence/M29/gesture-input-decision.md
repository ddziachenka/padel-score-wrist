# M29 — five-second prototype approved

Builder record, 2026-11-01. No release approval or hardware recognition pass.
Current shipping correction: `0d535ac26a543d37333f3c457bbfba1316663d90`,
Release 1.0 (4), owner-confirmed on physical Watch Ultra 3 / watchOS 27.0.1.
Test-input-only follow-up: `9659e7c3017faf8dc4530c46ad49cb97f3c0eec9`.

## Observation

Owner reports two Double Tap series do select THEM, but not always, and asks
whether another gesture would make sense. There are no exact denominators,
miss/wrong-team counts, wrist/racket hand, or continuous video. The ≥95% per-team
criterion is unmeasured; intermittent recognition is not accepted as completion.
We have not isolated native recognition rhythm, available time, or another cause.
No claim that a longer window fixes recognition is supported yet.

## Platform boundary

Apple's [Double Tap integration documentation](https://developer.apple.com/documentation/watchos-apps/enabling-double-tap)
provides one primary action per scene via `handGestureShortcut`. The installed
watchOS 27 SDK's `HandGestureShortcut` public interface exposes only
`static let primaryAction` (SwiftUI arm64_32 watchOS swiftinterface, lines 526–529).
A separate clench, held finger contact or wrist rotation cannot simply be assigned
through this API. This is narrower than claiming all alternative inputs impossible.
A custom movement classifier would require separate feasibility work and physical
validation; racket/play motions create a plausible false-positive risk, not a
measured finding in this project.

## Options presented for owner choice

1. **Test a five-second prototype (Recommended).** Preserve native one/two/third
   series and cancellation, but extend the fixed window from 3 to 5 seconds in a
   test build. Two seconds more time for the second recognized series, with two
   seconds more latency before saving. Hypothesis only; keep all existing ≥95%,
   zero wrong-team and one-hour criteria. Update owning product/architecture/design
   and localized instructions/tests if approved; retest before any acceptance.
2. **Investigate another gesture.** Bounded feasibility/prototype for an alternative
   input before selecting a production mechanic. A motion-based detector would
   change the approved no-motion-collection architecture and need a separate
   contract and sporting-motion false-positive evidence. No reliability promise.
3. **Keep three seconds and measure.** Preserve current approved behavior; practice
   and collect actual per-team attempts, misses and wrong-team outcomes. No waiver
   of failed recognition or missing physical rows.

The approved [plan](../../gesture-differentiation-plan.md) fixes three seconds;
[architecture](../../ARCHITECTURE.md) explicitly excludes motion collection.
AGENTS A4/A13 require the developer's decision for these product changes. No
production timing or gesture changes have been made in response to this question.
Capture refresh waits for the chosen mechanic so the source-bound galleries are
recreated from the final shipping inputs, without weakening the fingerprint guard.

## Owner choice — resolved

Owner selected **“Прототип 5 секунд (Recommended)”** on 2026-11-01. The decision
blocker is resolved. M29 resumes IN_PROGRESS with the five-second prototype and
matching Watch/phone instructions in all 13 UI languages. Build 1.0 (5) will
distinguish this timing experiment from build 4. The owning PRODUCT, ARCHITECTURE,
DESIGN and gesture plan record this narrow amendment. No custom motion detector,
new gesture, lower recognition threshold or acceptance waiver is approved.

Earlier wording above records the decision as presented, not a still-pending
question. The choice authorizes building/testing five seconds; physical evidence
must still establish comfort and reliability before adoption/release readiness.

## Other blockers retained

Owner postponed one-hour ordinary-play testing and real Watch gesture video.
The remaining physical inventory, six final domain records and full unchanged
`make milestone ID=M29` remain mandatory. M29 cannot reach DONE or advance M26
from the current qualitative trials or the targeted simulator checks.
