# M22 Builder self-review

Baseline: `116a22c8b418412e08998fb07cd3bbf4a840a361`, primary checkout/main.
Builder self-review, not an independent audit or release approval.

## Scope and state ownership

Watch game menu and latest editable result open Journal. Effective rallies are
materialized in played order with stable identities and correction receipts;
recent entries appear first in a lazy scrolling list, without a display cap.
Checkpoint, service and lifecycle entries have detail. Earlier readable rallies
remain read-only after the latest manual/migration checkpoint. New archived
results expose read-only journals; legacy archives say detail is unavailable.
No new scoring, setup, persistence schema, iPhone demo, purchase or network behavior.

Change winner/delete/insert opens a pure revision-bound Before/After review. Later
winners retain order. A changed set boundary has no final After snapshot or enabled
Apply until both serving players are selected explicitly; subsequent boundaries
can ask again. Overflow and unavailable targets have localized cancellation and
review guidance. Apply uses LiveScore's existing atomic store/retry/announcement
path. Cancel and Back write nothing. Revision changes invalidate the review, and
the domain checks the revision/target/boundary again at save time. One Undo restores
the whole correction with existing idempotent usage accounting.

## Craftsmanship and accessibility

Native graphite/lime rows retain existing Watch tap targets, body typography,
wrapping and scroll behavior. The live one-tap scoring surface is unchanged.
Review separates Before/After vertically; each complete score, completed sets,
next service and finish state forms a coherent VoiceOver element. Blocking errors
and serving requirements are announced; save success/failure uses existing
feedback. There is no new custom animation, illustration or continuous activity;
the native interaction expresses this careful review task adequately. Existing
Reduce Motion behavior remains applicable without a new motion dependency.
All new strings have actual translations in the existing 13 locales. Identical
French/Swedish Journal and Dutch Rally entries have language-specific explanations
in their existing unchanged-word records; the verification rules are unchanged.

## Corrections during development

- The latest finished result needed a visible Undo for the new selective correction
  journey. It now exposes the existing LiveScore Undo action while available;
  coverage checks a result correction followed by exact journal restoration.

- Registered new production views in both Watch executable and StoreKit host;
  source membership is checked by the existing strict graph checks.
- Corrected initial registration helper matching across pbxproj object boundaries.
- Corrected the new UI helper to tap the live score's fixed footer directly, as the
  existing suite does, rather than treating that footer as scrollable content.
- Corrected the new failed-save fixture’s last rally number to39 (nine four-point games plus three rallies).
- Corrected the new legacy History navigation identifier to the existing home route.
- Replaced a key-path predicate in a new Swift Testing assertion with an explicit
  closure to avoid the SDK macro's throwing-function inference error.
- Runtime inspection moved the long replay explanation below Before/After so the score comparison leads on the small Watch.
- Archived detail now explains that the entire journal is read-only, rather than
  implying that only the checkpoint prevents editing.
- Successful own saves do not announce a spurious stale-preview error while their
  view leaves. Initial ambiguity/error is announced as well as later requirements.

Validation, runtime results and remaining dispositions are recorded in the final
milestone verification record. Early development failures are retained and are not
claimed as passes. No pre-existing failure or historical acceptance is invoked.
