# Coordinator visual review

Shipping 44-mm screenshots: all 72 added locale images and all six refreshed English images individually inspected. Source `cbe452b0efda5c1c06aac97cc6b5132817876cd8`; original exports and hashes are in the shipping manifests. French/Russian replacements and the two Portuguese Portugal replacements use passing result bundles at the same source, recorded per image where needed. Every final shipping image was individually inspected and 78/78 matched the exact original attachment bytes.

Final product source under integration: `b03098d66ec2948b2c840501773078a83c7dd896`. Additional bounded QA source `b5ebd6ab23b7edf0899c8c26e65fc9233b44a11f` has identical product files; the only difference under App is added test-only probes in StoreMaterialsUITests.swift. Both devices use managed Apple Watch SE 40-mm simulators on watchOS 26.1.

The full final scheme supplies largest-text rules, demo, privacy, terms, support, launcher help, access/restore, live score and save-error captures, plus actual Match/Americano completion and data-deletion states. Additional QA supplies six normal-size 40-mm captures and seven expanded Americano/result/history captures per locale. Captures are read as complete rendered screens; an accessibility tree alone does not establish that glyphs fit.

| Locale | Shipping 44 mm (6 each) | Additional 40 mm normal/expanded (13 each) | Final journeys and creation (13 each) |
| --- | --- | --- | --- |
| es | reviewed | reviewed at b030; fit corrections pending | PENDING |
| it | reviewed | reviewed at b030; fit corrections pending | PENDING |
| fr | reviewed | reviewed at b030; fit corrections pending | PENDING |
| pt-PT | reviewed | reviewed at b030; fit corrections pending | PENDING |
| pt-BR | reviewed | reviewed at b030; fit corrections pending | PENDING |
| nl | reviewed | reviewed at b030; fit corrections pending | PENDING |
| de | reviewed | reviewed at b030; fit corrections pending | PENDING |
| sv | reviewed | reviewed at b030; fit corrections pending | PENDING |
| da | reviewed | reviewed at b030; fit corrections pending | PENDING |
| fi | reviewed | reviewed at b030; fit corrections pending | PENDING |
| nb | reviewed | reviewed at b030; fit corrections pending | PENDING |
| ru | reviewed | reviewed at b030; fit corrections pending | PENDING |

Real spoken VoiceOver is not covered here; all required Watch rows remain unverified in REAL-WATCH.md until M10 records hardware evidence.

The complete 156-image first pass found Spanish team-name/editor clipping at maximum text and Dutch/Swedish server-number clipping at normal 40-mm size. All corrections are tracked in runtime-findings.md; affected surfaces are repeated before acceptance.
