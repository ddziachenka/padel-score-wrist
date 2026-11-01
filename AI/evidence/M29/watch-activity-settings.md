# M29 — Watch activity/display settings, read-only investigation

2026-11-01, physical paired Watch Ultra 3 / watchOS 27.0.1, observed through the
phone's Watch app in iPhone Mirroring. Owner asks how to keep the score visible
and prevent returning to the clock during play, then clarifies that Watch menus
are English. The latest instruction is to explain the settings. Agent only reads
these preferences; no system setting is changed for this request.

## Actual observations

- Global **General → Return to Clock → After 2 minutes** is selected.
- **Return to Clock → Padel Score — Wrist → Default** is selected. Its own footer
  explicitly says the app returns to the clock after two minutes. Thus the global
  value is actually inherited by this app, not merely assumed.
- **Display & Brightness → Always On** is On.
- **Wake on Wrist Raise** and **Wake on Crown Rotation** are On.
- **Wake Duration → Wake for 70 Seconds** is already selected, under **On Tap**.
- Always On's global **Show Apps** is On, and **Padel Score — Wrist** is also On
  in that list. Capture `watch-always-on-padel-enabled-observed.png`.
- General shows configured **Watch Orientation: Left Wrist**. This is the system
  setting, not owner confirmation of actual worn wrist or racket hand.

Captures under `.artifacts/M29/`: `watch-return-clock-global-observed.png`,
`watch-padel-return-clock-default-observed.png`, `watch-display-settings-observed.png`,
`watch-wake-duration-70-observed.png`.

## Instructions supplied with exact English labels

1. **Settings → General → Return to Clock → Padel Score → Custom → After 1 hour**.
2. **Settings → Display & Brightness → Always On → On**; permit Padel Score in
   **Show Apps** if that per-app option is shown.
3. **Settings → Display & Brightness → Wake on Wrist Raise → On**.
4. **Settings → Display & Brightness → Wake Duration → Wake for 70 Seconds**.

**Always** in Return to Clock means always returning to the watch face, not keeping
the app visible. Always On retains a dim score display, not full active gesture
recognition. Raise/wake the wrist before native Double Tap. Seventy seconds applies
to tap-to-wake and does not promise permanent full brightness/activity.

Apple's current [display settings guide](https://support.apple.com/en-by/guide/watch/apd127ec93ac/27/watchos/27)
explains the separate per-app return duration and wake settings. Apple's
[frontmost-state documentation](https://developer.apple.com/documentation/watchkit/taking-advantage-of-frontmost-app-state)
and [deprecated extension property](https://developer.apple.com/documentation/watchkit/wkextension/isfrontmosttimeoutextended)
say watchOS 7+ gives this duration to the user; the obsolete extension flag cannot
override it. [Always On behavior](https://developer.apple.com/documentation/watchos-apps/designing-your-app-for-the-always-on-state)
distinguishes inactive visible UI from active execution. No fake workout or extended
runtime is added; the approved no-HealthKit/no-motion architecture and pending-input
cancellation on inactivity remain intact. Actual idle/wrist-down physical outcome
still requires observation and is not marked passed from these settings alone.
