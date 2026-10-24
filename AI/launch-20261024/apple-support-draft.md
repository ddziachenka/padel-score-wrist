# Apple Developer Support inquiry — sent 2026-10-24

Owner explicitly authorized sending this prepared message. Submitted through Apple Developer Support → App Review → Other App Review questions → Email, with platform watchOS and app ID 6825393194. Confirmed case ID: **103007020727**. The exact message below was sent; confirmation is preserved in `.artifacts/asc-launch-20261024/evidence/apple-support-confirmation.png`.

Subject: First non-consumable IAP blocked for a Watch-only app despite watchOS IAP documentation

Hello Apple Developer Support,

Please clarify the supported submission path for the first non-consumable In-App Purchase in our Watch-only app. We want to preserve the Watch-only product format and submit the app and its lifetime unlock together.

- App: Padel Score — Wrist, Apple ID 6825393194.
- Version: 1.0, build 1. The uploaded build completed processing with status VALID.
- Build ID: c335c85e-bba0-4d36-894a-7675626e93e4.
- Container bundle: com.dziachenka.padelscore.
- Watch app bundle: com.dziachenka.padelscore.watchkitapp.
- Non-consumable product: com.dziachenka.padelscore.lifetime, Apple ID 6825393394.
- IAP version: d96baf47-39f7-4632-856e-b2cd28ec458f.
- Draft submission: 17c2964a-e72b-4558-983f-4a40c5545d9f, containing the app version and IAP version. Both items report READY_FOR_REVIEW. The submission has not been sent.

The submission dialog disables Submit for Review and says:

> In-app purchases and subscriptions are currently not supported on Apple Watch.

It then requires removing all in-app purchases or subscriptions from this submission.

The App Store Connect help page “Submit an In-App Purchase” both requires the first non-consumable to accompany an app version and says Apple Watch app versions must remove IAPs from the submission:
https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/

However, “Creating independent watchOS apps” explicitly describes in-app purchases directly on Apple Watch, including in its discussion of Watch-only apps:
https://developer.apple.com/documentation/watchos-apps/creating-independent-watchos-apps/

The app uses StoreKit 2 Product.products(for:), purchase(options:), current entitlements, transaction updates, and restore. Local Xcode StoreKit tests verify cancellation, purchase, restoration, relaunch and entitlement retention after a price change. These local tests are not evidence of App Review environment availability; that is precisely what we need a supported submission path to validate. No local StoreKit configuration or test bundle is included in the distribution IPA.

Free/Paid Apps agreements, banking, tax forms and DSA status are active. The app and IAP are configured for 175 regions. The app download is free. The existing non-consumable is temporarily priced at zero for a launch promotion; claiming it requires confirming an App Store purchase and grants permanent access. It is not an auto-renewing subscription or a seven-day access trial.

Could you please confirm:

1. How should a Watch-only app submit its first non-consumable IAP when these two validation rules conflict?
2. Can your team enable/review the existing app and IAP together, or provide another supported submission sequence without adding an iPhone companion?
3. If a companion app is required, is that a current distribution limitation despite the watchOS StoreKit documentation?

We can provide the screenshot of the blocked submission and the exact validation state. Please preserve this draft and its IAP; we do not want to release an app whose lifetime purchase is unavailable to customers.

Thank you.
