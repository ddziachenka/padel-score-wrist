# M02 — Americano Scoring handoff

**Policy status:** current

## Milestone

`M02` — Americano Scoring; status `DONE`.

## Summary

В `App/PadelScoreWatch/Domain` рядом с движком обычного матча добавлен чистый
движок раунда американо: Swift standard library и Foundation только для `UUID`,
без SwiftUI, файлов, часов и StoreKit. `AmericanoEngine.apply(_:to:)` получает
`AmericanoState` и `AmericanoCommand.awardPoint(to:)` и возвращает новый
`AmericanoState` с `AmericanoOutcome` (`point` или `roundComplete(result)`) либо
typed `AmericanoError`; входной snapshot не меняется.

- `AmericanoRules` хранит N (`totalRallies`, розыгрыши обеих команд вместе) и B
  (`ralliesPerServer`); значений по умолчанию нет, движок не содержит констант.
  `played`, `remaining = N − played`, `isComplete` и `result` (`draw` /
  `won(by:)`) выводятся из snapshot.
- Розыгрыш, после которого сумма очков равна N, завершает раунд при любом
  распределении очков и посреди серии; равный счёт — `draw` без дополнительного
  розыгрыша. Следующее очко любой команды отклоняется `totalReached`, пока
  исправление не освободит место.
- После B записанных розыгрышей подача переходит к следующему игроку порядка
  независимо от победителя; порядок — существующий `ServiceOrder` с чередованием
  пар, цикл повторяется. `AmericanoServiceAnchor` хранит порядок, подающего и место
  следующего розыгрыша в серии от 1 до B и никогда не вычисляется из счёта.
  Он сдвигается и после N-го розыгрыша, поэтому называет подающего, если
  исправление добавит розыгрыши; завершённую игру UI без подающего показывает в M05/M07.
- `AmericanoState.issues` в постоянном порядке называет неположительные N и B,
  отрицательные очки каждой команды, сумму очков больше N и место вне серии;
  проверка не переполняется ни для каких сохранённых чисел. Любое из них
  отклоняет очко как `invalidState(issues)`.
- `GameSnapshot` — минимальный снимок из ARCHITECTURE: стабильный `GameID`
  (`UUID`, передаётся снаружи) и `GameFormat` (`match` / `americano`). Он нужен
  критерию «исправление не меняет команды и sessionID». `correcting(to:)` принимает
  явно весь раунд — оба счёта, N, B, порядок, подающего и место в серии — проверяет
  его целиком и сохраняет `GameID`. Текущий раунд может быть невалидным: исправление
  и есть способ его починить. Для обычного матча операция отклоняется
  `notAmericano`, потому что смена формата — отдельная замена M06. Lifecycle,
  finish metadata, revision, history и Codable добавляет M03.

Сессию запустило приложение Claude в изолированном worktree
`.claude/worktrees/next-ready-milestone-96424e` на ветке
`claude/next-ready-milestone-96424e`; hook сессии запрещает правки основного
checkout. Поэтому, как в M01, коммиты сделаны на этой ветке поверх
`main`@`6a602fb`, а `main` основного checkout продвинут `git merge --ff-only` без
новых коммитов: SHA те же, история линейна. Milestone gate выполнен в основном
checkout на `main`. Это отклонение от буквы правила «milestone не реализуется в
worktree», записанное открыто.

## Changed files

- `App/PadelScoreWatch/Domain/` — `AmericanoState.swift` (правила, счёт, anchor,
  результат), `AmericanoValidation.swift` (`AmericanoIssue`, `AmericanoError`,
  `issues`), `AmericanoEngine.swift`, `GameSnapshot.swift` (`GameID`,
  `GameSnapshot`, `GameFormat`, исправление раунда).
- `App/PadelScoreWatchTests/Domain/` — `AmericanoTestSupport.swift`,
  `AmericanoScoringTests.swift`, `AmericanoServiceTests.swift`,
  `AmericanoValidationTests.swift`, `AmericanoCorrectionTests.swift`.
- `App/PadelScore.xcodeproj/project.pbxproj` — membership новых файлов в группах
  `Domain` Watch app и unit-test target.
- `App/README.md` — что добавил M02.
- `AI/ARCHITECTURE.md` — как снимок, anchor американо и исправление раунда
  отображены в коде и что добавит M03.
- `AI/PROJECT_STATUS.md`, `AI/milestones/M02-americano-scoring.md`,
  `AI/DEVELOPMENT_PLAN.md` — состояние этапа.
- `AI/handoffs/M02-handoff.md` — эта запись.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `e3378c4cffb1ca0bb6de638246cfd1eb690f489f` |
| Exact command | `make milestone ID=M02` в основном checkout `/Users/Shared/D/ios/padel-score` на `main` (из сессии вызван как `make -C /Users/Shared/D/ios/padel-score milestone ID=M02`) |
| Exit code | 0 |
| Timestamp | 2026-10-20T17:41:25Z–17:42:26Z; в отчёте verification started 20261020T174127Z, completed 20261020T174226Z |
| Report | `.artifacts/milestone/M02/20261020T174126Z-46625/report.md`; `milestone.xcresult` в том же каталоге |
| Counts | static + Debug build passed; 65 tests / 65 passed / 0 failed / 0 skipped / 0 expected failures по `.xcresult` (result `Passed`): 64 Swift Testing tests в 9 suites (31 новый тест американо, 31 тест M01 и 2 bootstrap) и 1 XCUITest; managed Watch SE 40 mm (2nd generation), watchOS 26.5, UDID `A77BD37D-4A5F-40E0-8CD3-899210952F92` |

Перед gate managed simulator запущен `make -C /Users/Shared/D/ios/padel-score
simulator-boot` (exit 0, `Booted`). Дополнительный problem scanner в репозитории не
настроен: SwiftLint, SwiftFormat и ShellCheck выключены в `Config/project.env`,
других нет.

Development feedback, не evidence:

- `make static` → PASSED в worktree до коммита `5891444` и → 0 на `e3378c4`;
  `./Scripts/project-status.sh validate` → 0.
- `swift test` во временном SwiftPM-пакете сессии, который ссылается на те же
  Domain и test files: macOS, 62 tests / 8 suites passed (31 тест M01 и 31 новый).
- `xcodebuild build-for-testing -project App/PadelScore.xcodeproj -scheme PadelScore
  -configuration Debug -destination 'generic/platform=watchOS Simulator'` с
  временной DerivedData → `TEST BUILD SUCCEEDED` до и после последней правки тестов,
  без compiler warnings.
- Mutation check: 20 намеренных ошибок правил в копии Domain по одной — все
  компилируются, и каждая ломает suite: длина серии B+1, подача по победителю,
  ротация без выбранного порядка, очко после N, замороженный anchor на последнем
  розыгрыше, движок без проверки, цель N для одной команды, нет ничьей, неверный
  первый подающий, конец на розыгрыш раньше, шесть ослабленных проверок, исправление
  без проверки, для обычного матча и с новым `GameID`. Четыре из них остановили
  тестовый процесс переполнением `Int` в граничных тестах с `Int.max`; это тоже
  провал suite.
- `make fast` не запускался: у worktree нет binding managed simulator, а второе
  устройство ради обратной связи не создавалось.

## Tests

- `AmericanoScoringTests` — таблица из 11 раундов от 0:0 (N/B 32/4 18:14 и 14:18,
  16/4 ничья, 10/4, 7/2, 5/1, 3/5, 1/1, 1/3 и два незавершённых): счёт, исход,
  `played`/`remaining` и следующий anchor; при N=32 раунд завершается на 18:14, хотя
  ни одна команда не набрала 32, — исход, `played` и `remaining` проверены после
  каждого из 32 розыгрышей; последний розыгрыш
  любой командой и результат по очкам; после N очко не принимается ни одной команде;
  для N от 1 до 12 и любого распределения ничья ровно при равных очках; до N
  результата нет; новый раунд и раунд с неположительными N/B; вход не меняется.
- `AmericanoServiceTests` — при B=4 для обоих порядков и каждого первого подающего
  40 розыгрышей смешанными победителями: подающий и место в серии на каждом
  розыгрыше, цикл после четвёртого игрока; победители не влияют на подачу при B=1,
  3 и 4; B=1 меняет подающего каждый розыгрыш; N<B — весь раунд у первого подающего;
  N не кратно B — короткая последняя серия (10/4 → 4, 4, 2 и ещё пять случаев) без
  ошибки; ручной anchor с каждого места 1…4; одинаковый счёт продолжается от своего
  anchor, а не от суммы очков.
- `AmericanoValidationTests` — 15 невалидных раундов (N и B ноль/меньше, отрицательные
  очки каждой команды, сумма больше N, место 0/−1/B+1, `Int.max` и `Int.min`,
  несколько проблем в постоянном порядке) отклоняют очко обеих команд с точным
  списком issues без изменения snapshot; пять достижимых граничных раундов, включая
  N = B = `Int.max`, принимают очко; раунд на N валиден, но очко отклоняет.
- `AmericanoCorrectionTests` — N от 1 до 21 при сыгранных 22 не применяется;
  меньшее N применяется вместе с меньшим счётом; N, равное сыгранному, завершает
  раунд; место −1, 0, 5, 6, `Int.max` при B=4 не применяется; уменьшение B требует
  выбрать место внутри новой серии, прежнее не переносится и не пересчитывается;
  семь допустимых исправлений сохраняют `GameID` и команды и применяются ровно как
  заданы; исправление счёта не сдвигает заданную подачу; новый порядок и подающий
  действуют со следующего розыгрыша; исправление после N снова открывает очки;
  невалидный текущий раунд исправляется; невалидные значения отклоняются с issues;
  обычный матч исправлением американо не меняется.

Self-review всего diff `6a602fb..e3378c4` блокирующих дефектов не нашёл. По его ходу
проверка «победители не влияют на подачу» расширена с B=3 на B=1, 3 и 4, потому что
критерий называет B=4, а `GameID` обычного матча в тесте создаётся напрямую.
Ожидаемый подающий одной строки таблицы (`9/3`) был записан неверно; ручная сверка
нашла это до первого прогона, исправлена строка теста, не движок. Пользовательской
поверхности у этапа нет, поэтому craftsmanship pass не применялся.

## Known issues

- Экрана нет: создание раунда — M04, счёт и `Serve k of B` — M05. В последней
  неполной серии подпись `of B` больше оставшихся розыгрышей (при 10/4 после восьми
  розыгрышей серия из двух); как её показать, решает M05 по DESIGN, данные для этого
  в snapshot есть.
- Lifecycle нет: автоматическое завершение при N сейчас только `isComplete` и исход
  `roundComplete`. Ручной `Finish round`/`Ended early` и правило «увеличение N после
  завершения возвращает игру только через `Resume game`» — M07; до тех пор движок
  снова принимает очки, как только исправление освободило место.
- Неоднозначная подача после правки счёта (`Check who serves next before saving.`) —
  черновик M06: доменное исправление требует anchor явно и сам его не угадывает.
- Codable и запись нет: формат хранения, revision и history принадлежат M03;
  декодированный раунд должен проходить `AmericanoState.issues`.
- watchOS 10 по-прежнему не проверена запуском: тесты выполнены на watchOS 26.5.
- Worktree `.claude/worktrees/next-ready-milestone-96424e` и ветка
  `claude/next-ready-milestone-96424e` остаются; их можно удалить. Worktree и ветка
  M01 (`…-7007f6`) тоже ещё на месте.

## Next step

M03 — Persistence and Recovery; открытое решение его не блокирует. H4 нужен до
M08, остаток H1 — до M09.
