# Watch-only first IAP: supported paths and alternatives

Research date: 2026-10-24. Scope: investigate the owner's request for a simple
workaround. This record does not authorize a new product model, companion app,
configuration change, or a bypass of App Store Connect validation.

## Conclusion

No confirmed, publicly documented simple workaround was found that preserves all
three approved conditions: Watch-only, free download, and a first non-consumable
lifetime IAP. Similar developers report the identical submission block. The
recommended next step remains Apple case **103007020727**, already sent with owner
authorization. Apple's supported submission path is still unknown.

## What the evidence shows

- [Exact matching Apple Developer Forums report, August 2026](https://developer.apple.com/forums/thread/842983):
  a standard Watch-only container and first non-consumable unlock encounter the
  same prohibition. Earlier submissions reached review but the product did not
  load there. Another developer reports the same missing product after submission.
  The single expanded comment asks how that submission was made; it supplies no
  solution. No accepted solution or Apple staff answer was visible on inspection.
  These are developer reports, not Apple confirmation of the root cause.
- [Related first-submission report, May 2026](https://developer.apple.com/forums/thread/827141):
  the purchase worked in TestFlight but could not be retrieved in review. An Apple
  DTS engineer directed the developer to a code-level support ticket. This supports
  escalation to technical support; it does not establish a configuration fix.
- [ASC first-IAP submission rules](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/):
  the first product of each IAP type must accompany a new app version. The same
  page instructs developers to remove IAPs from an Apple Watch submission.
- [Apple's independent watchOS app documentation](https://developer.apple.com/documentation/watchos-apps/creating-independent-watchos-apps):
  describes direct purchases on Apple Watch and the standard Watch-only packaging
  container. Consequently, interpreting the ASC message as proof that watchOS has
  no StoreKit purchase support would be incorrect. A distribution-workflow
  conflict is an inference; Apple has not confirmed the cause in our case.

## Comparison

| Option | Assessment | Effect on the approved product |
| --- | --- | --- |
| Apple supplies a supported path or corrects the account/submission state | Preferred. Existing case is open; a backend correction is a request, not a promised capability. DTS escalation is supported by the related staff response. | Can preserve every approved condition. No further outbound message has been sent. |
| Submit the IAP by itself, or release the app first and add its first IAP later | Not a documented solution. The first product of this type still needs a new app version; prior app approval alone does not waive that rule. | The current five-game limit would also leave users without the intended unlock if released without a usable IAP. Not applied. |
| Sell the full app itself, with a free launch period followed by $4.99 | My assessment: the simplest alternative architecture because it removes this IAP submission dependency. Apple documents scheduled app prices. Actual review acceptance is not guaranteed. | Preserves Watch-only, but replaces free download plus IAP with paid download after the offer. Requires removing the five-game limit/purchase gate, updating copy and pricing automation, and a newly verified milestone. Not authorized or applied. |
| Add a useful iPhone companion and submit an iOS app with its Watch counterpart | Documented app structure; a candidate alternative rather than a proven cure for this exact submission. The Watch app can still run independently. More implementation and store work than app-level pricing. | Changes the approved Watch-only product. Requires an owner decision and newly verified milestone. A blank placeholder or changing only classification flags is not an established solution. |
| Remove an IAP capability, flip Watch-only flags, change submission order, or recreate the draft | No verified fix found. The matching forum author explicitly does not establish causation between a capability change and the block. Our Xcode project already has no explicit In-App Purchase SystemCapabilities entry to remove. | Flag changes would alter packaging and require verification; no speculative rebuild or draft mutation was performed. |

For the paid-app alternative, [Apple supports scheduling app price changes](https://developer.apple.com/help/app-store-connect/manage-app-pricing/schedule-price-changes-for-apps/).
The intended replacement offer would make the complete app free on launch day and
the following seven full days, then charge new customers for download. It would
not be an in-app lifetime claim. Apple's [Watch download guidance](https://support.apple.com/en-ca/109023)
also describes redownloading acquired apps without paying again. This alternative
would need its own end-to-end checks before release.

The companion structure and independent operation are described in the watchOS
documentation above and [ASC platform guidance](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-platforms/).

## Local checks and handoff

Research began at clean main commit
`5e8f8f54d15d22b90379bfc66d55d3f7c55a7c57`. Read-only inspection of
`App/PadelScore.xcodeproj/project.pbxproj` found the expected WKWatchOnly settings
and no explicit InAppPurchase/SystemCapabilities entry. Previously inspected
archive flags remain documented in the launch evidence. No app source,
entitlements, build settings, IAP association, price, or external submission was
changed during this research.

Actual launch state remains **READY_FOR_REVIEW, not submitted**. Version 1.0 (1),
14 locales, 84 screenshot placements, 28 creative placements and zero IAP prices
in 175 regions are saved. No publication or offer-end date is confirmed. The
authorized hourly monitor checks the release and only Gmail messages for Apple
case 103007020727; it sends no automatic replies.

Recommendation: await the existing Apple response before changing the product. If
Apple cannot provide a supported Watch-only/IAP path, compare paid download against
a real iPhone companion with the owner. Preserve the saved launch package and
already-authorized submission intent. Full evidence: [launch handoff](../handoffs/ASC-launch-20261024.md).
