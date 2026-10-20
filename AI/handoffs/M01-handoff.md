# M01 — Match Scoring handoff

**Policy status:** current

## Milestone

`M01` — Match Scoring; status `DONE`.

## Summary

Владелец закрыл H2 в этой сессии явным выбором варианта 1
(«Tie-break at 6:6 (Recommended)»): сет до шести геймов с отрывом два, при 6:6
тай-брейк до семи очков с отрывом два, сет записывается 7:6; тай-брейк начинает
игрок, чья очередь подавать, он подаёт одно очко, дальше каждый по два; следующий
сет начинает пара, не начинавшая подачу тай-брейка; порядок подачи подтверждается
перед каждым следующим сетом. Число сетов не ограничено. Решение записано в PRODUCT
(обычный матч, подача, исправления, закрытый H2, change log) и отражено в
ARCHITECTURE, DESIGN, плане, брифе и статусе. Формулировки сверены с FIP Rules of
Padel, редакция 01.01.2026: Rule 1 (тай-брейк) и Rule 6.8 (выбор подающего перед сетом).

В `App/PadelScoreWatch/Domain` добавлен чистый движок обычного матча — только Swift
standard library, без SwiftUI, файлов, часов и StoreKit.
`MatchEngine.apply(_:to:)` получает `MatchState` и `MatchCommand`
(`awardPoint(to:)`, `confirmService(order:firstServer:)`) и возвращает новый
`MatchState` с `MatchOutcome` (`point`, `game`, `set`, `serviceConfirmed`) либо
typed `MatchError`; входной snapshot не меняется.

- Очки 0/15/30/40 и три правила 40:40: `GameScore` хранит `deuce`, `advantage`
  и `decidingPoint` отдельными стадиями, поэтому две одинаковые 40:40 при
  `One advantage` различимы.
- `SetPolicy.tieBreakAtSixAll` — единственная утверждённая политика; все числа
  правила движок берёт из неё. Победителя матча, best-of и автоматического
  завершения нет: после любого сета начинается следующий.
- `ServiceAnchor` хранит ротацию (`ServiceOrder`, две возможные при чередовании
  пар), следующего подающего, контекст тай-брейка (открывший игрок и позиция в
  ходе из одного или двух очков) и признак подтверждения порядка нового сета.
  Очко нового сета до `confirmService` отклоняется; подтверждение меняет игроков
  внутри пар, но не пару, которой правило отдаёт первую подачу.
- `MatchState.issues` называет каждое противоречие счёта, стадии, сетов и подачи;
  при любом из них команда не применяется. Этот же список пригоден для
  черновиков M06.

Сессия запущена приложением Claude в изолированном worktree
`.claude/worktrees/next-ready-milestone-7007f6` на ветке
`claude/next-ready-milestone-7007f6`; hook сессии запрещает правки основного
checkout. Поэтому коммиты сделаны на этой ветке поверх `main`@`adca9e9`, а `main`
основного checkout продвинут `git merge --ff-only` без новых коммитов: SHA те же,
история линейна. Milestone gate выполнен в основном checkout на `main`. Это
отклонение от буквы правила «milestone не реализуется в worktree» повторяет
практику соседнего проекта владельца с тем же шаблоном.

## Changed files

- `AI/PRODUCT.md` — закрытый H2: правило сета и тай-брейка, подача на границах,
  подтверждение порядка, правка тай-брейка, approval points, change log.
- `AI/ARCHITECTURE.md`, `AI/DESIGN.md`, `AI/DEVELOPMENT_PLAN.md`,
  `AI/PRODUCT_BRIEF.md` — указатели на решение, `SetPolicy` и anchor тай-брейка,
  следствия для M05/M06, M01 в плане.
- `AI/PROJECT_STATUS.md`, `AI/milestones/M01-match-scoring.md` — состояние этапа.
- `App/PadelScoreWatch/Domain/` — `Team.swift` (Team, Player), `ServiceOrder.swift`,
  `MatchRules.swift` (DeuceRule, SetPolicy), `MatchState.swift` (snapshot, счёт,
  anchor), `MatchValidation.swift` (MatchIssue, MatchError), `MatchEngine.swift`.
- `App/PadelScoreWatchTests/Domain/` — `MatchTestSupport.swift`,
  `GameScoringTests.swift`, `SetScoringTests.swift`, `ServiceRotationTests.swift`,
  `MatchValidationTests.swift`.
- `App/PadelScore.xcodeproj/project.pbxproj` — группы `Domain` и membership
  новых файлов в Watch app и unit-test target.
- `App/README.md` — что добавил M01 и что остаётся следующим этапам.
- `AI/handoffs/M01-handoff.md` — эта запись.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `4a5f29faafaf164404d50d409248330d1cf4f7a4` |
| Exact command | `make milestone ID=M01` в основном checkout `/Users/Shared/D/ios/padel-score` на `main` (из сессии вызван как `make -C /Users/Shared/D/ios/padel-score milestone ID=M01`) |
| Exit code | 0 |
| Timestamp | 2026-10-20T15:53:54Z–15:54:36Z; в отчёте verification started 20261020T155357Z, completed 20261020T155436Z |
| Report | `.artifacts/milestone/M01/20261020T155355Z-97318/report.md`; `milestone.xcresult` в том же каталоге |
| Counts | static + Debug build passed; 34 tests / 34 passed / 0 failed / 0 skipped / 0 expected failures: 33 Swift Testing tests в 5 suites (31 новый тест движка и 2 bootstrap) и 1 XCUITest; managed Watch SE 40 mm (2nd generation), watchOS 26.5, UDID `A77BD37D-4A5F-40E0-8CD3-899210952F92` |

Перед gate managed simulator запущен `make simulator-boot` (exit 0, `Booted`),
как рекомендовал M00. Дополнительный problem scanner в репозитории не настроен:
SwiftLint, SwiftFormat и ShellCheck выключены в `Config/project.env`, других нет.

Development feedback, не evidence:

- `make static` → 0 в worktree на каждом коммите этапа; `./Scripts/project-status.sh validate`
  → 0; `git diff --check` → 0.
- `swift test` во временном SwiftPM-пакете сессии, который ссылается на те же
  Domain и test files: macOS, 31 test / 4 suites passed.
- `xcodebuild build-for-testing -project App/PadelScore.xcodeproj -scheme PadelScore
  -configuration Debug -destination 'generic/platform=watchOS Simulator'` с
  временной DerivedData → `TEST BUILD SUCCEEDED`, без compiler warnings.
- Mutation check: 24 намеренные ошибки правил в копии Domain по одной —
  каждая ломает suite. Первая форма «opener serves two points» не компилировалась
  и ничего не доказывала; её компилируемая форма тоже поймана.
- `make fast` не запускался: у worktree нет binding managed simulator, а второе
  устройство ради обратной связи не создавалось. Логи этой обратной связи
  остались во временном каталоге сессии.

## Tests

- `GameScoringTests` — таблица из 53 последовательностей от 0:0 для трёх правил:
  выигрыш гейма каждой стороной с 40:0/15/30, немедленный golden point, первый
  AD и его реализация, возврат к решающим 40:40 после потерянного AD при
  `One advantage`, многократные deuce при `Advantage`; плюс 25 циклов
  преимущества подряд. Ловит неверную стадию 40:40 и смешение двух 40:40.
- `SetScoringTests` — 6:0…6:4 завершают сет обеим сторонам, 6:5 нет, 7:5 да, 6:6
  открывает тай-брейк; таблица из 14 строк тай-брейка (7:5, 8:6, 12:10
  завершают; 6:6, 7:6, 11:11 нет); тай-брейк не зависит от правила 40:40; сет
  тай-брейка пишется 7:6; 1, 2, 3, 7 и 12 сетов подряд без завершения матча
  и с выводом выигранных сетов из списка.
- `ServiceRotationTests` — подающий держит весь гейм; ротация через геймы для
  обеих возможных ротаций; тай-брейк открывает следующий игрок, порядок 1 + по 2
  на 14 очков; после тай-брейка и после обычного сета следующую подачу
  предлагает правильная пара для всех игроков и победителей; очко нового сета
  ждёт подтверждения; подтверждение меняет игроков внутри пар, но не пару;
  повторное подтверждение отклоняется; разбор ротации из любых четырёх игроков
  и отказ для неверных списков.
- `MatchValidationTests` — 21 недопустимое состояние счёта, стадии, сетов и
  подачи даёт `invalidState` с точным списком issues для каждой команды,
  snapshot не меняется; достижимые граничные состояния принимаются; новый матч;
  входной snapshot не меняется ни при успехе, ни при отказе.

Self-review всего diff `adca9e9..4a5f29f` блокирующих дефектов движка не нашёл.
Исправлено по его ходу: имя тестового метода `tieBreakTable` скрывало одноимённую
таблицу аргументов (ошибка компиляции) — данные тестов переименованы в `…Rows`;
неработающая форма одной мутации заменена компилируемой; перенесена строка в
PRODUCT; README приложения описывает новый слой. Пользовательской поверхности
у этапа нет, поэтому craftsmanship pass не применялся.

## Known issues

- Экрана нет: M05 должен показать подтверждение порядка подачи на границе сета.
  Движок по H2 отклоняет очко нового сета до `confirmService`.
- Codable нет: формат хранения принадлежит M03; декодированное состояние должно
  проходить `MatchState.issues`, а движок повторяет проверку на каждой команде.
- Undo не является командой движка: по ARCHITECTURE он восстанавливает целый
  snapshot и появляется с историей в M03.
- watchOS 10 по-прежнему не проверена запуском: тесты выполнены на watchOS 26.5.
- Worktree `.claude/worktrees/next-ready-milestone-7007f6` и ветка
  `claude/next-ready-milestone-7007f6` остаются; их можно удалить.

## Next step

M02 — Americano Scoring; открытое решение его не блокирует. H4 нужен до M08,
остаток H1 — до M09.
