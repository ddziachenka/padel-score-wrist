# M31 installed icon runtime review

Builder visual self-review, not independent audit or physical gesture validation.
Candidate `16a7a094ac863a416b61aa701d3c7b37d14f445d`, capture-source shipping
inputs `d4fd56eed1ec786b7558b5f64907291bb0f16aee`, version1.0(7).

The owner unlocked the Mac on2026-11-02. Xcode's installed simulator UI is Device Hub
(com.apple.dt.Devices); a separate Simulator.app does not exist at the usual path.
Each inspection held its own checkout/device/desktop lease across all interactions.
Both leases were explicitly released, exit0. No foreign device or physical pair
was changed, and no global simulator reset was performed.

Watch44mmSE/watchOS26.1, UDID22C79D99-DEA7-4525-AD2D-50FDCD6B8720:
actual system circular app grid inspected. The hand silhouette and ball seams stay
legible, with no meaningful shape clipped by the circle. Evidence screenshot
`.artifacts/M31/watch-system-icon-1.png`, SHA256
748cb5e567b6a5f87dcf86f8a8cbc3bc8ac32204a0c6016344e813f174fd8c25.
Installed plist confirms1.0(7), correct Watch bundle. Exact executable hash and UDID
are in `.artifacts/M31/watch-icon-runtime.json`.

Phone17ProMax/iOS27, UDID2D44D21F-290D-4325-8DED-B98D29977585:
actual system Spotlight displays PadelScore with the matching rounded-square icon.
Hand/ball remain clear and centered, label readable. First Home page had no app;
Spotlight is the reviewed surface, not a claimed second Home-page observation.
Evidence `.artifacts/M31/phone-system-icon-search.png`, SHA256
91ce22775412cd79c818f39f3d2cc84ccfcff6db385edee212f7d6e08ba866af.
Installed plist confirms1.0(7), correct phone bundle. Exact executable hash and UDID
are in `.artifacts/M31/phone-icon-runtime.json`.

Both PNGs were captured through exact-UDID `xcrun simctl io ... screenshot ...`,
exit0, and actually viewed by the Builder. They supplement earlier inspected32px/
64px source previews and opaque1024px identical icon catalogs. No icon correction
was needed. The required runtime icon observation is complete; full M31 automatic
verification separately remains failed and must be corrected/rerun.
