# M08 — Access and Purchase

**ID:** M08
**Status:** PLANNED
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
