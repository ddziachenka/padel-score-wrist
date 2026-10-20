# M05 — Live Score

**ID:** M05
**Status:** REVIEW
**Depends on:** M04
**Validation:** make milestone ID=M05
**Handoff:** AI/handoffs/M05-handoff.md

## Objective

Отмечать розыгрыш одним касанием и сразу видеть счёт обеих команд и следующего подающего.

## Scope

- Главный экран DESIGN: фиксированные US/THEM, большие score-buttons, games/sets либо Remaining/serve progress, Undo и Menu с постоянным server label.
- Подключить engines+repository; session actions сериализуются, число касаний не порождает перекрывающихся сохранений.
- Доступная кнопка Undo выполняет полную отмену, без подтверждения обычного начисления; доступность отмены озвучивается.
- Нативная короткая обратная связь после успешной записи, отдельный смысл для game/set boundary без модальных экранов и лишнего tap.
- При поднятии запястья/возврате восстановить экран игры; Always On read-only presentation по системному lifecycle, без HealthKit или обещания постоянно включённого экрана.
- Основная компоновка без прокрутки на утверждённом компактном размере при обычном тексте; accessibility reflow и VoiceOver по DESIGN.

## Non-goals

- Complications, фоновые тренировки и ускорители голосового ввода.
- Редактирование сложного состояния и отдельный экран результата.

## Acceptance criteria

- [ ] Одно осознанное касание выигравшей команды добавляет ровно один розыгрыш, не переставляет US/THEM и показывает правильного подающего.
- [ ] Обе модели и все deuce states отображаются однозначно; большие значения и длинные роли не скрывают принадлежность счёта.
- [ ] Реальный запуск на owned Watch simulator подтверждает main loop и Undo; lifecycle suspend/reopen не теряет подтверждённого очка.
- [ ] Проверены maximum text, VoiceOver order, Increase Contrast/Reduce Motion, недоступность сохранения; физические haptics отмечены как requiring real Watch evidence, а не доказанные симулятором.
- [ ] Тесты проверяют наблюдаемое поведение и регрессии этого этапа; `make milestone ID=M05` проходит на clean `REVIEW` HEAD с обязательными тестами без failures/skips.

## Validation

`make milestone ID=M05`. Обязательные проверки и evidence выполняются в одной Builder-сессии.

## Handoff

Записать `AI/handoffs/M05-handoff.md` по компактному шаблону: полный SHA, точные команды, exit codes, UTC time, report paths, counts, известные ограничения и следующий шаг. После доказанного DONE остановиться.
