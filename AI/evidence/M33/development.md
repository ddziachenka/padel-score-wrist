# M33 preparation and Builder self-review

Baseline `57e0d5918c265abab071435ce5c7e8dbb7a6b286`, primary checkout/main.
Build/material source `8eeec63f5287639b86e637803b436b005a6901da`.
This is Builder self-review, not an independent audit or release approval.

## Scope and source review

The owner approved splitting M33 audit/materials and M34 release readiness; all
original gates are retained in their owning milestones. M33 increments all twenty
project build settings from 7 to 8 and updates the two exact installed-version
assertions. No test/assertion is removed or loosened. No scoring, privacy, storage,
permissions, purchase or gesture-recognition implementation changes in M33.

Reviewed M32's serve-side diff against PRODUCT and DESIGN: ordinary points use
parity without overflow-prone addition; deuce/advantage and deciding points are
explicit; tie-break uses total parity, independent of server. Americano derives
from accepted rallyInBlock, not total score. Finished/unconfirmed states suppress
side. No persistence field, migration or receiver-choice input was introduced.
Watch/phone/recovery read the shared board. Full speech is attached to server
labels/values; duplicate visible choice labels are accessibility-hidden. Custom
names wrap with the side, retaining the score and existing scrolling fallback.

Reviewed all thirteen translated side labels and help paragraphs: the server-facing-
net viewpoint, NEXT rally, receivers' choice, and per-block Americano R reset are
present; literal L/R is preserved. Prepared fourteen Store-locale guide snippets
from these exact approved translations, including both Spanish storefronts.
Self-review corrected a draft instruction that incorrectly suggested an Americano
Watch demo: Watch Try the scoreboard is Match-only; Americano demo is on iPhone.
The physical protocol now uses a safe disposable real Watch Americano game.
Review Notes add reproducible isolated demo steps and make no uniqueness or
review-acceptance claim. Historical guides remain unchanged.

Source-bound comparison with final M31 candidate
`cb6bc1243e49cd51f1817d1d263e09e9028a7fe9` is saved in
`.artifacts/M33/source-impact.json`: 30 changed App/test files and 216 unchanged
App/Config/Scripts files with SHA256 hashes. Changed production paths are the
serve-side model/presentation/help/catalogs and project build identity. Persistence,
StoreKit, permissions/privacy, rating eligibility and native name storage remain
unchanged. Historical M29 physical acceptance retains its recorded limits and
cannot establish fresh affected side readability or VoiceOver acceptance.

## Actual current checks

- `./Scripts/project-status.sh validate`: exit 0 after the approved split.
- Signed device build outside sandbox: exit 0; three actual bundle plists all
  1.0 (8). See physical-check.md for command and unsuccessful installation evidence.
- Read-only `ruby .artifacts/M33/read-asc.rb`: sandbox DNS failure exit 1,
  network-enabled read exit 0 at 2026-11-07T04:35:31Z. Current app/version remains
  DEVELOPER_REJECTED; categories SPORTS/UTILITIES; age-rating declarations contain
  no advertising, gambling or other mature-content claims. No ASC mutation.
  `.artifacts/M33/asc-readback.json`; global credentials used in memory only.
- Fifty-two `curl -L --fail --silent --show-error --max-time 45 <URL> -o <file>`
  calls exited 0. Actual HTML and hashes under `.artifacts/M33/public/` and
  `public-readback.json`; all thirteen Terms pages include Apple's Standard EULA
  URL. No deployment occurred. No HTTP status beyond successful --fail GET is
  invented; the exact command results remain in public-command-results.json.

## Self-review corrections and current limits

All material visual review is now complete; see visual-review.md. The PDF's four
pages were rendered and inspected. Exact digital command results and bundle counts
are recorded in digital-verification.md, including correction of an initial helper
selector that named NewGameUITests instead of PlayerNamesUITests for the long-name
regression. The original runs remain intact; separate correct-class runs are
required before crediting that coverage. No test source/assertion is loosened.

Reviewed baseline-to-tip source diff: twenty build identities and two strict
expected-version assertions only. Approved workflow split retains every full gate.
No shipping input changed after8eeec63; records, native/creative assets, guide and
local corresponding website copies are the only subsequent work. The visual pass
found no issue that required a new asset or altered product UI; native score,
server and side remain the focus. No speculative motion/performance change.

Physical acceptance and the unchanged full M33 milestone gate are NOT complete.
The owner explicitly says the Watch is unavailable. Six domain records remain
INCOMPLETE and M33 BLOCKED; M34 is PLANNED. No readiness verdict, App Review
submission, uploaded build, public deployment or promotion change.

## Later physical closure

The earlier physical blocker is superseded by owner-physical-verification.md:
all requested affected physical checks are owner-confirmed. Six domain records
are completed for the clean REVIEW/main full gate. No source/material byte changed
as part of physical closure; historical failures remain preserved.

## Full verification closure

The fresh unchanged full make milestone ID=M33 passed at
fd27bdc459a23e7880b3beb16711b92e6fc962aa, exit0, UTC2026-11-07T08:24:19Z–14:47:43Z.
All693 definitions/1156 invocations passed, zero adverse results; both Debug and
package guards passed. See milestone-verification.md for exact commands, bundles,
counts and the retained raw report. This supersedes the historical pending gate
and physical-blocker statements above. Only AI Markdown closure records follow
the verified candidate; M34 remains separate.
