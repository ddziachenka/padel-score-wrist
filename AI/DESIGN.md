# Product design contract

This document owns journeys, screens, navigation, interface states, visual rules,
accessibility, localization, and appearance. Product purpose belongs in
`PRODUCT.md`; technical implementation belongs in `ARCHITECTURE.md`.

**Status:** not initialized
**Approved by:** TBD
**Updated:** TBD

## Information architecture

Record the complete hierarchy, including tabs, stacks, sheets, full-screen flows,
settings, paywalls, and the default launch destination.

```text
TBD
```

| Question | Answer |
| --- | --- |
| Where does the app open? | TBD |
| What appears before any data exists? | TBD |
| Maximum navigation depth | TBD |
| Which navigation state survives relaunch? | TBD |

## Primary journeys

Every journey records the start, ordered interaction, success, recovery, abandonment
behavior, and the behavior that must never regress.

### J1 — TBD

| Field | Value |
| --- | --- |
| Goal | TBD |
| Entry point and starting condition | TBD |
| Steps | TBD |
| Success looks like | TBD |
| Recovery path | TBD |
| Abandonment: what is kept | TBD |
| Must never break | TBD |
| Acceptance evidence | TBD |

## Screen inventory and navigation

A surface missing from this table has no contract.

| ID | Screen/surface | Purpose | Entry | Exit | Empty | Loading | Error | Offline | Persistent state |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S1 | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

| Navigation question | Answer |
| --- | --- |
| Pattern: tabs, stack, modal, or mixed | TBD |
| Back behavior from the deepest screen | TBD |
| Modal surfaces and dismissal behavior | TBD |
| Surfaces that block dismissal and why | TBD |
| Deep links and invalid-link recovery | TBD |
| Selection/focus restoration | TBD |

A dismissible modal must be safe to dismiss. A surface holding unsaved work either
persists a draft or names the loss and asks for confirmation.

## Interface states

Every relevant screen answers every row. “Cannot happen” requires a reason.

| State | Required contract |
| --- | --- |
| Empty | Explanation and one clear action; never a blank unexplained list |
| First run | Onboarding, sample content, and contextual permission timing |
| Loading | Immediate feedback, thresholds, stale-data behavior, timeout, and cancellation |
| Partial | What appears while some data is available and what remains hidden |
| Recoverable error | Plain-language cause, preserved input, and a retry/recovery action |
| Unrecoverable error | Honest explanation and a safe destination that still works |
| Offline | Available work, refused or queued actions, status, and reconnection behavior |
| Interrupted | Background, termination, lock, call, cancellation, and resume behavior |
| Destructive | Consequence, reversibility, confirmation, and undo policy |
| Success | Visible result or explicit confirmation; silence is allowed when the result is obvious |

### Empty and loading details

| Screen | Empty reason | Empty copy | Primary action |
| --- | --- | --- | --- |
| TBD | TBD | TBD | TBD |

| Screen | Trigger | Under 1s | 1–5s | Over 5s | Timeout/cancel |
| --- | --- | --- | --- | --- | --- |
| TBD | TBD | TBD | TBD | TBD | TBD |

Prefer stale content with a refresh indicator to replacing useful content with an
unbounded spinner.

### Errors and offline behavior

| ID | Error/cause | User-facing message | Recovery | Logged safely? |
| --- | --- | --- | --- | --- |
| E1 | TBD | TBD | TBD | TBD |

Error copy says what happened and what to do next. An error code is never the main
message, and generic copy is not used when the app knows the cause.

| Offline question | Answer |
| --- | --- |
| Does the app work with no network? | TBD |
| Available offline | TBD |
| Unavailable and how it is shown | TBD |
| Actions queued or refused | TBD |
| How offline status appears | TBD |
| What happens when connectivity returns | TBD |

If the app has no network dependency, say so explicitly.

### Interruptions and destructive actions

| Interruption | Expected behavior |
| --- | --- |
| Backgrounded | TBD |
| System termination | TBD |
| Incoming call | TBD |
| Device locked | TBD |
| Low Power Mode | TBD |
| Storage full | TBD |
| Permission revoked while running | TBD |

| Destructive action | Reversible? | Confirmation copy | Undo/recovery |
| --- | --- | --- | --- |
| TBD | TBD | TBD | TBD |

A destructive action is reversible or confirmed, never neither. Confirmation names
the affected object and consequence rather than asking only “Are you sure?”.

## Permissions and privacy UX

Delete the table if the app requests no permission and state that decision.

| Permission | User value | Pre-prompt | When asked | Denial recovery | Revoked later | Works without it? |
| --- | --- | --- | --- | --- | --- | --- |
| TBD | TBD | TBD | TBD | TBD | TBD | TBD |

- Ask when the person invokes the feature, not on first launch without context.
- Explain the value before the system prompt; the system prompt is not onboarding.
- Denial is a supported state with a real path forward.
- Revocation while running is handled without a crash or silent corruption.

## Purchases and paywalls

Delete this section when there are no purchases.

| Question | Answer |
| --- | --- |
| Where the paywall appears | TBD |
| What remains visible for free | TBD |
| How the paid value is demonstrated before the paywall asks for money | TBD |
| Exactly what is sold | TBD |
| Price and term presentation from StoreKit | TBD |
| Which offer is recommended, and how that is marked | TBD |
| Comparison price shown, and the StoreKit product it is derived from | TBD |
| Saving claimed, and the two real prices it is the difference between | TBD |
| Introductory or promotional offer: its duration, and the price after it | TBD |
| What the paywall shows when a compared product does not load | TBD |
| Restore Purchases placement | TBD |
| Terms and Privacy links (see [Legal and support](#legal-and-support)) | TBD |
| Success, failure, cancellation, and pending behavior | TBD |
| Already purchased / family sharing | TBD |
| Expiry, refund, and offline entitlement | TBD |
| What happens to already-created content | TBD |
| Dismissal | TBD |

No fake urgency, countdown pressure, disguised or delayed close control, preselected
purchase, obstructed restore, hard-coded price, or subscription presented as a
one-time purchase. Free content remains reachable. The amount the person will
actually be charged is the most prominent number on the screen, and a crossed-out
price appears only where the table above says which real product it comes from.

Every price, period, and saving is the localized string StoreKit returns for the
person's own storefront, never a number the app formatted itself — a hand-built
currency string is wrong in some storefront on the day it ships. The purchase,
restore, pending, and failure states are finished surfaces with the same care as the
offer, because those are the moments a person is deciding whether to trust the app
with money.

The development-only premium override in `AI/ARCHITECTURE.md` has no user-facing
surface. It belongs to no journey, appears in no screen inventory, and is never a way
to grant a person entitlement — a build anyone can install does not contain it, so
nothing here describes how it looks.

## Review request

watchOS has no required rating request or manual rate entry point. Record this
section as inapplicable for Watch-only; the rules below govern iOS.

Every iOS product asks for a rating, and every iOS product asks the same way: once,
at a moment the application has already earned, through the system rating prompt. This
section is answered rather than deleted.

| Question | Answer |
| --- | --- |
| Qualifying moment — the success the person has just completed | TBD |
| What must be true before asking: completed successes, days since first launch | TBD |
| Cooldown, and the cap of one request per app version | TBD |
| Manual entry point, its wording, and where it lives | TBD |
| What the person sees when the system prompt does not appear | TBD |
| Where eligibility state lives, and what resets it | TBD |

The request follows a success, never a task in progress, an error, a purchase or
paywall flow, a destructive action, an interruption, or onboarding. The system
decides whether the prompt is actually shown and may show nothing at all, so the
application records that it asked rather than that the person saw anything, and
no journey may depend on the prompt having appeared. The manual entry point is
how somebody rates on their own initiative, and it is the only rating surface a
tap is allowed to open directly.

## Legal and support

Every product provides access to its privacy policy, its terms of use, and support
from inside the app. iOS uses links; watchOS provides readable on-watch content.
This section is answered rather than deleted. Terms of use is
Apple Standard EULA for every product this template generates, so what is designed
here is where the links live and how they behave — never whether a person can reach
them.

| Question | Answer |
| --- | --- |
| The settings or about surface that carries all three, and how it is reached | TBD |
| Their wording and order on that surface | TBD |
| Where Terms and Privacy appear on the paywall | TBD |
| Platform-supported access: browser/URL action or readable on-watch content | TBD |
| What the person sees when the link cannot open | TBD |

On watchOS, provide readable Privacy, Terms and Support content on the Watch, with
the corresponding public URLs and support contact. A working system URL action may
supplement it; never assume Safari exists or require an iPhone app. Verify access
and failure states on the supported Watch OS. Subscription terms remain available
before purchase. The public pages and their validation remain required.

Three links, three destinations: `<site>/privacy`, Apple's Standard EULA at
`apple.com/legal/internet-services/itunes/dev/stdeula/`, and `<site>/support`. The
support page is also what the App Store listing's support URL points at, so it
answers a real person rather than redirecting to a marketing page.

All three are reachable without paying, without an account, and without granting a
permission. A person deciding whether to trust the app reads the privacy policy
before they buy anything, so a privacy link that only exists on the paywall is a
privacy link most people never see.

The published site covers every language the application ships, or this section
records why it does not — a person who uses the app in their own language and is
handed a privacy policy in another has not been told what the app does with their
data. See [Localization](#localization).

## Visual direction

| Question | Answer |
| --- | --- |
| Three or four adjectives | TBD |
| Reference products and the specific lesson from each | TBD |
| Density | TBD |
| Personality | TBD |
| Amount and purpose of color | TBD |
| Imagery/illustration | TBD |
| What this app must never look like | TBD |

The template chooses no style. It requires semantic tokens and prohibits visual
choices that break behavior or accessibility.

## Craftsmanship and signature experience

What separates a finished commercial product from a working MVP. Here that is
clarity, speed, hierarchy, excellent defaults, low friction, immediate feedback,
consistency, and details that were decided rather than defaulted. It is not
gradients, glass, cards, or animation: decoration added to a screen that was not
otherwise resolved makes the screen look decorated, not made. This section is short
on purpose — it is a product language, not a design-system specification.

| Question | Answer |
| --- | --- |
| Interaction personality, in one sentence | TBD |
| What a person should notice first on any screen | TBD |
| What this app does faster, or in fewer steps, than the obvious alternative | TBD |

### Action hierarchy

| Level | How it is expressed | How many per screen |
| --- | --- | --- |
| Primary | TBD | at most one |
| Secondary | TBD | TBD |
| Tertiary or navigational | TBD | TBD |
| Destructive | TBD | TBD |

One action on a screen is obviously the one to take. Two controls competing for that
role is the same defect as none: the person stops to decide something the design
should already have decided.

### Interaction feedback

Every action is acknowledged — the control responds to the touch, the result appears
or its progress does, and a failure says what happened. Silence is allowed only where
the result itself is the feedback. Feedback that arrives late reads as a bug, and a
screen that replaces another with no transition reads as a glitch.

| Question | Answer |
| --- | --- |
| Acknowledgement for an action that completes immediately | TBD |
| Acknowledgement for one that takes longer than a moment | TBD |
| How a change of screen or of major state is expressed | TBD |
| Pressed and selected state for a primary control | TBD |
| Which results earn a success transformation rather than a message | TBD |
| Where inline feedback replaces a modal interruption | TBD |
| Which destructive actions offer undo instead of a confirmation | TBD |
| Which results earn a haptic (see [Motion and haptics](#motion-and-haptics)) | TBD |

An important interaction may combine a visual response, motion, and a haptic where that
combination is what makes the feedback land. An ordinary tap does not become an event.

### Signature experience

One moment this product is remembered for: the interaction worth building properly
even though a plainer version would function. It belongs to an approved journey and
to a surface in the screen inventory, and it never costs clarity, speed, or
accessibility to exist.

| Question | Answer |
| --- | --- |
| The moment, and where it happens | TBD |
| Why it makes the product feel unusually well made | TBD |
| Its behavior under Reduce Motion, VoiceOver, and the largest text size | TBD |
| How it is judged finished rather than merely present | TBD |

`None`, with the reason, is a valid answer. A product that invents a signature moment
it does not need has added bloat, which is the opposite of what this section exists
for. The native-versus-custom rule in
[Components and system controls](#components-and-system-controls) applies here like
anywhere else: a custom interaction records why a system one is insufficient and
matches it for accessibility and platform behavior.

### Delight opportunities

Two to four moments — normally no more — where a bespoke visual treatment, an
illustration, motion, a haptic, or a micro-interaction would materially improve
comprehension, personality, feedback, or delight. The signature experience above is the
first candidate. The others are drawn from the first-value moment, an important empty
state, a completed result, the core repeated interaction, the paywall where there is
one, meaningful progress or change, and a destructive or recovery action whose feedback
carries the reassurance.

| ID | The moment and its surface | What it should improve | Chosen treatment and medium | How it is judged worth keeping |
| --- | --- | --- | --- | --- |
| DO1 | TBD | TBD | TBD | TBD |

They are opportunities, not features. `None`, with the reason, is a valid answer for a
row and for the whole table, and a moment answered by the simplest native UI is answered
correctly. Nothing is added to a screen because this table exists: premium here means
resolved rather than decorated, and a screen that needed nothing is finished once it is
clear.

Native first, and a bespoke asset only where native cannot express it. SF Symbols and
symbol effects, transitions and matched geometry, SwiftUI animation, a custom `Shape` or
`Canvas`, gradients and materials where [Visual direction](#visual-direction) asks for
them, the system controls, and sensory feedback adapt to state, appearance, Dynamic
Type, and accessibility on their own, which is why they are the first choice rather than
the fallback. A bespoke asset records why native was insufficient, exactly as
[Components and system controls](#components-and-system-controls) requires of a custom
control.

### Bespoke visual assets

An illustration, empty-state artwork, a hero or completion visual, a branded shape, or a
subtle texture is kept only where every line below holds:

- it matches the personality [Visual direction](#visual-direction) states;
- it communicates something useful, or creates delight the moment has earned;
- it does not read as generic, stock, templated, or obviously generated;
- its visual weight does not overpower the interface around it;
- it works in the real layout, and scales and crops correctly at every supported size;
- it works in every appearance this product supports;
- it carries no text that should be real, localizable UI text;
- no simpler native solution would do the job better.

One strong asset is worth more than several decorative ones, so a weak one is
regenerated or removed rather than kept because it already exists. An accepted asset
lives in the application's normal asset structure under a deterministic name, in an
iOS-friendly format, at no more resolution than it needs, with transparency preserved
where that matters and no device-specific dimension hard-coded. Everything needed to
render it is committed: displaying static product artwork never calls an
image-generation service at runtime, and an intermediate generation is committed only
where it is deliberately useful source material.

## Semantic colors

Name by role, never appearance. Define each token once in the asset catalog with
light, dark, and contrast-checked variants; do not put raw RGB values in views.

| Token | Role | Light | Dark | Contrast checked |
| --- | --- | --- | --- | --- |
| `background.primary` | Main canvas | TBD | TBD | TBD |
| `background.secondary` | Grouped surface | TBD | TBD | TBD |
| `background.elevated` | Raised surface | TBD | TBD | TBD |
| `text.primary` | Main content | TBD | TBD | TBD |
| `text.secondary` | Supporting content | TBD | TBD | TBD |
| `accent` | Primary action/selection | TBD | TBD | TBD |
| `destructive` | Destructive action | TBD | TBD | TBD |
| `success` | Successful state | TBD | TBD | TBD |
| `warning` | Warning state | TBD | TBD | TBD |
| `separator` | Structure | TBD | TBD | TBD |

Color never carries meaning alone; pair it with text, iconography, shape, or
position. Check contrast against the actual background in both appearances.

## Typography and layout

| Token | Dynamic Type style | Weight | Use |
| --- | --- | --- | --- |
| `title` | TBD | TBD | TBD |
| `heading` | TBD | TBD | TBD |
| `body` | TBD | TBD | TBD |
| `caption` | TBD | TBD | TBD |
| `numeric` | TBD | TBD | TBD |

Use semantic Dynamic Type styles, never fixed point sizes. A custom font must cover
every shipped language and scale correctly. Line limits are deliberate; the layout,
not Dynamic Type, changes when text grows.

| Spacing token | Value | Use |
| --- | --- | --- |
| `xs` | TBD | TBD |
| `sm` | TBD | TBD |
| `md` | TBD | TBD |
| `lg` | TBD | TBD |
| `xl` | TBD | TBD |

Record the base unit, screen-edge margin, related-element gap, section gap, content
widths, safe-area behavior, keyboard avoidance, and layout at the smallest device.
Text reflows without clipping at the largest accessibility size.

## Components and system controls

| Component | Variants | Required states | Notes |
| --- | --- | --- | --- |
| Primary button | TBD | default, pressed, disabled, loading | stable size while loading |
| Secondary/destructive button | TBD | default, pressed, disabled | TBD |
| Text field | TBD | empty, focused, filled, error, disabled | TBD |
| List row | TBD | default, selected, swiped, disabled | TBD |
| Empty/loading/error surface | TBD | every applicable interface state | TBD |

Prefer native navigation, lists, toggles, pickers, alerts, sheets, swipe actions,
refresh, search, sharing, and purchase surfaces. A custom control records why a
system control is insufficient and must match it for labels/traits, Dynamic Type,
dark mode, right-to-left, keyboard, Switch Control, hit targets, and expected
gestures.

## Motion and haptics

| Motion question | Answer |
| --- | --- |
| Purpose | TBD |
| Standard duration and curve | TBD |
| What animates / never animates | TBD |
| Reduce Motion equivalent | TBD |

Motion explains hierarchy or state; it does not merely decorate. Reduce Motion
uses an equivalent such as a cross-fade without losing information.

Motion is interaction design, so what it communicates is a state change, hierarchy,
continuity, cause and effect, progress, completion, a reveal, or navigation context.
Short and responsive beats elaborate. Looping decoration, animation on every element, a
spring chosen for its own sake, and motion that delays a result the person is waiting
for all cost more than they return.

| Event | Haptic | Why |
| --- | --- | --- |
| TBD | TBD | TBD |

Haptics confirm meaningful results, respect system settings, and are never the
only signal.

## Accessibility

The universal baseline applies to every surface:

| ID | Requirement |
| --- | --- |
| AX1 | Every interactive element has an accurate action label, value, hint when needed, and trait |
| AX2 | Every state-bearing element announces that state; asynchronous errors and important changes are announced |
| AX3 | VoiceOver reaches every control in logical visual order |
| AX4 | Nothing is conveyed by color alone |
| AX5 | Text meets WCAG AA: 4.5:1 body and 3:1 large; non-text indicators meet 3:1 |
| AX6 | Every tap target is at least 44×44 points |
| AX7 | Largest accessibility Dynamic Type works without clipped or truncated essential text |
| AX8 | Reduce Motion has a non-moving equivalent and motion is never essential |
| AX9 | No flashing or strobing content |
| AX10 | Decorative images are hidden from assistive technologies |
| AX11 | Modals move focus appropriately and return it on dismissal |
| AX12 | Keyboard, Switch Control, focus, Reduce Transparency, Increase Contrast, Bold Text, and Button Shapes remain usable |

Project-specific requirements beyond this baseline are recorded with their reason
and approving decision. The accessibility audit walks every primary journey with
VoiceOver and the largest text size.

## Localization

| Question | Answer |
| --- | --- |
| Languages built by the milestones | English only |
| Planned languages | TBD — added after release readiness, never inside a milestone |
| Right-to-left support | TBD |
| Dates, numbers, currency, units | system locale formatting |
| Pluralization | string-catalog variations |
| Longest expansion assumption | at least 40% over English |
| Tone/formality | TBD |

Every visible string comes from localization resources. Never concatenate sentence
fragments or interpolate counts into English grammar. Layouts survive expansion;
right-to-left uses leading/trailing, directional system images, and mirrored layout.
Review translations in context, in the running app.

The milestones build, audit, and verify one language, English. What they settle is the
structure a translation needs — resources, expansion allowance, plural handling,
right-to-left — not the translations themselves. Every further language is added
after the English candidate reaches `READY_FOR_HUMAN`, one worktree per
language, as `AI/WORKFLOW.md` describes. Which languages those are is a decision the
developer makes then, not one the milestone plan carries.

## Appearance and device coverage

| Question | Answer |
| --- | --- |
| Light and dark appearance | TBD |
| Elevation and imagery variants in dark mode | TBD |
| Smallest supported screen | TBD |
| Largest supported layout / iPad behavior | TBD |
| Orientation and multitasking policy | TBD |
| Screens that reflow vertically at large text | TBD |
| Text that may truncate / must never truncate | TBD |

Both appearances are first-class and are not simple inversions. Fixed-height text
containers and fixed-width labels are avoided. Record behavior for Reduce Motion,
Increase Contrast, Reduce Transparency, Bold Text, and Button Shapes.

## Prohibited patterns

- Decoration standing in for resolution — a gradient, blur, card, shadow, or
  animation added to a screen whose hierarchy, spacing, or copy is the real problem.
- Two controls competing to be the primary action, or a screen with no obvious one.
- An action that produces no acknowledgement, or feedback slow enough to read as a
  defect.
- Animation that delays a result the person is waiting for, or a haptic fired for a
  result that did not matter.
- Raw hard-coded color values in views or meaning carried only by color.
- Fixed point fonts, disabled Dynamic Type, or fixed-height containers around
  scalable text.
- Tap targets under 44×44 points, unlabeled icon-only actions, or illogical focus.
- Motion that cannot be reduced, information conveyed only by motion/haptics, or
  flashing/strobing content.
- Placeholder/debug/lorem ipsum copy or user-facing text baked into images.
- Artwork that reads as generic, stock, templated, or obviously generated, or an asset
  whose only purpose is filling empty space.
- Artwork whose visual weight overpowers the interface it sits in, or an illustration
  and icon style that changes between screens.
- Artwork the committed application cannot render on its own — static product imagery
  fetched from an image-generation service at runtime.
- A custom control replacing a system control without a documented reason and
  equivalent accessibility/platform behavior.
- Hidden, tiny, delayed, or disguised dismissal; irreversible dismissal traps.
- Paywall countdowns, fake scarcity, ambiguous recurring terms, hard-coded prices,
  obstructed restore, or a subscription presented as a one-time purchase.
- An invented reference price — a crossed-out original, regular, or MSRP figure no
  StoreKit product charges — or a saving that is not the real difference between two
  real prices.
- An introductory or promotional offer shown without its duration and the price that
  applies when it ends, or a renewal price made less prominent than the offer price.
- A sentiment gate before the rating prompt — asking how the person feels and
  showing it only to the happy ones — a custom dialog imitating or preceding the
  system prompt, or any reward offered for a rating.
- A review request during onboarding, an error, or a purchase flow, one triggered
  by a tap on an unrelated control, or a second one in the same app version.
- Legal or support links reachable only from the paywall, or only after a purchase,
  an account, or a granted permission.
- A privacy, terms, or support link that opens a page describing a different app, a
  generic company site, or nothing at all.
- A premium override that ships — one reachable in a Release build, keyed to a launch
  argument, an environment variable, or a build setting rather than `#if DEBUG`, or
  reached through a debug menu, a hidden gesture, or a screen of its own.

## Unresolved design decisions

| ID | Question | Options | Blocks | Developer decision needed |
| --- | --- | --- | --- | --- |
| D-U1 | TBD | TBD | TBD | TBD |
