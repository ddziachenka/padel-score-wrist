# M00 — Watch-only Bootstrap

**ID:** M00
**Status:** REVIEW
**Depends on:** none
**Validation:** make milestone ID=M00
**Handoff:** AI/handoffs/M00-handoff.md

## Objective

Подключить настоящий Watch-only проект к локальной проверке и подтвердить сборку, тесты и запуск на собственном симуляторе.

## Scope

- Вход: владелец одобрил направление контрактов, минимум watchOS 10 и название Padel Score — Wrist; выбор bundle identifier делегирован агенту. Deployment target — watchOS 10.0, фактическая совместимость требует проверки.
- По явному поручению владельца от 2026-10-20 агент создаёт проект в `App/`, следуя установленному современному Watch-only App template Xcode: исполняемое Watch-приложение и packaging container, общий shared scheme, собирающий оба, и настоящий Watch unit-test target. Это поручение заменяет прежнее условие о создании только владельцем. Требования сборки и проверки сохранены.
- Сохранить существующую Git-историю. Не запускать `make initialize`: этот скрипт сбрасывает историю. Подготовить `.iosai-project` без сброса репозитория с primary_branch=main и честной записью происхождения шаблона; исходный upstream SHA пока неизвестен. Импортированный baseline доступен в первом коммите, но сам по себе не доказывает прохождение self-test.
- До перехода в product mode получить проверяемую исходную запись self-test либо прогнать `make self-test` на отдельной временной копии импортированного шаблона с точным SHA. Записать SHA, команду и результат; не заявлять унаследованные гарантии без доказательства. Это проверка инструментария, а не приложения.
- Выполнить `xcrun simctl list -j`. По утверждённой H3 выбрать доступную совместимую Watch-модель и runtime; передать `--platform watchOS`, `--simulator-device-type` и `--simulator-runtime` в `Scripts/configure-project.sh` вместе с реальными project/scheme/app-target/bundle-id. APP_TARGET и BUNDLE_IDENTIFIER принадлежат Watch executable.
- Наблюдавшаяся 2026-10-20 пара для первого запуска: com.apple.CoreSimulator.SimDeviceType.Apple-Watch-SE-40mm-2nd-generation и com.apple.CoreSimulator.SimRuntime.watchOS-26-5. Повторно проверить доступность; это не утверждённый deployment target и не доказательство работы на минимальной ОС.
- Перейти на product mode реальной конфигурацией, подготовить managed simulator через `make simulator-setup`, получить UDID через `make simulator-context`. Все последующие действия адресованы этому устройству; никаких чужих или парных iPhone-симуляторов.
- Добавить минимальный запускаемый экран, реальный unit test и английский String Catalog. Синхронизировать версии/build app и container, записать фактическую toolchain и deployment target в ARCHITECTURE.
- Выполнить make template-check, make static, make fast; проверить запуск и одно действие на собственном Watch simulator. Проверить clean-HEAD milestone и повторение по полному SHA, а также отказ release до финального аудита.

## Non-goals

- Счёт, покупки, HealthKit, complication и продуктовые экраны следующих этапов.
- Установка runtime, изменение системных симуляторов, автоматическая установка Git hooks, публикация и отправка на ревью.

## Acceptance criteria

- [x] Xcode показывает shared scheme с Watch app, container и настоящим test target; вложенного .git в App нет.
- [x] Config/project.env использует APP_PLATFORM=watchOS, TEMPLATE_REPOSITORY=false, managed mode и выбранные реальные identifiers; маркер записывает main и честное происхождение инструментария.
- [x] Проверены WKWatchOnly, embedded Watch app и совпадение version/build в container; на managed Watch simulator приложение запускается и принимает действие.
- [ ] Есть успешные make template-check, make static, make fast; make milestone ID=M00 и повтор той же проверки с CANDIDATE=<full-SHA> дают ненулевые обязательные тесты без failures/skips.
- [ ] make release CANDIDATE=<тот же full-SHA> ожидаемо возвращает NOT_READY до Final Product Polish; это не успешная release-проверка.
- [ ] Существует точное доказательство self-test инструментария, а handoff различает его и реальные результаты Xcode.
- [ ] ARCHITECTURE содержит фактическую платформу и ограничения покрытия minimum OS; hooksPath не менялся без выбора владельца.
- [ ] ./Scripts/project-status.sh validate проходит; handoff содержит полный SHA, команды, время, пути отчётов и counts.

## Validation

`make milestone ID=M00`. Обязательные проверки и evidence выполняются в одной Builder-сессии.

## Handoff

Записать `AI/handoffs/M00-handoff.md` по компактному шаблону: полный SHA, точные команды, exit codes, UTC time, report paths, counts, известные ограничения и следующий шаг. После доказанного DONE остановиться.
