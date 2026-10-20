# M00 — Watch-only Bootstrap handoff

**Policy status:** current

## Milestone

`M00` — Watch-only Bootstrap; `DONE`. Сборка и тесты приложения проверены.
Полный self-test инструментария и повтор после исправления единственного
дефекта состава тестовой копии записаны ниже отдельно.

## Summary

По прямому поручению владельца создан `App/PadelScore.xcodeproj`. Это заменяет
исходное условие о создании проекта только владельцем. Название Padel Score занято
в публичном App Store; владелец выбрал **Padel Score — Wrist**. Публичный поиск
нового имени не нашёл точного совпадения, но имя не резервировалось в App Store Connect.

Watch executable `PadelScoreWatch` использует `com.dziachenka.padelscore.watchapp`;
container `PadelScore` — `com.dziachenka.padelscore`. Shared scheme `PadelScore`
собирает оба и запускает hosted Swift Testing и XCTest UI targets. Минимум —
watchOS 10.0, язык — английский, Swift 6 со strict concurrency, version/build 1.0 (1).
Есть минимальные Home/About, String Catalog и структура каталога ресурсов.
Игровые экраны и итоговая иконка остаются следующим этапам.

Сохранена существующая история Git. `make initialize` и установка hooks не
выполнялись. Настроен отдельный managed Watch SE 40 mm (2nd generation),
watchOS 26.5, UDID `A77BD37D-4A5F-40E0-8CD3-899210952F92`. iPhone-пара не создавалась.

## Changed files

- `App/PadelScore.xcodeproj/` — четыре targets, shared scheme, Debug/Release, упаковка.
- `App/PadelScoreWatch/` — SwiftUI bootstrap, английские строки, каталоги ресурсов.
- `App/PadelScoreWatchTests/`, `App/PadelScoreWatchUITests/` — реальные bundle/UI tests.
- `App/README.md` — открытие проекта, targets, проверки и границы M00.
- `Config/project.env`, `.iosai-project` — product mode, Watch identity и происхождение инструментария.
- `.gitignore` — локальные IDE-файлы и binding симулятора; существующая `.idea/` сохранена.
- `Scripts/lib/platform.sh`, `Scripts/self-test.sh` — безопасная поддержка системного
  алиаса `/tmp` для путей Xcode и 20 регрессионных проверок.
- `AI/PRODUCT_BRIEF.md`, `AI/PRODUCT.md`, `AI/ARCHITECTURE.md`, `AI/DESIGN.md`,
  `AI/DEVELOPMENT_PLAN.md`, `AI/PROJECT_STATUS.md`, `AI/milestones/M00-template-bootstrap.md`
  — решения владельца, фактическая конфигурация, состояние этапа.
- `AI/handoffs/M00-handoff.md` — эта запись.

## Validation

| Field | Evidence |
| --- | --- |
| Verified SHA | `e3baec27721079d8dd5388de5d4b7de8045d86fb` |
| Exact command | `make milestone ID=M00`; `make milestone ID=M00 CANDIDATE=e3baec27721079d8dd5388de5d4b7de8045d86fb` |
| Exit code | 0 у обоих запусков |
| Timestamp | Первый: 2026-10-20T14:49:18Z–14:50:13Z; повтор: 2026-10-20T14:50:33Z–14:51:31Z |
| Report | `.artifacts/milestone/M00/20261020T144916Z-78277/report.md`; `.artifacts/milestone/M00/20261020T145033Z-2003/report.md`; в каждом каталоге `milestone.xcresult` |
| Counts | В каждом запуске: static + Debug build, 3 tests / 3 passed / 0 failed / 0 skipped / 0 expected failures |

Дополнительная проверка:

- `make template-check` → 0, `.artifacts/M00-bootstrap/template-check.log`.
- `make static` → 0, `.artifacts/M00-bootstrap/static.log`; затем static повторён
  обоими milestone gates. Не включённые optional linters и незаполненная публичная
  site identity не объявлены проверенными.
- `make fast` → 0 после исправлений и готовности симулятора, 3/3:
  `.artifacts/fast/20261020T144637Z-95366/report.md`, `fast.xcresult`.
- `make release CANDIDATE=e3baec27721079d8dd5388de5d4b7de8045d86fb` → ожидаемый
  `NOT_READY`: verify-release exit 65 / Make exit 2, так как нет readiness milestone
  в REVIEW. `.artifacts/release/20261020T145143Z-7027/report.md`.
  Это проверка отказа, а не успешная release-проверка.
- `./Scripts/self-test.sh --case watch_plist_paths --jobs 1` → 0,
  1 case / 20 checks / 0 failures. `.artifacts/M00-bootstrap/platform-path-after.log`.
- `git diff --check`, `git diff --cached --check`, `./Scripts/project-status.sh validate`
  → 0 перед коммитом кандидата.

Завершающий коммит содержит только Markdown-записи под `AI/`.
Его отдельная проверка: `make static`, `./Scripts/project-status.sh validate`,
`./Scripts/project-status.sh continuity e3baec27721079d8dd5388de5d4b7de8045d86fb`.
Логи завершающей проверки: `.artifacts/M00-bootstrap/continuity-static.log`,
`continuity-status.log`, `continuity-records.log`; точные exit codes и SHA
завершающего коммита — в `.artifacts/M00-bootstrap/continuity.json`.

### Происхождение и self-test инструментария

Upstream SHA неизвестен. Первый локальный импорт —
`bc0ccd55b9893d2ee863f8d85e29f339e465a937`; его Scripts/Config/Makefile/AGENTS/WORKFLOW
совпадают с baseline этой сессии `f425fe0e6431f3faea2f933d26851f5119649dc7`.

Первый полный `make self-test` на копии f425fe0 остановлен: его product documents
уже содержат M01–M10 и не являются шаблонными fixture inputs. Дополнительно sandbox
запрещал `ps`, необходимый lease fixtures. Это **ABORTED_INCOMPATIBLE_FIXTURE**,
без итоговых counts; не успешная проверка. Сохранены
`.artifacts/M00-bootstrap/template-self-test.log` и `.json`.

Для честной полной проверки создана отдельная реконструкция: исходные документы
из bc0ccd5, восстановленные `.githooks/pre-commit` и `.artifacts/.gitkeep` из
f425fe0, текущие `.gitignore`, `Scripts/lib/platform.sh`, `Scripts/self-test.sh`.
Точный fixture commit — `e1210a81a17a95b12b91d8678b562b6f39e4b7e4`,
tree — `191aa06c378eb5f6dfd07e60bf1cc81cc0ef8804`. Это не upstream baseline.
SHA256 и Git blob каждого добавленного файла записаны в
`.artifacts/M00-bootstrap/reconstructed-template-self-test.json`.
Полный `make self-test` выполнен вне sandbox в
2026-10-20T14:46:49.601749Z–15:09:07.012032Z: Make exit 2 / script exit 65,
97 cases, 2145 checks passed, 1 failed. Единственный failure —
`documentation_consistency`: из первоначального импорта в реконструкции остался
продуктовый `AI/handoffs/product-brief.md`, хотя проверка универсального шаблона
требует в этом каталоге только `.gitkeep`. Остальные 96 cases прошли. Лог:
`.artifacts/M00-bootstrap/reconstructed-template-self-test.log`.

Исправлен только состав временной копии: удалён этот продуктовый handoff, штатный
`.gitkeep` уже существовал. Новый fixture commit —
`3c5f259d15ea94b4ecb70e23f6661ee3112ef2c4`; единственный diff сохранён в
`.artifacts/M00-bootstrap/reconstructed-template-targeted-fix.patch`.
Команда `./Scripts/self-test.sh --case documentation_consistency --jobs 1`
выполнена 2026-10-20T15:10:02.062420Z–15:10:02.774881Z: exit 0,
1 case / 78 checks passed / 0 failed. Лог и metadata:
`.artifacts/M00-bootstrap/reconstructed-template-documentation-rerun.log` и `.json`.
Сами проверки не менялись; hashes обоих изменённых Scripts совпадают с кандидатом
приложения и с полным прогоном. Полная suite на новом fixture SHA не повторялась:
это успешный повтор затронутой проверки после исправления её входных данных,
а не заявление об успешном полном прогоне на новом SHA.

`.iosai-project` сохраняет исходный fixture SHA полного прогона; этот handoff
дополняет его исправлением и точными результатами. Продуктовый handoff в основном
репозитории сохранён. В suite Xcode и Simulator заменены stubs;
она не доказывает работу приложения.

## Tests

Два hosted unit tests проверяют фактический bundle: Watch-only, отсутствие
companion key, minimum OS, английскую identity и версию. UI test запускает
приложение, открывает About, проверяет имя/версию и возвращается Home.
Просмотрены реальные изображения Home и About из UI test, без обрезанного текста;
проверены нативная кнопка Back и доступная кнопка About. Снимки:
`.artifacts/M00-bootstrap/ui-attachments/manifest.json` и `home.png`.

Self-review исправил отсутствующий scaffold AppIcon и привязку Foundation к
несуществующей версии SDK: file references используют SDKROOT. Иконка не считается
готовой к выпуску. Первый запуск тестового хоста получил отказ системной оболочки
свежего симулятора; после `make simulator-boot` и успешного прямого запуска выполнены
полные повторные тесты без пропусков. Подготовка симулятора должна включать boot
и ожидание готовности перед первой проверкой.
После проверок собственный симулятор выключен через `make simulator-shutdown`
(exit 0); чужие устройства не затрагивались.

Реальная сборка также выявила ошибку существующего validator: Xcode возвращает
`/tmp/...`, а cache root записан `/private/tmp/...`. Исходный helper из f425fe0
отдельно воспроизвёл exit 64 на алиасе при успешном canonical path. Исправление
нормализует только подтверждённый системный `/tmp → /private/tmp`; symlink внутри
пути, traversal, sibling root и произвольный алиас по-прежнему отвергаются.
Новая regression case до исправления: 18 passed / 2 failed; после — 20/20.
Evidence: `.artifacts/M00-bootstrap/platform-path-{before,after}.log` и metadata.
Дополнительное чтение агентом помогло проверить project/scheme; это не release audit.

## Known issues

- watchOS 10 runtime не установлен: M00 проверяет сборку с target 10.0 и выполнение
  на 26.5. Проверка самого минимального runtime остаётся обязательной до финальной готовности.
- Подпись для физических часов требует выбора development team в Xcode; она не
  настроена, Apple Developer/App Store Connect records не создавались.
- Точное наличие имени в App Store Connect не подтверждено; имя не зарезервировано.
- Финальная иконка — M04. Scoring, persistence, edit и commerce ещё не реализованы.
- В сборке Apple packaging stub выдавал предупреждение actool о trait set Watch6,12
  на 26.5; оно не остановило сборку, проверку упаковки или тесты.
- H2 нужен до M01; H4 — до M08; остаток H1 (публичные реквизиты) — до M09.

## Next step

Следующий продуктовый этап — M01 после выбора владельцем правил H2 (завершение
сета и тай-брейк). M00 завершён; в этой сессии M01 не начинается.
App Review, upload, публикация и архивация не выполнялись.
