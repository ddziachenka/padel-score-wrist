# M16 hardware progress — 2026-10-24

Builder observation plus explicit owner confirmations. Not a complete hardware pass.

Candidate source checkpoint: 91af634d5278fd77bee0cefa0d6347214e7a9c4f (the signed Debug build was compiled from the same app inputs before the recovery commit). iPhone17 Pro Max iOS27.0.1; paired Apple Watch Ultra3. Version1.0 build2. Actual shipping bundle structure passed the companion checker. Build/install logs: `.artifacts/M16/device-build-visual-fix.log`, `.artifacts/M16/iphone-install-visual-fix.log` (installation exit0). No app data was erased.

- Phone read-only DEBUG diagnostics: verified transaction environment Sandbox, price0 USD. `.artifacts/M16/iphone-console-visual-fix.log`. No local bought flag is transferred.
- Owner confirmed repaired secondary copy is visible on the physical iPhone and the Watch app updated: “Текст виден, приложение на часах обновлено”.
- Owner executed About→Access→Restore purchases on Watch and Access→Restore purchases on iPhone, then disconnected the Watch from the phone and opened scoring. Exact answer: “Восстановление работает на обоих, часы работают без связи”.
- Mac direct Watch install/info attempts fail with CoreDevice Bluetooth L2CAP open channel errors. Owner confirmation of Watch update and manual flows is distinct from Mac installation evidence; no successful Mac Watch install is claimed.

Still required before DONE: distinct fresh iPhone→Watch and Watch→iPhone purchase scenarios, restoration after reinstall, Watch operation with iPhone app absent, full hardware accessibility/haptics/appearance checks. An already-owned Sandbox entitlement plus Restore on both proves neither a new purchase nor an uninstall/reinstall. Preserve existing Watch game/history data during any reinstall scenario.

Latest read-only CoreDevice inventory reports the owner iPhone and Watch unavailable
(`.artifacts/M16/devices-latest.json`). No further hardware test or installation is
claimed after that disconnection. No Sandbox testers have been created; the proposed
isolated tester setup and Mac unlock/reconnection questions remain unanswered.
