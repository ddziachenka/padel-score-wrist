# Remaining physical StoreKit scenarios

The owner confirmed Sandbox restore on both devices and Watch scoring without phone connectivity. The phone has an existing verified lifetime, so another Restore does not prove a fresh purchase.

Proposed isolated test setup: two dedicated Apple Sandbox testers using owner-controlled Gmail aliases `dzmitry.dziachenka+padel-m16-a-20261024@gmail.com` and `dzmitry.dziachenka+padel-m16-b-20261024@gmail.com`. No real payments, no reset of existing testers or other apps' test purchases. Credentials must remain in a private ignored local file, never in Git or tool output. The owner signs in on the physical devices.

Scenario A: same fresh tester A on iPhone and Watch; verify no lifetime initially; acquire lifetime for0 on iPhone; foreground/restore on Watch and verify unlocked.

Scenario B: same fresh tester B on both; verify no lifetime initially; acquire on Watch; foreground/restore on iPhone and verify unlocked.

Reinstall iPhone companion, restore tester B, verify access. Remove only the iPhone companion while retaining Watch installation; verify Watch scoring and restore/purchase entry points remain usable. Do not erase Watch game/history data without backup or the owner's explicit choice.

Finish physical craftsmanship checks: both themes, VoiceOver score/service/Undo announcement, Reduce Motion and actual haptics. Record owner observations and the exact installed candidate before M16 DONE.

No testers have been created by this proposal. Existing unrelated testers remain untouched.
