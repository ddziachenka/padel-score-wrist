# M16 — Compact iPhone Companion

**ID:** M16
**Status:** BLOCKED
**Depends on:** M10, M15
**Validation:** make milestone ID=M16
**Handoff:** AI/handoffs/M16-handoff.md

## Objective

Полезный iPhone-компаньон знакомит с приложением, даёт попробовать Match и
Americano и оформить общий lifetime, сохраняя самостоятельную работу Apple Watch.
Владелец явно утвердил этот контракт 2026-10-24 командой IMPLEMENT THIS PLAN.

## Scope

- iOS 17+, watchOS 10+, iPhone; три вкладки Start, Demo, Access; первый запуск Start.
- Start: установка и использование Watch, очки, Undo, подача, оба режима, launcher;
  Support/Privacy/Terms; реальные игры явно обозначены как функция Apple Watch.
- Match demo: существующий Golden point 2–2, 40–30, подаёт You; один гейм,
  начисление обеим командам, подача, Undo и Reset.
- Americano demo: до 24 суммарных очков, 10–10, по два розыгрыша подачи,
  Partner подаёт первый розыгрыш блока; четыре оставшихся розыгрыша и ничья.
- Настоящие общие движки; только in-memory demo state; постоянная метка Demo;
  смена режима, выход из вкладки и холодный запуск сбрасывают пример. Не изменять
  Watch-игру, историю, настройки, usage ledger или entitlement.
- Общая существующая non-consumable покупка и bundle IDs; StoreKit price,
  cancellation/pending/error/retry/restore/revocation; можно купить до установки
  на Watch с пояснением. Не показывать на iPhone остаток Watch free games.
- Локальные StoreKit-verified entitlement на каждом устройстве; refresh на запуске,
  foreground, updates и restore; часы работают офлайн после получения права.
- Black/lime, native navigation, light/dark, accessibility и все существующие языки.
- Ручная оценка; системный запрос после завершения обоих демо и использования
  в другой день, вне покупки/onboarding, максимум одна попытка за 365 дней.
- Настоящий iOS executable вместо Watch-only container; независимый Watch с
  companion ID; существующий launcher; matching version/build; без test hosts в IPA.
- Два явных профиля iOS/watchOS и managed bindings, separate schemes/xcresults;
  полный прежний Watch suite обязателен. Ошибка/отсутствие/skip любой обязательной
  платформы означает failure. Regression coverage инфраструктуры через self-test.
- Четыре настоящих iPhone screenshot 1320×2868 без alpha для каждой из 14 ASC
  локалей; provenance/SHA; проверка прежних Watch/Header/Search материалов.
  Обновить локальные store/site/review drafts и монитор новой сборки.
- Launch offer: бесплатное скачивание; 5 completed Watch games; lifetime 0
  в 175 регионах в день публичного выхода + семь полных дней, затем exact baseline
  regional prices ($4.99 US). Sandbox/TestFlight не запускают отсчёт акции.

## Non-goals

- Реальные матчи на iPhone, перенос/синхронизация истории, remote scoring, аккаунты,
  backend, Watch Connectivity как условие работы или источник entitlement.
- Новая покупка или новая ASC app record; изменение правил существующих матчей.
- Перенос исторического release approval на новый код; отправка новой сборки до
  отдельной Release Readiness Revalidation. Загрузка тестовой сборки разрешена.

## Acceptance criteria

- [ ] Три iPhone вкладки доступны без обязательного онбординга/paywall; законченный
      интерфейс и обе темы проверены на маленьком и большом экранах во всех языках.
- [ ] Оба фиксированных демо используют реальные движки и точно поддерживают
      очки/подачу/Undo/Reset/конец/сброс навигацией; реальные данные не изменяются.
- [ ] Общая покупка проверяется StoreKit; 0/paid price, cancel/pending/error,
      relaunch/restore/refund и право после возврата цены покрыты тестами.
- [ ] На физической паре проверены iPhone→Watch и Watch→iPhone purchase/restore,
      переустановка и самостоятельная работа Watch без iPhone-приложения/связи.
      Владелец подключит пару; отсутствие фактического evidence блокирует DONE.
- [ ] VoiceOver, AX Dynamic Type, Reduce Motion, locale layouts, iOS17/watchOS10
      и актуальные доступные runtimes проверены; minimum tap targets соблюдены.
- [ ] Архив содержит настоящий iOS app, independent Watch и launcher с правильными
      ID/version/build и не содержит test hosts/local StoreKit config.
- [ ] Старый полный Watch suite и новый полный iOS suite проходят; missing/zero/
      failed/skipped mandatory tests отвергаются; meaningful harness self-tests pass.
- [ ] 14 комплектов iPhone screenshot и актуальные store/site/review материалы
      подготовлены; существующие assets сохранены; launch monitor учитывает M16.
- [ ] make static, make site-check и make milestone ID=M16 проходят на clean
      REVIEW SHA. make self-test проходит на byte-matched generic tooling в
      одобренной владельцем M00 fixture; все Padel-specific guards и regression
      tests отдельно обязательны в primary static/site gates. Точные SHA,
      manifests/counts/exit codes/limitations записаны в handoff.

## Validation

`make milestone ID=M16` runs both platform profiles. Also `make static`,
`make site-check`, `make self-test`; targeted minimum-OS and actual-device checks.
No old binary evidence substitutes for new candidate evidence.

## Handoff

Record exact SHA, all command exit codes, timestamps, per-platform xcresult counts,
actual hardware evidence and asset manifest. Mark DONE only after all required
coverage. After DONE/continuity, stop the Builder session. A separate readiness
revalidation establishes the next distributable candidate.

## Owner-approved tooling fixture clarification — 2026-10-24

The owner explicitly approved repeating the documented M00 temporary template
procedure without changing assertions. Direct product-root self-test failures are
preserved. Universal shell/Perl tooling runs with original English template inputs;
Padel-specific Python guards require actual App/store assets and run unchanged in
the primary product static/site gates. Neither the generic fixture nor its stubbed
Xcode replaces a real platform suite or physical hardware scenario. Record both
fixture provenance/hash equality and the actual product results. The rejected
proposal for an automatic wrapper was not executed; invocation logic is unchanged.

## Current blocker — 2026-10-24

The complete iOS17 UI suite has two unresolved native Contrast failed audits at
largest text on iPhone SE; no issue or category is waived. The normal Xcode
inspection path cannot run while the Mac is locked. The physical pair is also
unavailable, with fresh bidirectional Sandbox acquisitions/reinstall/Watch-without-
companion and physical accessibility/haptics still incomplete. Resume this same
milestone after manual Mac unlock/pair reconnection and the pending isolated
Sandbox tester choice. Implementation, signed archive and56 native gallery images
are preserved. Exact evidence and remaining gates: AI/handoffs/M16-handoff.md.
