# M10 — Final Product Polish

**ID:** M10
**Status:** IN_PROGRESS
**Depends on:** M00, M01, M02, M03, M04, M05, M06, M07, M08, M09
**Validation:** make milestone ID=M10
**Handoff:** AI/handoffs/M10-handoff.md
**Audit prompt:** AI/prompts/final-polish.md
**Audit record:** AI/audits/M10-final-polish.md

## Objective

Проверить готовое английское Watch-приложение целиком и получить READY_FOR_HUMAN для точного кандидата.

## Scope

- Следовать AI/prompts/final-polish.md: один последовательный полный проход Functional Correctness, UI / UX, Content / Copy, Accessibility, Product Experience, Release / App Store / Privacy / Monetization.
- Исправить каждый воспроизводимый P0/P1 в этой же сессии; брать только явно полезные безопасные P2. Затем один targeted re-audit изменённого поведения без третьего полного прохода.
- Проверить на реальных часах запись очка на корте, читаемость, haptics, возврат после опускания руки, offline recovery, VoiceOver, Crown и sandbox purchase/restore при lifetime IAP. Минимальная ОС и компактный экран требуют собственного evidence; новый runtime не заменяет старый.
- Заполнить ровно один консолидированный AI/audits/M10-final-polish.md из templates/final-polish-audit-template.md; охватить все применимые типизированные строки Config/release-requirements.v3.tsv и каждый канал/домен.
- На clean REVIEW commit выполнить make milestone ID=M10, затем без изменения кода/конфигурации make release CANDIDATE=<полный verified SHA>; записать результат и остановиться для субъективного review владельца.

## Non-goals

- Переводы, новая продуктовая функциональность, новые audit циклы или этапы после M10 в этом плане.
- Автоматический Archive/upload/submit/publish и трактовка READY_FOR_HUMAN как разрешения на отправку.

## Acceptance criteria

- [ ] Все M00–M09 DONE с собственным evidence; все применимые H-решения закрыты, неизвестные коммерческие значения не замещены примерами.
- [ ] Шесть доменов пройдены в требуемом порядке одной Builder-сессией; исправлены все valid P0/P1, после изменений выполнен один targeted re-audit.
- [ ] Один consolidated record имеет COMPLETE typed coverage, Open P0/P1 0, findings/fixes/deferred P2, INAPPLICABLE с причинами, FUTURE_PRODUCT_IDEA и точные SHA/команды/counts/пути.
- [ ] Нет пропущенной обязательной среды/устройства; реальные часы и минимальная поддерживаемая конфигурация проверены. Недоступность необходимого evidence блокирует этап.
- [ ] Watch-only REL-208 и REL-209 явно INAPPLICABLE с причиной; неиспользуемые HealthKit/account/cloud/notifications так же оцениваются по применимости, а не молча пропускаются.
- [ ] make milestone ID=M10 проходит и make release CANDIDATE=<verified-full-SHA> возвращает READY_FOR_HUMAN для того же commit.
- [ ] После записи DONE и handoff выполнены make static, project-status validate и continuity от verified SHA; никакая отправка или публикация не выполнена.

## Validation

`make milestone ID=M10`. Обязательные проверки и evidence выполняются в одной Builder-сессии.

## Handoff

Записать `AI/handoffs/M10-handoff.md` по компактному шаблону: полный SHA, точные команды, exit codes, UTC time, report paths, counts, известные ограничения и следующий шаг. После доказанного DONE остановиться.
