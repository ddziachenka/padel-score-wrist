# M16 — explicit owner acceptance, 2026-10-24

The owner said: «достаточно что проверили на текущем» and confirmed that the Mac
was unlocked and the current pair connected. Asked whether this accepts the current
pair without fresh Sandbox accounts/reinstalls, and also permits the two SE/iOS17
native audits not to block M16 based on the passing iOS27 checks, the owner answered:

> да - разрешаю не блокировать и опираемся на прошедшие проверки

## Exact scope

- Existing observed Sandbox entitlement, owner-confirmed restore on both devices,
  Watch update/visible text and scoring disconnected from phone are accepted as
  sufficient physical coverage for M16. Fresh acquisitions in both directions,
  reinstall/restore, deleting only the phone app and additional physical assistive-
  technology/haptics scenarios were not executed and are not reported as passes.
  Do not create new Sandbox accounts or reset existing purchases for those scenarios.
- Only the native **Contrast failed** results in
  `CompanionUITests/testLargestTextAccessibility()` and
  `CompanionUITests/testSpanishTeamNamesAtLargestTextAreNotClipped()` on iPhone SE3 /
  iOS17 are accepted as nonblocking. Supplemental current-iOS27 checks passed4/4
  (including both audits). The real earlier Spanish text truncation was fixed.
  This decision does not declare the remaining native reports false positives.
- No missing, skipped, crashed, functional, StoreKit, packaging, clipped-text or
  other failure is accepted. Full primary Watch coverage and all existing iPhone
  tests still execute. No test, assertion, result parser, retry policy or generic
  gate is altered to turn a failure into a pass.
- Run `make milestone ID=M16` on the clean REVIEW candidate. Preserve its actual
  exit/status and all result counts. If its sole failure is the two exact accepted
  contrast results, M16 may complete under this explicit owner exception to the
  earlier all-green acceptance requirement. It must not be described as a passing
  automated gate. Any other failure still blocks DONE.
- A separate Release Readiness Revalidation remains required. Preserve this owner
  decision and actual raw gate verdict in that process; do not inherit M10 readiness
  or report an automated READY_FOR_HUMAN that the tool did not return. Existing
  submission authorization remains; no new permission is required for the approved
  submission once the new candidate is properly assessed.

Mac access was confirmed through normal Xcode UI on this resumed session. CoreDevice
still reported the physical phone tunnel unavailable; that observation does not
contradict the owner's physical connection confirmation or invent a new device test.
