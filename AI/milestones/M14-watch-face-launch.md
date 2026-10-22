# M14 — Watch Face and Smart Stack Launch

**ID:** M14
**Status:** PLANNED
**Depends on:** M13
**Validation:** make milestone ID=M14
**Handoff:** AI/handoffs/M14-handoff.md

## Objective

Статическая кнопка на циферблате и в Smart Stack открывает Padel Score одним касанием
и возвращает к обычному сохранённому состоянию.

## Scope

- Вход: [план владельца](../purchase-appeal-plan.md) §3 M14, PRODUCT → «Быстрый запуск»,
  DESIGN → S19, ARCHITECTURE → «WidgetKit extension»; актуальные рекомендации Apple
  [Creating accessory widgets and watch complications](https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications).
- WidgetKit extension с `accessoryCircular` и `accessoryRectangular` (включая Smart
  Stack): узнаваемый символ и название, accessibility-подпись `Open Padel Score`;
  нажатие открывает приложение системным механизмом WidgetKit.
- Холодный запуск: текущая игра, завершённый результат либо New game, как обычный
  запуск. Уже открытое приложение не теряет несохранённый редактор и экран.
- Без счёта, общей базы, App Group, фоновых обновлений и обещания актуальных цифр.
- Extension входит в сборку и упаковку Watch-приложения; marketing version и build
  согласованы со всеми targets; Debug и Release собираются, shipping archive не содержит
  тестовых host.
- About: короткая инструкция добавления кнопки на циферблат и в Smart Stack.

## Non-goals

- Счёт или состояние игры на циферблате, App Intents, Action button, Siri, Live
  Activities и фоновые обновления.
- iPhone-приложение и Watch Connectivity.

## Acceptance criteria

- [ ] Оба семейства отображают узнаваемую кнопку с подписью `Open Padel Score` на
      поддерживаемых ОС, включая минимальную watchOS 10, и проходят accessibility audit.
- [ ] Касание открывает приложение: холодный запуск восстанавливает игру, результат или
      New game; при открытом приложении несохранённый редактор и экран сохраняются.
- [ ] Debug и Release собирают extension в Watch-приложении с согласованными version и
      build; static/release проверки упаковки проходят.
- [ ] About содержит понятную инструкцию для циферблата и Smart Stack.
- [ ] Реальная проверка на часах записана либо конкретно заблокирована для M10, без
      объявления её пройденной.
- [ ] Тесты падают при регрессии этого поведения; `make milestone ID=M14` проходит на
      clean `REVIEW` HEAD с обязательными тестами без failures/skips.

## Validation

`make milestone ID=M14`. Обязательные проверки и evidence выполняются в одной
Builder-сессии.

## Handoff

Записать `AI/handoffs/M14-handoff.md` по компактному шаблону: полный SHA, точные
команды, exit codes, UTC time, report paths, counts, известные ограничения и следующий
шаг. После доказанного DONE остановиться.
