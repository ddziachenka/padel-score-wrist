# M07 — Finish and Resume handoff

**Policy status:** current

## Milestone

`M07` — Finish and Resume; status `DONE`.

## Summary

Игру теперь можно честно завершить, увидеть сохранённый результат и продолжить её с того же места.

- **Finish (S9).** В меню играемой игры под исправлениями — `Finish match` / `Finish round`. Экран
  показывает итог, который будет сохранён, затем `Finish this game?` / `Your current score will be saved.`,
  `Finish` и `Keep playing`. Finish — команда `.finish` тем же последовательным путём, что розыгрыш:
  `Saving…` на кнопке, `success` после записи, неудача — E3 поверх (Retry тем же `CommandID`, Cancel
  оставляет игру играемой). Закрытие S9 или Keep playing ничего не меняет.
- **Результат (S10).** Пока последний результат можно изменить, он открывается вместо счёта — и после
  Finish, и при запуске. `Match finished` / `Round finished`, `✓ Saved`, итог, `New game`, пояснение
  `Starting a new game will keep this result for viewing only.`, `Resume game`, `Edit result`, `About`.
- **Итог.** Две плитки `US` / `THEM` как на счёте: выигранные сеты матча или очки раунда; под ними строки
  «наше — название — их»: каждый завершённый сет, затем начатый сет с пометкой `Incomplete` и строкой
  `Points` / `Tie-break`; новый сет 0:0 не выводится, матч без очков — `No points played.` У матча
  победителя нет. Раунд при N — `US won` / `THEM won` / `Draw`; остановленный раньше — `Ended early` и
  лидер (`US ahead`, `THEM ahead`, `Points level`); всегда `18 of 32 rallies played.`
- **Resume.** Та же игра (тот же `GameID`), тот же счёт, подача и вся история Undo. Раунд на N ничего не
  отправляет: Resume открывает Game settings черновика с текстом `All rallies are played. To resume, increase
  the total or correct the score.`; сохранение большего N оставляет игру завершённой (`Ended early`),
  продолжение — отдельным Resume. Undo после Resume снова завершает игру на экране счёта.
- **Edit result** — редактор M06 для завершённой игры; правка оставляет её завершённой. N, опущенное до
  сыгранного, показывает у строки Total rallies `All rallies are played.` и итог; N ниже — конфликт E2,
  Save отказывает.
- **Раунд, завершённый последним розыгрышем**, остаётся на счёте с Undo, как в M05; вместо меню — круглая
  ✓ (`Done`), она ведёт к результату.
- **Следующая игра.** New game с результата открывает выбор формата и настройку в том же стеке; Back
  возвращает к редактируемому результату. Старт делает результат только просматриваемым: меню новой игры
  показывает `Last result` без действий, пока новая игра не завершится вместо него.
- **About → Settings → Delete local data (S15).** Список хранимого (`The game being played`, `The last
  result`, `Settings saved for the next game`), `Delete local data` и подтверждение из DESIGN; Cancel ничего
  не меняет, Delete удаляет игру, историю, результаты и настройки одной записью вместе с резервной копией и
  открывает пустой New game. Без данных — `No game data is kept on this Watch.` и недоступная кнопка.
  Неудача — `Couldn’t delete. Your game data is unchanged.` с Retry/Cancel. Учёт использования не удаляется.
- **Учёт использования.** Одно событие завершения на game ID уже обеспечено доменом M03 (переход active →
  finished, ledger — множество ID). Новые тесты проходят Finish → Resume → Finish, правку результата и Undo
  через `LiveScore` с учитывающей политикой: игра учтена один раз.
- **Последняя короткая серия** раунда показывает настоящую длину: при 10/4 после восьми розыгрышей
  `Serve 1 of 2` (замечание M02).

Обратимые решения этапа:

- один стек текущей игры от счёта до результата (`LiveScoreView`): сохранённый Finish возвращает к
  результату, Resume — к счёту, без смены корневого экрана приложения;
- раунд, завершённый розыгрышем, остаётся на счёте с Undo (M05), а ✓ вместо меню ведёт к результату; Undo
  на S10 не добавлялся — DESIGN его там не предусматривает;
- Resume раунда на N открывает Game settings, а продолжение после правки — отдельное Resume (AC6);
- пояснение о новой игре — под `New game` на S10, где «this result» однозначно;
- итог в колонках счёта, `Incomplete` цвета warning; `Ended early` и лидер — двумя строками (через `·` на
  40 mm строка рвалась);
- New game с результата — в том же стеке через проекцию пути `NewGameFlow`; строки Setup открывают
  редакторы через `flow.path` вместо `NavigationLink(value:)`;
- `Saved` на результате всегда (он сохранён), на 1,5 с после правки — `Changes saved`;
- VoiceOver: `Match finished. Saved.`, `Game resumed.` с очками и подающим, `Local data deleted.`.

Сессия работала в worktree `.claude/worktrees/next-ready-milestone-5a9335` на ветке
`claude/next-ready-milestone-5a9335`, как M01–M06: коммиты сделаны на этой ветке поверх `main`@`b4da134`,
`main` основного checkout продвинут `git merge --ff-only` без новых коммитов (SHA те же), и milestone
gate выполнен в основном checkout на `main`. Это открыто записанное отклонение от буквы правила
«milestone не реализуется в worktree».

## Changed files

- `App/PadelScoreWatch/Features/Result/` — новые: `ResultSummary` (итог из snapshot: окончание, плитки,
  завершённые сеты, незавершённый сет с очками, розыгрыши раунда), `ResultSummaryView` (плитки и строки в
  колонках счёта), `ResultView` (S10, `Saved`, `EarlierResultView` для Last result, `FinishView` для S9).
- `App/PadelScoreWatch/Features/Settings/` — новые: `LocalDataSettings` (что хранится, удаление одной
  записью, Retry/Cancel), `LocalDataSettingsView` (S15 с подтверждением).
- `App/PadelScoreWatch/Features/Game/` — `LiveScore`: `finish()`, `resume()`, правка результата,
  `showsResult`, `earlierResult`, игра, завершённая через Finish, идёт к результату; `LiveScoreView`: результат
  корнем стека, маршруты Finish, Last result, Settings, выбор формата и настройка новой игры (проекция пути
  `NewGameFlow`), ✓ Done на завершённом раунде, `Game resumed`; `GameMenuView`: `Finish match` / `Finish
  round`, `Last result`, без прежнего `New game`; `ScoreAnnouncement`: Finish, Resume, правка результата, Undo
  после Resume; `ScoreBoard`: настоящая длина последней серии, `points(_:)` доступен итогу.
- `App/PadelScoreWatch/Features/Correction/` — `GameEditor.makesRoomToResume`; `CorrectionDraft.completesResult`
  и `leavesNoRoom`; `GameEditorScreen`: текст Resume для раунда на N, итог раунда у строки Total rallies;
  `RoundEndNotice` для завершённого раунда.
- `App/PadelScoreWatch/Features/NewGame/` — `FormatChoices` и `NewGameDestination` выделены для стека результата;
  строки Setup открывают редакторы через `flow.path`; маршрут `.settings`.
- `App/PadelScoreWatch/Features/Root/` — `LaunchScreen.result`; `RootView` показывает игру и её результат одним
  `LiveScoreView` и сбрасывает отклик прошлой игры при смене игры.
- `App/PadelScoreWatch/Features/About/AboutView.swift` — строка `Settings`.
- `App/PadelScoreWatch/App/UITestStore.swift` — seeds `matchFinished`, `roundFinished`, `roundEndedEarly`,
  `afterResult`.
- `App/PadelScoreWatch/Localizable.xcstrings` — 49 новых ключей, уточнены комментарии 13 переиспользованных;
  значения прежних ключей не менялись.
- `App/PadelScoreWatchTests/` — новые `FinishResumeTests`, `ResultSummaryTests`, `LocalDataSettingsTests`;
  новые и изменённые случаи `CorrectionDraftTests`, `GameEditorTests`, `LaunchScreenTests`, `LiveScoreTests`,
  `ScoreAnnouncementTests`, `ScoreBoardTests`, `UITestStoreTests`.
- `App/PadelScoreWatchUITests/` — новый `FinishResumeUITests`; новые случаи `AccessibilityUITests` и
  `LargeTextUITests`; `LiveScoreUITests` и `NewGameUITests` идут к New game через результат.
- `App/PadelScore.xcodeproj/project.pbxproj` — файлы и группы `Result`, `Settings`.
- `App/README.md`, `AI/ARCHITECTURE.md`, `AI/DESIGN.md` — что добавил M07.
- `AI/milestones/M07-finish-resume.md`, `AI/PROJECT_STATUS.md`, `AI/DEVELOPMENT_PLAN.md` — состояние этапа;
  `AI/handoffs/M07-handoff.md` — эта запись.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `fdabf2e3e2a043e926c4ec34225b3968a6309d40` |
| Exact command | `make milestone ID=M07` в основном checkout `/Users/Shared/D/ios/padel-score` на `main` (из сессии: `make -C /Users/Shared/D/ios/padel-score milestone ID=M07`) |
| Exit code | 0 |
| Timestamp | 2026-10-21T10:14:27Z–10:49:35Z; в отчёте verification started 20261021T101429Z, completed 20261021T104935Z |
| Report | `.artifacts/milestone/M07/20261021T101428Z-28225/report.md`; `milestone.xcresult` в том же каталоге |
| Counts | static + Debug build passed; 371 tests / 371 passed / 0 failed / 0 skipped / 0 expected failures по `.xcresult` (result `Passed`): 320 Swift Testing tests (32 новых M07, 288 M00–M06) и 51 XCUITest (9 новых M07, 42 M04–M06); managed Watch SE 40 mm (2nd generation), watchOS 26.5 (23T570), UDID `A77BD37D-4A5F-40E0-8CD3-899210952F92` |

Managed simulator был загружен `make simulator-boot` в основном checkout. Перед gate lease этой
сессии освобождён (`{"released":true}`, `Scripts/simulator.sh leases` → `{}`). Дополнительный problem
scanner не настроен: SwiftLint, SwiftFormat и ShellCheck выключены в `Config/project.env`.

Development feedback, не evidence:

- `make static` в worktree → PASSED на каждом коммите; `./Scripts/project-status.sh validate` → ok.
  `xcodebuild build`/`build-for-testing … 'generic/platform=watchOS Simulator'` и сборки для managed
  device — без errors и warnings (кроме служебных `appintentsmetadataprocessor` и `MessagesApplicationStub`).
- Scratch SwiftPM-пакет поверх Domain, Services и Features без SwiftUI (`swift test` на macOS): 313/313 на
  финальных байтах этих файлов.
- Hosted на managed simulator под lease этой сессии: unit-тесты и новые или изменённые UI-тесты — 333
  (332 прошли; тест удаления падал на касании alert и после исправления прошёл отдельно); 13 UI-тестов,
  которых касаются строки Setup, About и ✓ (New game, Bootstrap, крупный текст, аудиты), — 13/13; тест Resume
  с проверкой строки контекста — прошёл с исправлением и упал без него.
- String Catalog против ключей, извлечённых компилятором (`.stringsdata`): 224 из 224, 0 отсутствующих,
  0 лишних. 49 ключей новые, значения прежних не менялись.
- Mutation check: 25 ошибок, 24 пойманы, 1 эквивалентная (см. Tests).
- В запущенном приложении (managed 40 mm, инструмент управления симулятором): все экраны M07 при стандартном
  тексте и XXXL; Increase Contrast через `defaults write com.apple.Accessibility DarkenSystemColors`, после
  проверки ключ удалён.

## Tests

Новые и изменённые тесты (Swift Testing, hosted на часах):

- `FinishResumeTests` (13):
  - Finish при 0:0, посреди гейма, сразу после сета (порядок нового сета не подтверждён) и при равных сетах
    сохраняет ту же игру и тот же счёт целиком, историю `.finish`, `success`, результат вместо счёта и файл;
    VoiceOver `Match finished. Saved.`;
  - раунд, остановленный на 12:6 из 32, — `Ended early`, лидер US, 18 из 32; `Round finished. Saved.`;
  - Finish не отправляется при открытом редакторе, во время другой записи и для завершённой игры;
  - Resume возвращает ту же игру (score, подача, статус) с историей `.finish`, `.resume`, без haptic,
    `Game resumed. Us 40, them 40. Serving: You.`; следующий розыгрыш даёт AD;
  - Undo после Resume снова завершает игру на экране счёта (`Action undone. Match finished.`), второй Undo
    снимает Finish;
  - раунд на N: Resume ничего не отправляет (`needsRoom`), правка в режиме `makesRoomToResume` до 6 оставляет
    его завершённым (`Ended early`, level), отдельный Resume продолжает последнюю короткую серию с места;
  - N завершённого раунда ниже сыгранного не сохраняется, равное сыгранному сохраняет результат полного
    раунда (`Our team won`), Resume снова просит места;
  - правка результата: та же игра, завершённая, история `.correction`, `Changes saved. Match finished. Sets: us
    1, them 0.`;
  - Finish → Resume → Finish → правка → Resume → Finish с учитывающей политикой учитывает игру один раз и
    не создаёт другой игры, также после перезапуска;
  - неудачная запись Finish держит игру играемой и файл прежним; Retry записывает её один раз;
  - неудачная запись Resume держит результат; Cancel оставляет его, и после перезапуска открывается результат;
  - после перезапуска открывается результат, Resume восстанавливает игру и историю Undo;
  - новая игра оставляет прежний результат только для просмотра (`earlierResult`), правится только новая;
    её Finish заменяет его, Resume снова показывает прежний.
- `ResultSummaryTests` (8): матч 0:0 (`No points played`), посреди гейма, только очки в начатом сете, сразу
  после сета (новый 0:0 не выводится), равные сеты/AD/тай-брейк без победителя; раунд 18:14 и 14:18 из 32 —
  победа, 16:16 — `Draw`; остановленный раньше (10:8, 6:12, 9:9, 0:0) — лидер, не победитель и не ничья;
  английские тексты.
- `LocalDataSettingsTests` (3): что хранится в каждом состоянии и пустой список без данных; удаление одной
  записью убирает игру, историю, результаты и настройки, оставляет учёт и только `session.json`, открывает New
  game; неудачная запись ничего не удаляет, держит запрос, Retry удаляет один раз, Cancel всё оставляет.
- `CorrectionDraftTests`: завершённый раунд относительно N (`completesResult`, `leavesNoRoom`, N ниже —
  конфликт); нетронутый полный раунд ничего нового не говорит, исправленный на N — новый итог; играемый раунд.
- `ScoreBoardTests`: 10 розыгрышей по 4 — серии 4, 4 и 2 (`Serve 1 of 2`, `Serve 2 of 2`, Partner); один
  оставшийся розыгрыш — серия из одного; серия, кончающаяся раньше N, целиком.
- `ScoreAnnouncementTests`: Finish, Resume, Undo после Resume, правка результата матча и раунда (лидер, ничья
  при N); `.finished` без итога не объявляется.
- `LaunchScreenTests`: завершённая игра открывает результат, после удаления — New game; новая игра поверх
  результата; раунд на экране и прочие завершённые. `LiveScoreTests`: уход завершённого раунда — к результату.
  `GameEditorTests`: одна правка за раз, завершённая игра правится как результат и остаётся завершённой.
- `UITestStoreTests`: seeds `matchFinished`, `roundFinished`, `roundEndedEarly`, `afterResult`.

UI (XCUITest, managed SE 40 mm):

- `FinishResumeUITests` (6): Finish матча посреди гейма (S9 с `Incomplete` и очками, Keep playing ничего не
  меняет, результат с `Saved`), перезапуск открывает результат, Resume возвращает 30:15 и подающего, возврат
  из меню не повторяет `Game resumed`, Undo снова завершает игру с ✓, ✓ ведёт к результату; раунд 18:14 из 32:
  Resume просит места, N 36, `32 of 36`, Resume, четыре розыгрыша до конца, ✓, `36 of 36`; раунд,
  остановленный раньше: N 17 не сохраняется, N 18 — `All rallies are played.`, `Our team won`; New game с
  результата и Back к редактируемому результату, новая игра, Last result только для просмотра, Finish новой
  игры заменяет результат; неудачная запись Finish: Cancel оставляет игру, после перезапуска она играется;
  Delete local data: список, Cancel ничего не удаляет, Delete data — пустой New game без последних настроек,
  Settings без данных, после перезапуска New game.
- `AccessibilityUITests` (2): аудит меню с Finish и Last result, Last result, Finish round, результата
  раунда, Settings; результата матча и игры, снова завершённой на экране.
- `LargeTextUITests` (1): результат при самом крупном тексте — строки сетов и очков, Edit result, Resume.
- `LiveScoreUITests`: завершённый раунд без меню, ✓ ведёт к результату `Our team won`, оттуда New game.
- `NewGameUITests`: запуск с последними настройками открывает результат; New game — через него.

Self-review всего diff `b4da134..fdabf2e` нашёл и исправил:

- **Повтор подсказки строки контекста** (M05): возврат на счёт из меню снова показывал `Action undone` /
  `Changes saved`, и так же повторялся бы новый `Game resumed`. Строка помнит сказанное изменение; UI-тест
  следит за строкой после возврата из меню и без исправления падает.
- **`Ended early · US ahead`** на 40 mm переносилось с висящей точкой — две строки `Ended early` / `US ahead`.
- **`All rallies are played.`** стояло у Total rallies и при неизменённом полном раунде — теперь только после
  правки, меняющей итог.
- **`Set 2` над `Incomplete`** при самом крупном тексте стояло по центру — выравнивание по краю.
- **Список хранимого** в Settings был голым текстом — тональная группа.
- **✓ Done** принимал касание во время записи Undo — теперь только в покое, как остальные действия.
- **Декоративная галочка** у `Saved` попадала в VoiceOver — скрыта, метка `Saved`.
- Тест удаления: действия alert нажимаются напрямую, список alert прокручивается к ним сам.

Mutation check (scratch SwiftPM на macOS, копии файлов): 25 ошибок по одной в `ResultSummary`, `LiveScore`,
`LocalDataSettings`, `CorrectionDraft`, `ScoreBoard`, `ScoreAnnouncement`, `LaunchScreen` и `UITestStore` —
24 пойманы. Выжил один эквивалентный: отказ от запроса при отклонённом Retry удаления — ветка недостижима
(пока запрос ждёт повтора, ревизия не меняется, повторное касание Retry отсекается состоянием), та же
защитная ветка есть в `LiveScore.retry`.

Craftsmanship pass выполнен в запущенном приложении на 40 mm (инструмент управления симулятором): результат
матча и раунда (полный, раньше N), S9, Keep playing, неудачная запись Finish с Cancel, Resume матча и раунда
через правку N, ✓ на завершённом раунде, New game с результата и Back, Last result, About → Settings, Delete
local data (Cancel и Delete), Settings без данных; самый крупный текст; Increase Contrast (контуры плиток), ключ
удалён после проверки. DO3 выполнен нативно: галочка `Saved`, `success` при завершении, `Incomplete` сразу;
без конфетти и выдуманной победы.

## Known issues

- **Нужны настоящие часы.** `success` при Finish и последнем розыгрыше, ощущение ✓ и Undo на завершённом
  раунде; VoiceOver на часах: объявления `Match finished. Saved.` / `Game resumed.` при смене корня стека,
  куда встаёт фокус после Finish, Resume и удаления; Always On на результате. Это M10.
- **watchOS 10 не проверена запуском:** все проверки на watchOS 26.5.
- **Покупки ещё нет (H4, M08).** Подтверждение удаления говорит `Your purchase is not deleted.` — текст DESIGN;
  если H4 выберет бесплатную v1, M08 должен убрать эту фразу. Удаление не трогает учёт использования (H4d
  открыт), экран ничего не обещает о пробном счётчике. Учёт одного завершения на game ID проверен только
  тестовыми политиками; `OpenAccess` по-прежнему ничего не считает.
- **P2: заголовок результата** `Match finished` в свёрнутом виде при самом крупном тексте обрезается системой
  (`Match finishe…`); итог на экране виден целиком, развёрнутый заголовок — тоже.
- **P2: S9 на 40 mm.** Вопрос и кнопки — под итогом, до `Finish` нужно прокрутить: сначала видно, что будет
  сохранено (DESIGN: «Finish: фактический результат» первым).
- **Отмена на результате.** На S10 нет Undo (DESIGN его не предусматривает): ошибочный последний розыгрыш
  раунда отменяется Undo на счёте до ✓, а после — правкой результата; сохранённая правка результата
  исправляется новой правкой.
- **P2 из M06 остаются:** контур круглых + и − при Increase Contrast; номер сета в VoiceOver строки Sets;
  `Restore set N` после отменённой смены формата.
- **Gate** теперь занимает около 35 минут: 51 UI-тест — 2062 с.
- **Остаются worktrees** `.claude/worktrees/next-ready-milestone-7007f6`, `…-96424e`, `…-97ed55`, `…-8fb157`,
  `…-a555a6`, `…-3783d3` и эта, `…-5a9335`, с их ветками; их можно удалить.

## Next step

M08 — Access and Purchase; ждёт решения H4 владельца. Остаток H1 нужен до M09.
