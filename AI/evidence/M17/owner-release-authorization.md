# Owner release authorization — 2026-10-24

The owner requested:

> Проведи отдельную Release Readiness Revalidation новой сборки с уже согласованными исключениями и проверить можешь через установленоое приложение TestFlight на телефоне, затем загрузи её в App Store Connect и отправь приложение вместе с lifetime-покупкой на ревью.

This directly authorizes the separate six-domain revalidation, new candidate gates,
TestFlight check, signed upload and ordinary app plus existing first lifetime IAP
submission. It carries the exact M16 exceptions from
AI/evidence/M16/owner-acceptance-20261024.md into this release work. No new acceptance
is inferred for additional failures. Raw gate results remain truthful; owner-approved
submission disposition is distinct from an automated READY_FOR_HUMAN verdict.

The repository's required ordering is represented by M17 six current domain audits,
then M18 candidate-bound readiness. These are sequential phases of the owner's
explicit end-to-end request, with no product implementation expansion or delegation.
Historic M10 and M16 records stay unchanged. Owner again confirmed phone connected,
unlocked, then locked its screen for normal iPhone Mirroring; no lock bypass.
