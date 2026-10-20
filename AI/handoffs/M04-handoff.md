# M04 — New Game handoff

**Policy status:** current

## Milestone

`M04` — New Game; status `DONE`.

## Summary

На часах теперь создаются оба формата. Приложение открывается по сохранённой сессии:
пока она читается — пустой холст, через секунду `Loading game…`; играемая игра
открывается сразу (это и есть Resume: экран New game с активной игрой недостижим, а
Domain дополнительно отклоняет старт поверх неё); иначе — New game. Нечитаемые данные
показывают S14 (`We couldn’t read this game.` / `Your saved data has not been deleted.`)
с `Try again`; для повреждённого файла ещё и `Start over` после подтверждения.
Недоступный файл и файл более новой версии не откладываются. Восстановление из backup
объявляется alert `Earlier save restored` до подтверждения.

- **New game (S1):** `Match` — `Games and sets`, `Americano` — `A fixed total of rallies`,
  `About`. Без регистрации, разрешений и примеров.
- **Setup (S2):** матч — `At 40–40` и `Serving`; американо — `Total rallies`,
  `Rallies per server` и `Serving`. Число сетов нигде не спрашивается. Невыбранное
  значение читается `Choose`; `Start game` без него называет значение у его строки,
  даёт failure haptic, переносит туда VoiceOver и прокрутку и ничего не записывает.
  Последние настройки повторяются для проверки (`From your last game. Check before you
  start.`), каждый формат со своими правилами; первый запуск ничего не подставляет.
  Start отправляет одну команду `.start` с новыми `GameID`/`CommandID` через
  `SessionStore`; через секунду `Saving…`, через пять `Still saving…`. Неудачная запись:
  `Couldn’t save. The game hasn’t started.` с `Retry` (те же идентификаторы) и `Cancel`;
  отказ политики доступа — отдельное сообщение (M08 заменит его paywall).
- **Редакторы (S7/S8), общие для M06:** правило 40:40 с пояснениями (у `One advantage`
  — `At the second deuce, the next point wins.`); число с Digital Crown (фокус при
  открытии, Crown меняет только его), `−`/`+` с удержанием, VoiceOver adjustable, границы
  `From 1 to 999.` / `From 1 to 99.`; подача — `First server`, `Second server` (только
  соперники первого) и `Service order` всех четырёх. Выбор пишется в черновик сразу: Done
  и Back сохраняют, `Cancel` возвращает значение поля на момент открытия (DESIGN →
  Navigation); после возврата VoiceOver-фокус встаёт на изменённую строку.
- **Игра:** пока M05 не дал живой счёт, `GameView` только показывает сохранённую игру:
  US/THEM, геймы/сеты или `Rallies left`, подающего (`Serve 1 of 4`) и правила; Crown
  на нём ничего не меняет.
- **Дизайн:** 11 семантических color sets по таблице DESIGN, `Typography`, `Spacing`,
  стили кнопок и строк; оригинальная иконка — мяч для падела цвета accent на чёрном,
  исходник `App/Design/render-app-icon.swift` (CoreGraphics, детерминирован: оба рендера
  дают SHA-256 `027c1013188b72ee5ce3be5dc922427e444624c3f6a7668438ef3d791a329694`),
  PNG 1024×1024 без альфы в AppIcon каталога Watch target.
- **Тексты:** 75 ключей в `Localizable.xcstrings` с комментариями, plural для rallies,
  `40–40` не разрывается (word joiner в английских значениях). Сверка с ключами,
  которые извлёк компилятор (`.stringsdata`): 0 отсутствующих, 0 лишних.

Обратимые решения этапа: границы редакторов 1–999 и 1–99 (продукт верхней границы не
задаёт, Domain требует лишь положительных целых); пустой числовой редактор начинает с
нижней границы, а не с придуманного значения; подача — первый и второй подающий, причём
выбор каждой команды хранится отдельно и переживает смену подающей пары; временный
экран игры до M05; уведомление о восстановлении — alert; `Start over` только для
повреждённых данных; Debug-хуки UI-тестов (`UITestStore`: `PADEL_UITEST_STORE`,
`PADEL_UITEST_SEED`, `PADEL_UITEST_FAIL_SAVES`), которых нет в Release.

Сессию запустило приложение Claude в worktree `.claude/worktrees/next-ready-milestone-8fb157`
на ветке `claude/next-ready-milestone-8fb157`; hook сессии запрещает правки основного
checkout. Как в M01–M03, коммиты сделаны на этой ветке поверх `main`@`5070c4b`, `main`
основного checkout продвинут `git merge --ff-only` без новых коммитов (SHA те же),
milestone gate выполнен в основном checkout на `main`. Это открыто записанное отклонение
от буквы правила «milestone не реализуется в worktree».

## Changed files

- `App/PadelScoreWatch/App/` — composition root: `PadelScoreApp.swift` (перенесён из корня
  target), `AppComposition.swift` (единственный store), `UITestStore.swift` (только Debug).
- `App/PadelScoreWatch/Features/Root/` — `RootView` (маршрут по состоянию store, загрузка,
  alert восстановления), `LaunchScreen`, `RecoveryView` (S14).
- `App/PadelScoreWatch/Features/NewGame/` — `SetupDraft` (+ `ServingChoice`), `NewGameFlow`,
  `NewGameView` (S1 и маршруты), `SetupView` (S2).
- `App/PadelScoreWatch/Features/Editors/` — `DeuceRuleEditor`, `NumberEditor`,
  `ServingEditor`, `ChoiceButton`, `EditorActions`.
- `App/PadelScoreWatch/Features/Game/GameView.swift`, `Features/About/AboutView.swift`
  (перенесён из удалённого `HomeView.swift`).
- `App/PadelScoreWatch/Features/Shared/` — `DesignSystem` (Palette, Typography, Spacing,
  Metrics, стили), `DisplayNames` (роли, правила, форматы), `SavingLabel` (+ `SaveWait`).
- `App/PadelScoreWatch/Domain/Team.swift` (`Player.partner`), `ServiceOrder.swift`
  (`init(first:second:)`).
- `App/PadelScoreWatch/Assets.xcassets/` — 10 новых color sets, `AppIcon.png` и его
  `Contents.json`; `App/Design/render-app-icon.swift` — исходник иконки.
- `App/PadelScoreWatch/Localizable.xcstrings` — все строки M04; два неиспользуемых ключа
  прежнего wordmark удалены.
- `App/PadelScoreWatchTests/Features/` — `SetupDraftTests` (с `ServingChoiceTests`),
  `NewGameFlowTests`, `LaunchScreenTests` (с `SaveWaitTests`), `DesignSystemTests`;
  `App/PadelScoreWatchTests/App/UITestStoreTests.swift`; `AppConfigurationTests` — иконка.
- `App/PadelScoreWatchUITests/` — `NewGameUITests`, `LargeTextUITests`,
  `AccessibilityUITests`, `UITestSupport`; `BootstrapUITests` — на тестовом store.
- `App/PadelScore.xcodeproj/project.pbxproj` — группы `App`, `Features/*`, membership.
- `App/README.md`, `AI/ARCHITECTURE.md`, `AI/DESIGN.md` — что добавил M04, маршрут,
  черновик и редакторы, границы ввода, токены, иконка, новые тексты.
- `AI/milestones/M04-new-game.md`, `AI/PROJECT_STATUS.md`, `AI/DEVELOPMENT_PLAN.md` —
  состояние этапа; `AI/handoffs/M04-handoff.md` — эта запись.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `b746c73ecd188a1f85bdf156f567d04ec36375d8` |
| Exact command | `make milestone ID=M04` в основном checkout `/Users/Shared/D/ios/padel-score` на `main` (из сессии: `cd /Users/Shared/D/ios/padel-score && make milestone ID=M04`) |
| Exit code | 0 |
| Timestamp | 2026-10-20T21:04:24Z–21:13:38Z; в отчёте verification started 20261020T210426Z, completed 20261020T211337Z |
| Report | `.artifacts/milestone/M04/20261020T210425Z-2388/report.md`; `milestone.xcresult` в том же каталоге |
| Counts | static + Debug build passed; 206 tests / 206 passed / 0 failed / 0 skipped / 0 expected failures по `.xcresult` (result `Passed`): 192 Swift Testing tests в 25 suites (43 новых M04, 149 M00–M03) и 14 XCUITests (13 новых, `BootstrapUITests` обновлён); managed Watch SE 40 mm (2nd generation), watchOS 26.5, UDID `A77BD37D-4A5F-40E0-8CD3-899210952F92` |

Managed simulator запущен `make simulator-boot` в основном checkout в начале сессии;
перед gate `make simulator-status` показал `Booted`, а lease этой сессии был освобождён
(`Scripts/simulator.sh release`, `{"released":true}`). Дополнительный problem scanner в
репозитории не настроен: SwiftLint, SwiftFormat и ShellCheck выключены в
`Config/project.env`, других нет.

Development feedback, не evidence (ручные материалы — `.artifacts/M04-new-game/` основного
checkout, описание в `README.txt` там же):

- `make static` в worktree → PASSED до коммита `2919a71`; static stage gate на `b746c73`
  тоже прошёл. `./Scripts/project-status.sh validate` → ok при каждом изменении статуса.
- `xcodebuild build-for-testing … -destination 'generic/platform=watchOS Simulator'` →
  без errors и warnings на каждом шаге. Hosted `xcodebuild test-without-building` из
  worktree на managed simulator под lease этой сессии: весь scheme 206/206 перед
  усилением тестов, затем hosted unit tests 192/192 на финальных байтах тестов.
- Временный Apple Watch Ultra 3 (49mm), watchOS 26.5, UDID
  `51D26999-DD96-4DAB-95BF-6B14DA7A3D43`, создан `xcrun simctl create` только для этой
  проверки и удалён: `NewGameUITests` + `BootstrapUITests` 10/10 на `2919a71`, снимки
  всех состояний. Иконка в сетке приложений проверена на обоих размерах временным
  UI-тестом, который в проект не вошёл.
- String Catalog против ключей, извлечённых компилятором: 0 отсутствующих, 0 лишних.
- Mutation check: 25 ошибок по одной в копии кода (SwiftPM, macOS): 23 пойманы сразу,
  2 — после усиления тестов (см. Tests); логи обоих проходов в `.artifacts/M04-new-game/`.

## Tests

Новые и изменённые тесты (Swift Testing, hosted на часах):

- `SetupDraftTests` — первая игра ничего не подставляет (оба формата); матч просит правило
  40:40 и подачу, но не число сетов; американо — общий итог, серию и подачу, недостающее
  называется по порядку; последние настройки повторяются, у каждого формата свои правила;
  формат без прошлой игры повторяет только подачу; числа вне диапазона редакторов не
  сохраняются; любой готовый черновик стартует игру.
- `ServingChoiceTests` — пустой выбор; любые первый и второй подающий дают чередующийся
  порядок всех четырёх; партнёр первого не подаёт вторым и отклонённый выбор не оставляет
  следа; при смене подающей пары каждая команда сохраняет своего первого подающего; выбор
  второй команды остаётся открытым; подача прошлой игры повторяется точно; порядок из
  игроков одной команды не строится.
- `NewGameFlowTests` — выбор формата открывает Setup; Back выбрасывает черновик и ничего не
  пишет; запоминается редактор, из которого вернулись; Start с недостающим называет поля и
  ничего не пишет; Start сохраняет ровно настроенные матч и американо (и после повторного
  открытия); неудачная запись не стартует игру и сохраняет черновик, Retry стартует ту же
  игру один раз; Cancel и уход из Setup отказываются от неудачного старта; отказ политики
  доступа; играемая игра не заменяется; во время записи черновик не меняется и Start не
  уходит дважды; новый черновик повторяет сохранённые настройки.
- `LaunchScreenTests`, `SaveWaitTests` — до чтения только загрузка; первый запуск — New game;
  играемая игра открывается снова; завершённая — New game; повреждённые и более новые данные
  — recovery, а `Start over` только для повреждённых; шаги `Saving…`/`Still saving…`.
- `DesignSystemTests` — каждый токен есть в каталоге; текст на трёх фонах ≥ 4.5:1, подпись
  на accent ≥ 4.5:1, контуры ≥ 3:1 по фактическим значениям ассетов.
- `UITestStoreTests` — Release-путь без имени store, каждое seed, отказ записи;
  `AppConfigurationTests` — Watch-приложение несёт иконку `AppIcon`.

UI (XCUITest, managed SE 40 mm): `NewGameUITests` — первый запуск; матч от `Choose` и
ошибок у полей до старта, Crown на экране игры не меняет счёт, повторный запуск открывает
ту же игру; американо с Crown и `−`/`+`; Back из Setup выбрасывает черновик; Back из
редактора сохраняет выбор, `Cancel` возвращает прежнее значение (правило, подача, число);
повтор последних настроек; отказ записи с `Retry`/`Cancel` и повторным запуском без игры;
повреждённые данные с `Try again` и подтверждённым `Start over`; уведомление о
восстановлении до подтверждения. `LargeTextUITests` — американо и правила при самом
крупном тексте на 40 mm. `AccessibilityUITests` — системный аудит (все типы) на New game,
At 40–40, Setup матча, Setup американо с ошибками, Total rallies, Serving, экране игры и
recovery: замечаний нет. `BootstrapUITests` переведён на собственный store.

Self-review всего diff `5070c4b..b746c73` нашёл и исправил:

- Back из редактора поля отбрасывал выбор, а DESIGN (Navigation) требует возвращаться с
  черновиком и отменять поле явным `Cancel`: редакторы пишут сразу, `Cancel` добавлен.
- Редакторы брали исходное значение в `init`, а SwiftUI пересоздаёт view после каждой
  записи, и `Cancel` возвращал уже новое значение (поймал новый UI-тест): исходное
  значение хранится в `@State`.
- Аудит доступности: hit area числа была его текстом, 19.5×41 pt; теперь элемент — вся
  строка высотой 44 pt.
- При accessibility-размерах `Advantage` переносилось посреди слова рядом с галочкой:
  галочка уходит под текст. `40–40` переносилось на тире (49 mm): word joiner.
- Подпись повтора настроек занимала четыре строки на 40 mm — сокращена; строки не
  тускнеют на время записи короче секунды; добавлен возврат VoiceOver-фокуса (AX3);
  повторы в коде вынесены в helpers.
- Mutation check (копия Domain, Services и логики M04 в SwiftPM-пакете, `swift test` на
  macOS, по одной ошибке за прогон): первый проход 23 из 25; один тест бесконечно ждал
  начала записи, то есть регрессия повесила бы suite, — ожидание ограничено; два
  выживших (отклонённый второй подающий меняет выбор команды; выбор формата во время
  записи) пойманы усиленными тестами; итог 25 из 25.
- В UI-тестах: свайп на 40 mm проскакивает цель, а касание под заголовком попадает в
  заголовок — прокрутка короткими перетаскиваниями; alert на watchOS — таблица. Тест
  домашнего экрана часов не добавлен: при сбое снимка системного экрана `xcodebuild`
  висел около 10 минут.

Craftsmanship pass выполнен в запущенном приложении: все состояния создания на 40 mm при
стандартном и самом крупном тексте и на временном Apple Watch Ultra 3 49 mm (watchOS 26.5,
создан для проверки и удалён), иконка в сетке приложений обоих размеров. Delight-моментов
DESIGN этот этап не владеет (DO1–DO3 — M05/M07); отдельной анимации не добавлено.

## Known issues

- Экран игры только читает: очки, Undo и меню — M05, исправления — M06, завершение —
  M07. В сборке M04 начатую игру нельзя завершить или заменить другой.
- Экран результата и пояснение `Starting a new game will keep this result for viewing
  only.` принадлежат M07. Если текущая игра завершена (в M04 через UI недостижимо), New
  game открывается без этого пояснения.
- Доступ — `OpenAccess` до H4; текст отказа `A new game can’t start right now.` заменит
  M08.
- На 40 mm при стандартном тексте `Done`/`Cancel` числового редактора ниже края экрана,
  а Crown занят числом: до них прокручивают касанием. Back сохраняет выбранное число,
  поэтому выбор не теряется.
- watchOS 10 не проверена запуском: все проверки на watchOS 26.5. Тактильная отдача,
  ощущение Crown и иконка на настоящих часах не проверялись — в проекте нет signing team;
  это M05/M10.
- Increase Contrast добавляет контур строк через `colorSchemeContrast`; есть ли такая
  настройка на целевых watchOS, проверяет финальный аудит доступности (AX12).
- Полный scheme теперь идёт около 13 минут (14 UI-тестов ≈ 10 минут).
- Worktrees `.claude/worktrees/next-ready-milestone-7007f6`, `…-96424e`, `…-97ed55` и
  `…-8fb157` с их ветками остаются; их можно удалить.

## Next step

M05 — Live Score; открытое решение его не блокирует. H4 нужен до M08, остаток H1 — до M09.
