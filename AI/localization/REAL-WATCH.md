# Real-Watch localization evidence — owner confirmed

Owner confirmed all outstanding physical checks in the current M10 completion task; each locale row below is owner-confirmed manual evidence. Exact quote, scope and limits: `AI/evidence/M10/device-confirmation.md`. Simulator screenshots alone are still not spoken-output evidence.

Record the exact installed build SHA, version/build, Watch model and size, watchOS version, language/region, text size, tester, UTC date, observations and evidence location. Preserve observed speech and any correction with before/after evidence. Required hardware that is unavailable keeps M10 BLOCKED.

| App locale | Region used in automated coverage | Spoken VoiceOver on Watch |
| --- | --- | --- |
| es | es_ES | Owner confirmed |
| it | it_IT | Owner confirmed |
| fr | fr_FR | Owner confirmed |
| pt-PT | pt_PT | Owner confirmed |
| pt-BR | pt_BR | Owner confirmed |
| nl | nl_NL | Owner confirmed |
| de | de_DE | Owner confirmed |
| sv | sv_SE | Owner confirmed |
| da | da_DK | Owner confirmed |
| fi | fi_FI | Owner confirmed |
| nb | nb_NO | Owner confirmed |
| ru | ru_RU | Owner confirmed |

For each locale, follow the actual player journey: choose Match and its 40–40 rule, select serving order, add and undo a point, correct score/service, confirm the next set, finish, read the result/history and start again. Also create Americano, reach its total, read the round result and return to history. Read rule explanations, demo, quick-launch help, free-game limit, purchase/restore states, save error and deletion confirmation. Use the glossary in that locale's review to distinguish an entire game/session from a game inside a set and a serving player from a computer server.

Judge focus order, full control names, score ownership, state-change announcements, native pronunciation and intelligible counts. Cover 0, 1, 2, 4, 5, 11, 21, 22, 25, 101 and 999 for both pluralized messages; Russian denominators use genitive forms, and Brazilian zero remains plural. A correct written label alone does not mark this row verified. Review the small supported screen and largest text size as well as normal court use.

M10 also retains its existing real-device rows: on-court operation and haptics, Always On/Low Power and wrist-down return, oldest-device launch performance, adverse-network StoreKit purchase/restore, and launching from the actual watch face/Smart Stack. The six-domain consolidated M10 record owns the final evidence. `make milestone ID=M10` and `make release CANDIDATE=<full-SHA>` run only after required evidence is complete, on the same candidate. No App Review submission is implied.

## Owner confirmation — current M10 completion

The project owner subsequently stated in this chat: «на физическом устройстве все проверено», directly after asking to mark M10 DONE and after the outstanding hardware scope was listed. This confirms all required physical-device checks for the current multilingual product, including all twelve locale VoiceOver rows above, court operation, accessibility settings, Always On/Low Power, oldest-supported-device launch, adverse-network StoreKit and the M14 watch-face/Smart Stack launcher. These are owner-observed results, not coordinator-operated hardware tests. The owner did not provide additional device identifiers, measured timings or recordings; none are invented. The earlier UNVERIFIED state remains in Git history; the current acceptance record is consolidated in `AI/audits/M10-final-polish.md`. Automatic milestone and release gates now both passed on `93b7d26a5d1a10154affe27ca2d9d00ceeff6f4f` (exit 0; 510 definitions / 884 invocations each). M10 DONE / READY_FOR_HUMAN; see `AI/handoffs/M10-handoff.md`.
