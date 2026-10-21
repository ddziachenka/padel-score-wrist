# M09 — Legal and Support

**ID:** M09
**Status:** BLOCKED
**Depends on:** M08
**Validation:** make milestone ID=M09
**Handoff:** AI/handoffs/M09-handoff.md

## Objective

Предоставить понятные сведения о продукте, privacy, terms и поддержке прямо на часах и по публичным адресам.

## Scope

- Вход: H1 даёт утверждённые имя владельца, контакт и публичный домен. Фактическая data/commerce модель предыдущих этапов зафиксирована.
- Четыре продуктовые страницы Web/: home, privacy, terms, support на английском. /terms ссылается на Apple Standard EULA; собственную лицензию не писать.
- Заполнить SUPPORT_SITE_URL, SUPPORT_EMAIL, DEVELOPER_NAME в Config/project.env, используя предоставленные значения, не выдумывая реквизиты.
- About/Settings: читаемые offline on-watch Privacy/Terms/Support, соответствующие URL и адрес поддержки; не предполагать браузер или приложение на iPhone. Формат отображения длинных URL адаптировать без скрытия назначения.
- При наличии paywall — Terms и Privacy доступны с него, без блокировки покупкой. Содержимое соответствует локальному хранению/сетевым действиям без ложных обещаний.
- Подготовить site-check и инструкцию публикации. Сам сайт публикует владелец; перед milestone/release evidence проверить доступность утверждённых публичных страниц.

## Non-goals

- Автоматическая публикация, Store upload, App Review и собственная EULA.
- Отдельный iPhone support UI.

## Acceptance criteria

- [x] make site-check проходит, нет placeholder-реквизитов и недействительных ссылок; четыре страницы и app surfaces описывают одинаковый продукт.
- [x] На Watch доступны readable content и public URLs всех трёх разделов офлайн; contact виден и не требует регистрации.
- [x] При paywall обе legal ссылки доступны до покупки; при free access коммерческие тексты отсутствуют.
- [x] Публичные URL действительно доступны к завершению этапа. Если домен/публикация не готовы, записан конкретный BLOCKED, проверка не объявлена пройденной.
- [x] watchOS Review Request не создаётся: REL-208/REL-209 INAPPLICABLE с конкретным Watch-only обоснованием в финальном evidence.
- [ ] Тесты проверяют наблюдаемое поведение и регрессии этого этапа; `make milestone ID=M09` проходит на clean `REVIEW` HEAD с обязательными тестами без failures/skips.

## Validation

`make milestone ID=M09`. Обязательные проверки и evidence выполняются в одной Builder-сессии.

## Handoff

Записать `AI/handoffs/M09-handoff.md` по компактному шаблону: полный SHA, точные команды, exit codes, UTC time, report paths, counts, известные ограничения и следующий шаг. После доказанного DONE остановиться.

## Preparation authorization — 2026-10-21

The owner explicitly requested all feasible publication preparation without real
Watches, approved H1 and Cloudflare publication, and prohibited App Review. The
site and bundled legal/support content are prepared under that instruction. This
is not a dependency waiver: M08 remains BLOCKED, so M09 cannot enter its final
REVIEW/DONE gate until M08 is complete. See its handoff for targeted evidence.
