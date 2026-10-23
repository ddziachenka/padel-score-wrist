# Real-Watch localization evidence — pending M10

This is an execution guide for M10's existing hardware coverage, not another audit or a passing record. Every row below is **UNVERIFIED**. Simulator screenshots, accessibility trees and synthetic announcements do not prove spoken output on a Watch.

Record the exact installed build SHA, version/build, Watch model and size, watchOS version, language/region, text size, tester, UTC date, observations and evidence location. Preserve observed speech and any correction with before/after evidence. Required hardware that is unavailable keeps M10 BLOCKED.

| App locale | Region used in automated coverage | Spoken VoiceOver on Watch |
| --- | --- | --- |
| es | es_ES | UNVERIFIED |
| it | it_IT | UNVERIFIED |
| fr | fr_FR | UNVERIFIED |
| pt-PT | pt_PT | UNVERIFIED |
| pt-BR | pt_BR | UNVERIFIED |
| nl | nl_NL | UNVERIFIED |
| de | de_DE | UNVERIFIED |
| sv | sv_SE | UNVERIFIED |
| da | da_DK | UNVERIFIED |
| fi | fi_FI | UNVERIFIED |
| nb | nb_NO | UNVERIFIED |
| ru | ru_RU | UNVERIFIED |

For each locale, follow the actual player journey: choose Match and its 40–40 rule, select serving order, add and undo a point, correct score/service, confirm the next set, finish, read the result/history and start again. Also create Americano, reach its total, read the round result and return to history. Read rule explanations, demo, quick-launch help, free-game limit, purchase/restore states, save error and deletion confirmation. Use the glossary in that locale's review to distinguish an entire game/session from a game inside a set and a serving player from a computer server.

Judge focus order, full control names, score ownership, state-change announcements, native pronunciation and intelligible counts. Cover 0, 1, 2, 4, 5, 11, 21, 22, 25, 101 and 999 for both pluralized messages; Russian denominators use genitive forms, and Brazilian zero remains plural. A correct written label alone does not mark this row verified. Review the small supported screen and largest text size as well as normal court use.

M10 also retains its existing real-device rows: on-court operation and haptics, Always On/Low Power and wrist-down return, oldest-device launch performance, adverse-network StoreKit purchase/restore, and launching from the actual watch face/Smart Stack. The six-domain consolidated M10 record owns the final evidence. `make milestone ID=M10` and `make release CANDIDATE=<full-SHA>` run only after required evidence is complete, on the same candidate. No App Review submission is implied.
