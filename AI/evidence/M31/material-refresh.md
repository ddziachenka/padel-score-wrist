# M31 material refresh — in progress

Frozen source: `d4fd56eed1ec786b7558b5f64907291bb0f16aee`, build1.0(7).
No gameplay, persistence, gesture or purchase implementation change.

## Native capture evidence

`bash Scripts/capture-store-materials.sh watch capture m31-watch-gallery-1`
exits0. Native summary14/14 definitions/invocations passed;0failed/skipped/
expected failures/runtime warnings. UTC2026-11-01T20:24:26.541000+00:00–2026-11-01T21:04:55.347000+00:00.
Bundle `.artifacts/M25/m31-watch-gallery-1.xcresult`, source/context/exit/summary
sidecars and log share that prefix. Managed44mmSE/watchOS26.1, UDID
22C79D99-DEA7-4525-AD2D-50FDCD6B8720. Simulator activation does not measure
physical Double Tap recognition; M29 owner acceptance stays separate.

Phone-current capture is running from the same unchanged fullSHA. No phone pass,
new imported gallery, creative visual pass or full milestone pass is claimed yet.
Pipeline .artifacts/M31/refresh-materials.sh runs only after successful phone capture.

## Completed phone capture and material pipeline

`bash Scripts/capture-store-materials.sh phone-current capture m31-phone-gallery-1`
exits0. Native2/2definitions/invocations passed,0failed/skipped/expected/runtime
warnings. UTC2026-11-01T21:05:36.666000+00:00–2026-11-01T21:18:41.140000+00:00. Bundle/source/context/exit/summary
.artifacts/M25/m31-phone-gallery-1.*;17ProMax/iOS27 UDID
2D44D21F-290D-4325-8DED-B98D29977585. Same full capture source as Watch.

`bash .artifacts/M31/refresh-materials.sh` exits0. Strict importer, composition,
site preparation, unchanged validator,42contact-sheet generation, make site-check,
3page ReportLab guide generation and PDF rasterization all complete successfully.
Logs .artifacts/M31/material-{import,compose,site,validate,contacts}.log and
site-check.log.112Watch+98phone native originals,28creatives,14locales,104site copies.
No image/source/count guard weakened. Legacy PENDING_M29 manifest markers remain
schema identifiers; separate M29 owner acceptance and M30 distribution state govern
actual readiness. Full M31 gate and runtime launcher-icon inspection still pending.
