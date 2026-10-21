# M08 — Access and Purchase

**ID:** M08
**Status:** BLOCKED
**Depends on:** M07
**Validation:** make milestone ID=M08
**Handoff:** AI/handoffs/M08-handoff.md

## Objective

Применить утверждённую владельцем модель доступа между играми, сохраняя доступность начатой сессии.

## Scope

- Вход: закрыты H4 PRODUCT (модель, цена если платно, лимит/единица и reset-политика если trial). Этап не предполагает конкретный вариант: при бесплатной v1 или платном скачивании источник выдаёт игровой доступ без in-app paywall/trial/override; продажа скачивания настраивается в App Store после решения владельца.
- При выбранной lifetime-модели: один non-consumable StoreKit product, verified entitlement source of truth, Transaction updates, purchase/restore, корректная отзыв/возврат и signed transaction validation.
- Если утверждён trial: выбранная unit и quota задаются одной policy; ledger идемпотентен, отмена/правки/Resume и переустановка обрабатываются строго по утверждённому контракту. Не обещать anti-abuse или перенос trial без выбранного механизма.
- Paywall при попытке новой игры после лимита; уже начатая игра остаётся доступной. Price/terms читаются из StoreKit runtime, отсутствует выдуманная скидка или сравнение.
- Только при lifetime IAP здесь же debug-only premium override в едином entitlement owner; compiled out Release, без отдельной страницы логики во View.
- Английские состояния loading/pending/cancelled/offline/unverified/restored/product unavailable; юридические точки входа представлены интерфейсом и заполняются M09.

## Non-goals

- Подписка или дополнительные товары без явного решения владельца.
- Фиксированные цены в коде/дизайне/критериях; собственный payment backend.

## Acceptance criteria

- [ ] Тестовая матрица соответствует реально утверждённой модели; ни один пункт не выбирает цену, trial limit или единицу за владельца.
- [ ] Для lifetime IAP: покупка/restore/revoked/unverified/pending/offline проверены с StoreKit configuration и доступным реальным устройством; только verified entitlement открывает paid access.
- [ ] Повторное завершение того же sessionID, score correction и Resume не увеличивают usage; paywall не вмешивается в активную игру.
- [ ] Для lifetime IAP debug override отсутствует в Release артефакте и Release UI, не подменяет StoreKit-тесты и не создаёт второй источник entitlement.
- [ ] Для lifetime IAP цена локализована StoreKit; product unavailable не показывает fake price и не мешает восстановлению/обратному выходу; при free решении paywall и override отсутствуют.
- [ ] При платном скачивании нет повторной in-app покупки, пробного ledger и Restore purchases для несуществующего IAP; цена App Store не дублируется статической суммой в UI.
- [ ] Тесты проверяют наблюдаемое поведение и регрессии этого этапа; `make milestone ID=M08` проходит на clean `REVIEW` HEAD с обязательными тестами без failures/skips.

## Validation

`make milestone ID=M08`. Обязательные проверки и evidence выполняются в одной Builder-сессии.

## Handoff

Записать `AI/handoffs/M08-handoff.md` по компактному шаблону: полный SHA, точные команды, exit codes, UTC time, report paths, counts, известные ограничения и следующий шаг. После доказанного DONE остановиться.

## Local environment follow-up — 2026-10-22

The Watch restart repairs empty local currentEntitlements in the isolated
container-ID diagnostic host: three of the four original tests now pass.
The network test still fails because watchOS 27.0.1 converts the injected
network error to StoreKitError.unknown. Five public error-injection variants
reproduce that result directly through Product.purchase(). No assertion or
production error classification was relaxed.

The clean `make milestone ID=M08` at
`52182dfb8bc8380afc9fd1445b6429cbef31a98c` fails four StoreKit tests and three
access UI tests with the shipping `.watchkitapp` identity. It was stopped after
those failures: xcresult reports 340 passed / 8 failed / 0 skipped, including one
canceled UI test; this is incomplete coverage, not a gate pass. The ordinary Watch
app is restored and launches; three backed-up game files match SHA-256. See
[local environment handoff](../handoffs/M08-local-session-handoff.md).

## Earlier verification — 2026-10-21

2026-10-22 update: the `.watchkitapp` identity repair made the real Sandbox
catalog, purchase and restore pass (1/1); identity/policy tests 19/19 and UI 1/1
also pass on hardware. Local Xcode StoreKit controls still open dialogs despite
disableDialogs; the remaining required matrix and clean gate are incomplete.
See [identity repair handoff](../handoffs/M08-sandbox-identity-handoff.md).

Latest follow-up: reinstall with the owner's approval preserved the backed-up
game state and reached the real Sandbox password prompt. Direct Sandbox product
lookup returns no product; login success is unconfirmed. Original local tests
still pass 1/4 after reinstall. The documented Watch IAP submission restriction
also needs clarification. See [StoreKit follow-up](../handoffs/M08-hardware-fix-handoff.md).

Current follow-up: real Watch Ultra 3 / watchOS 27.0.1 is connected. Hardware
access UI 3/3 and policy/ledger/owner 16/16 pass; StoreKit 1/4 passes. Local
verified purchase is missing from current-entitlement APIs, and the injected
network error is generic. M08 remains BLOCKED. Exact evidence and the preserved
historical results are in [hardware handoff](../handoffs/M08-hardware-handoff.md).

H4 закрыт владельцем: пять завершённых игр автоматически, сохранять счётчик при
удалении данных, lifetime non-consumable с ценой из PRODUCT H4;
в UI нет активации или слова trial. Реализация сохранена на `main`.

`make milestone ID=M08` на `5760247a971eecd7151c92209cdd14291c032bd3`:
386 tests, 382 passed, 4 failed, 0 skipped. Все 328 Swift-тестов и 54 UI-теста
прошли; четыре StoreKit-теста не смогли настроить локальную среду
(`SKInternalErrorDomain Code=3`). Это не успешная проверка покупки.

Реальные часы недоступны по ответу владельца. App Store Connect не содержит
записи приложения для заданных bundle IDs; доступная браузерная сессия требует
входа, а API не создаёт приложения. Товар и цена пока заданы только локальной
StoreKit-конфигурацией. Полные команды и evidence — в handoff. M08 не DONE;
все обязательные проверки покупки остаются в этом этапе.

## StoreKit environment repair — 2026-10-21

На watchOS 26.1 (`23S36`) с явным test plan и восстановлением defaults после
симулированной ошибки четыре исходных StoreKit-теста прошли: 4 passed, 0 failed,
0 skipped, xcodebuild exit 0. Evidence:
`.artifacts/M08-storekit-fix/reset-26-1.xcresult`, `reset-26-1.log`.
Assertions и production purchase code не ослаблены. Полный
`make milestone ID=M08` прошёл на clean REVIEW-коммите
`14fffe5b70fcf859841a89c1363992fee313eafc`: exit 0, **386/386** logical tests,
0 failures/skips; expanded device summary 730/730. Report:
`.artifacts/milestone/M08/20261021T140724Z-29203/report.md`.
M08 остаётся BLOCKED: реальные часы по-прежнему недоступны и live App Store
Connect app/IAP ещё не настроены. Подробности и история сравнений — в handoff.

## App Store Connect setup — 2026-10-21

Созданы и проверены app `6825393194` (`Padel Score — Wrist`) и non-consumable
`6825393394` (`com.dziachenka.padelscore.lifetime`). Базовая цена США $4.99 USD;
174 остальных цены Apple рассчитывает автоматически. Владелец отдельно подтвердил
бесплатное скачивание и все 175 регионов; app и IAP availability сохранены.
Английская локализация, review notes и настоящий снимок 368×448 сохранены;
снимок обработан с `COMPLETE`, товар — `READY_TO_SUBMIT`. Версия приложения —
`PREPARE_FOR_SUBMISSION`; review submissions пусты. Ничего не отправлено на ревью.

Дополнительный запуск исходных StoreKit purchase/restore/refund и sixth-game UI
тестов на managed Watch SE 2 44 mm / watchOS 26.1: exit 0, 2 passed, 0 failed/skipped.
Он нужен для снимка; не заменяет полный gate на `14fffe5b70fcf859841a89c1363992fee313eafc`.
Исходные Config и managed binding 40 mm восстановлены. App/build inputs не менялись.
M08 остаётся BLOCKED только по обязательным реальным часам; H1 и минимальная
watchOS 10 остаются отдельными проектными зависимостями. Evidence — в handoff.
