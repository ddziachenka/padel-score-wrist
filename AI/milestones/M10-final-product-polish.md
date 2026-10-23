# M10 — Final Product Polish

**ID:** M10
**Status:** REVIEW
**Depends on:** M00, M01, M02, M03, M04, M05, M06, M07, M08, M09
**Validation:** make milestone ID=M10
**Handoff:** AI/handoffs/M10-handoff.md
**Audit prompt:** AI/prompts/final-polish.md
**Audit record:** AI/audits/M10-final-polish.md

## Objective

Проверить готовое многоязычное Watch-приложение целиком (английский и 12 добавленных локалей) и получить READY_FOR_HUMAN для точного кандидата.

## Scope

- Следовать AI/prompts/final-polish.md: один последовательный полный проход Functional Correctness, UI / UX, Content / Copy, Accessibility, Product Experience, Release / App Store / Privacy / Monetization.
- Исправить каждый воспроизводимый P0/P1 в этой же сессии; брать только явно полезные безопасные P2. Затем один targeted re-audit изменённого поведения без третьего полного прохода.
- Проверить на реальных часах запись очка на корте, читаемость, haptics, возврат после опускания руки, offline recovery, VoiceOver, Crown и sandbox purchase/restore при lifetime IAP. Минимальная ОС и компактный экран требуют собственного evidence; новый runtime не заменяет старый.
- Заполнить ровно один консолидированный AI/audits/M10-final-polish.md из templates/final-polish-audit-template.md; охватить все применимые типизированные строки Config/release-requirements.v3.tsv и каждый канал/домен.
- На clean REVIEW commit выполнить make milestone ID=M10, затем без изменения кода/конфигурации make release CANDIDATE=<полный verified SHA>; записать результат и остановиться для субъективного review владельца.

## Non-goals

- Выполнение переводов внутри M10, новая продуктовая функциональность и новые audit циклы. Переводы выполняются отдельными языковыми потоками до M10; итоговый аудит охватывает все добавленные локали. Функции плана покупки реализуют M11–M15 (исключение владельца ниже), не M10.
- Автоматический Archive/upload/submit/publish и трактовка READY_FOR_HUMAN как разрешения на отправку.

## Acceptance criteria

- [x] Все M00–M09 DONE с собственным evidence; все применимые H-решения закрыты, неизвестные коммерческие значения не замещены примерами.
- [x] M11, M12, M13, M14 и M15 DONE с собственным evidence до возобновления итоговой проверки; финальный проход выполняется на приложении с их изменениями.
- [x] Быстрый запуск с циферблата и Smart Stack (M14) проверен на реальных часах вместе с прежними аппаратными проверками.
- [x] Итоговый кандидат включает английский и все 12 добавленных локалей; проверены многоязычный интерфейс, доступность, сайт, материалы магазина и происхождение скриншотов. Реальное озвучивание VoiceOver подтверждено на часах.
- [x] Шесть доменов пройдены в требуемом порядке одной Builder-сессией; исправлены все valid P0/P1, после изменений выполнен один targeted re-audit.
- [x] Один consolidated record имеет COMPLETE typed coverage, Open P0/P1 0, findings/fixes/deferred P2, INAPPLICABLE с причинами, FUTURE_PRODUCT_IDEA и точные SHA/команды/counts/пути.
- [x] Нет пропущенной обязательной среды/устройства; реальные часы и минимальная поддерживаемая конфигурация проверены. Недоступность необходимого evidence блокирует этап.
- [x] Watch-only REL-208 и REL-209 явно INAPPLICABLE с причиной; неиспользуемые HealthKit/account/cloud/notifications так же оцениваются по применимости, а не молча пропускаются.
- [ ] make milestone ID=M10 проходит и make release CANDIDATE=<verified-full-SHA> возвращает READY_FOR_HUMAN для того же commit.
- [ ] После записи DONE и handoff выполнены make static, project-status validate и continuity от verified SHA; никакая отправка или публикация не выполнена.

## Validation

`make milestone ID=M10`. Обязательные проверки и evidence выполняются в одной Builder-сессии.

## Handoff

Записать `AI/handoffs/M10-handoff.md` по компактному шаблону: полный SHA, точные команды, exit codes, UTC time, report paths, counts, известные ограничения и следующий шаг. После доказанного DONE остановиться.

## Owner exception — purchase-appeal milestones, 2026-10-22

The owner approved [the purchase-appeal plan](../purchase-appeal-plan.md): milestones
M11–M15 are implemented while M10 is still `BLOCKED`, and the final polish then resumes
on the updated application. This is a recorded exception to the plan order, not a
dependency waiver and not a change to any validator.

- M10 keeps `**Depends on:** M00 … M09` unchanged. `project-status.sh validate` requires
  the Final Product Polish milestone to depend on exactly every earlier-numbered
  milestone, so M11–M15 cannot be listed there. Their completion is instead an explicit
  precondition above: M10 does not return to `IN_PROGRESS` until M11, M12, M13, M14 and
  M15 are all `DONE`.
- M10 is not marked `DONE`, renumbered or reused. The 2026-10-22 simulator evidence in
  `AI/handoffs/M10-handoff.md` and `AI/audits/M10-final-polish.md` stays as the
  historical record of `2f9d1e1d94c0ef1394bc43f7ac82de8ae57ca11d` and earlier SHAs; it
  is never presented as evidence about the application after M11–M15.
- When M10 resumes, every domain whose behavior M11–M15 changed is audited again on the
  new SHA, the remaining hardware checks (on-court use, spoken VoiceOver, Always On / Low
  Power, oldest-device launch performance, StoreKit under an adverse network) and the
  new watch-face launcher are checked on real Watches, and new evidence binds to the new
  SHA. Then `make milestone ID=M10` runs on a clean `REVIEW` commit and
  `make release CANDIDATE=<verified-full-SHA>` on that same SHA.
- A required environment that is still unavailable keeps M10 `BLOCKED` with the concrete
  blocker; release readiness is not declared.

## Owner exception — localization before M10, 2026-10-23

The owner explicitly approved implementation of the 11-language localization plan
before M10: es, it, fr, pt-PT, pt-BR, nl, de, sv, da, fi, nb, ru, in addition to en.
The Portuguese language task owns its two locale worktrees sequentially. The
coordinator prepares shared infrastructure on main, freezes one baseline SHA, then
each language works independently. App Store and IAP copy is prepared as local
reviewable drafts under AI/localization; nothing is uploaded or published. This
explicit product exception overrides the English-only timing and store-draft
exclusions in the generic localization prompts, not any verification requirement.

Localization is not a milestone and does not complete or reopen another one.
M10 audits the integrated multilingual candidate. Every applicable language and
layout check remains required; real-Watch evidence is still mandatory, and M10
remains BLOCKED until that evidence exists. Earlier evidence describes its own SHA.
The coordinator performs a full editorial second pass after the language agents.
All routes, screenshots and store drafts are validated before delivery. No App
Review submission, App Store Connect upload or site publication is authorized.

## Completion resumption — 2026-10-23

Owner explicitly confirmed «на физическом устройстве все проверено»; scope and evidence limits recorded in `AI/evidence/M10/device-confirmation.md`. All earlier physical blockers are resolved by that owner-observed report, without invented measurements. M11–M15 and localization preparation are complete. Six-domain consolidated record refreshed in order with exact current source evidence. New live privacy/history mismatch was corrected by owner-approved production site deployment; 131/131 public source hashes matched. M10 is REVIEW for its unchanged full milestone and release gates; DONE only after their actual pass.
