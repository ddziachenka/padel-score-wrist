# Architecture

Технический контракт самостоятельного приложения для Apple Watch. Прямые решения
владельца — Watch-only, оба формата счёта, исправление всех введённых данных и
английская v1 — сохранены. Архитектурное направление одобрено владельцем 2026-10-20;
минимальная watchOS 10 выбрана отдельно в тот же день, правило сета H2 — тоже.
H1 остаётся открытым; H4 закрыт владельцем 2026-10-21. Одобрение не означает,
что приложение уже реализовано или проверено.

**Status:** approved direction — открытые решения сохранены
**Approved by:** владелец проекта, сообщение «одобряю»
**Approved on:** 2026-10-20
**Updated:** 2026-10-20

Поведение и бизнес-решения принадлежат [PRODUCT.md](PRODUCT.md), интерфейс —
[DESIGN.md](DESIGN.md), выполнение и доказательства — [WORKFLOW.md](WORKFLOW.md).
Открытый H1 в PRODUCT блокирует зависимую реализацию, а не заменяются
примерными значениями из HTML-макетов.

---

## Selected technologies

| Concern | Choice | Rationale | Notes |
| --- | --- | --- | --- |
| UI framework | SwiftUI, нативный жизненный цикл `App`, Observation | Единый интерфейс watchOS; небольшое состояние и собственные кнопки счёта не требуют другого UI-фреймворка | Не переносить HTML-макеты как WebView; WatchKit используется только для нужных системных адаптеров, например haptics |
| Swift language mode | Swift 6 со строгой проверкой concurrency | Ошибки передачи изменяемого состояния обнаруживаются при сборке | Конкретный компилятор фиксируется вместе с Xcode в M00 |
| Concurrency | `@MainActor` для presentation; actor для сериализованной записи; `async/await` для StoreKit | Только один владелец игровых изменений; сеть покупки не блокирует счёт | Движок — синхронные чистые функции |
| Persistence | Foundation `Codable`, версионированный локальный файл с атомарной заменой и резервной предыдущей копией | Нужны небольшие согласованные снимки одной игры, а не запросы по большой базе | Не `UserDefaults` для игрового состояния; протокол хранилища отделяет формат от логики |
| Networking | Собственного сетевого клиента нет | Счёт, создание, исправление и завершение локальны | StoreKit общается с Apple; публичные legal/support URL открываются только по действию человека |
| Dependency injection | Явные initializer-параметры и небольшие протоколы | Зависимости видны, тесты подставляют хранилище и магазин | Без DI-контейнера и глобальных singleton-сервисов |
| Navigation | Типизированный `NavigationStack`, маршрут принадлежит composition root | Список настроек и отдельные редакторы укладываются в нативную навигацию | Экран матча не является горизонтальной каруселью; навигация не хранит копию счёта |
| Testing frameworks | Swift Testing для domain/service; XCTest/XCUITest для UI; StoreKit Testing | Правила проверяются без экрана, реальные маршруты — через Watch UI | Все обязательные тесты входят в shared scheme |

Apple описывает SwiftUI как основу нативного watchOS UI. Observation доступен для
приложений с минимумом watchOS 10, а NavigationStack — watchOS 9. Поэтому требование
более новой ОС из этих API не следует; владелец выбрал watchOS 10 в решении H3.
[SwiftUI для watchOS](https://developer.apple.com/documentation/watchos-apps/building_a_watchos_app),
[Observation](https://developer.apple.com/documentation/SwiftUI/Monitoring-model-data-changes-in-your-app),
[NavigationStack](https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types).

## Deployment target

| Field | Value |
| --- | --- |
| App platform: iOS or watchOS Watch-only | **Подтверждено: watchOS Watch-only**; нет iPhone companion, телефонного UI и Watch Connectivity как зависимости |
| Minimum iOS or watchOS version | **Подтверждено: watchOS 10.0; H3 закрыт владельцем 2026-10-20** |
| Why that version | Достаточен для Observation, NavigationStack и локальной модели; более высокий минимум сокращает охват без необходимой для счётчика функции |
| Devices | Apple Watch, совместимые с watchOS 10 и новее; конкретные компактный и крупный размеры и доступные среды проверки фиксируются в M00 |
| Orientations | Системная ориентация часов, настройки запястья и Digital Crown; ручного portrait/landscape режима нет |
| Additional surfaces supported by the chosen platform | Только основное Watch-приложение в MVP; complications, widgets, App Intents и Action button не включены |

**Решение H3:** владелец явно выбрал «watchOS 10: достаточно нужных API,
шире охват устройств». Минимум утверждён; выбор не является доказательством
совместимости приложения. Проверка на watchOS 10 остаётся обязательной, а подбор
конкретных моделей и runtime — инженерная задача в этих границах.

**Toolchain — исходная среда M00 и обновление M08; результаты проверок записываются отдельно:**

| Field | Value |
| --- | --- |
| Xcode version | Локально обнаружен Xcode 27.0, build 27A266a, 2026-10-20 |
| Swift version | Swift 6 language mode, strict concurrency; локальный компилятор Apple Swift 6.4 (`swiftlang-6.4.0.34.1`) |
| SDK used to build | watchOS SDK 27.0; Debug Watch executable и packaging container собраны Xcode 27.0 в M00 |
| Oldest runtime tested against | watchOS 26.1 (`23S36`), Apple Watch SE 40 mm (2nd generation): четыре StoreKit integration tests M08 прошли 2026-10-21. Полные результаты — в M08 handoff. watchOS 10 ещё не проверена; её проверка обязательна до финальной готовности |

Инвентаризация 2026-10-20 обнаружила доступный Watch runtime watchOS 26.5
(build 23T570), `com.apple.CoreSimulator.SimRuntime.watchOS-26-5`. Совместимый
компактный device type — Apple Watch SE (40mm), 2nd generation,
`com.apple.CoreSimulator.SimDeviceType.Apple-Watch-SE-40mm-2nd-generation`.
Эта пара выбрана для основной managed среды M00 и создан отдельный симулятор
проекта; она не доказывает работу на watchOS 10. Runtime минимальной ОС сейчас
не установлен. Во время инициализации контрактов устройства не создавались;
создание выполнено позже по поручению подготовить Xcode-проект.

M08 закрепляет watchOS 26.1 (`23S36`) для автоматической проверки покупки.
На 26.5 StoreKitTest отвергает настройку с Code=3; на 27.0 (`24R362`)
покупка возвращает `.unknown` вместо настроенной сетевой ошибки. В test plan
локальный StoreKit включён до запуска host app; после имитации сбоя тест
восстанавливает настройки через `resetToDefaultState()`, не удаляя транзакции.
Симуляторы 26.5 и 27.0 и их локальные bindings сохранены для воспроизведения.
Это выбор среды проверки, а не изменение минимальной поддерживаемой ОС.

M00 проверил inventory, передал выбранные Watch device type/runtime в
`configure-project.sh --platform watchOS` и выполнил `make simulator-setup`.
Managed simulator принадлежит этому checkout; чужое устройство
или paired iPhone не нужны. Если для принятого минимума нет доступного runtime или
другой требуемой среды, зависимая проверка остаётся заблокированной; наличие более
нового симулятора не доказывает работу на минимальной ОС.

## Dependency boundaries

**Identity:** проект `App/PadelScore.xcodeproj`, shared scheme `PadelScore`.
Watch executable `PadelScoreWatch` — `com.dziachenka.padelscore.watchapp`;
packaging container `PadelScore` — `com.dziachenka.padelscore`. Название
`Padel Score — Wrist` задаётся обоим targets; version/build синхронизированы.
Bundle IDs выбраны агентом по прямому поручению владельца; они пока не
зарегистрированы в Apple Developer / App Store Connect.

Стрелка означает «импортирует / зависит от»:

```text
App composition root → Features → Domain
         ↓                ↓
       Services ───────→ Domain
```

| Layer | May import | May never import | Why |
| --- | --- | --- | --- |
| Domain | Swift standard library; Foundation только для value types/кодирования | SwiftUI, WatchKit, StoreKit, файловую систему и concrete service | Счёт проверяется детерминированно без UI и устройства |
| Services | Domain, Foundation, Observation для application stores; StoreKit или WatchKit только в соответствующем адаптере | Features и App | Хранилище, магазин и haptics не управляют экранами |
| Features | SwiftUI, Observation, Domain и service protocols | Concrete file store, StoreKit transaction API, чужое mutable состояние | View отправляет intent единственному владельцу |
| App | Все слои для сборки зависимостей | Новые правила счёта внутри composition root | Здесь создаются ровно по одному session store и entitlement store |

### External dependencies

| Dependency | Version | What it does | Why not Apple's framework | Approval/rationale |
| --- | --- | --- | --- | --- |
| Сторонних библиотек нет | Не применимо | Системные SwiftUI, Foundation, StoreKit и WatchKit покрывают MVP | Причины заменять их пока нет | Направление одобрено; новая внешняя зависимость — отдельное человеческое решение |

Локальные Swift packages на старте не предлагаются. Если появятся внешние SPM
зависимости, зафиксировать версию, причину и разрешённый сетевой resolve в соответствии
с WORKFLOW; не добавлять SDK аналитики или покупок транзитивно.

## State ownership

| State | Owner | Lifetime | Who may mutate it | Observed by |
| --- | --- | --- | --- | --- |
| Активная игра, её ревизия и undo-цепочка | `SessionStore` на `@MainActor` | Между запусками через repository | Только обработчик domain commands после валидации и успешной записи | Игровой экран, редактор, результат |
| Последняя завершённая игра и её undo-цепочка | Тот же `SessionStore` | До замены следующим завершённым результатом или удаления | Finish/resume/delete commands | Экран результата/старта |
| Черновик создания/исправления | Feature draft с base revision | До Save/Cancel; не считается сохранённой игрой | Соответствующий редактор | Только его поля и preview |
| Последние настройки создания | `SessionStore` | Между запусками | Успешный старт/сохранение настроек | Создание игры |
| Право доступа, загрузка продукта, purchase/restore state | `EntitlementStore` | Жизнь процесса; источник права — проверенные StoreKit данные | Только этот store и инъецированный store adapter | Старт игры, paywall, настройки |
| Учёт бесплатного использования | Локальный `UsageLedger`, обновляется транзакционно вместе с игрой | Между запусками; политика H4 в PRODUCT | Только session command, согласованный с access policy | EntitlementStore получает read-only оценку |
| Навигация и transient ошибки | Composition root/feature presentation | Процесс/экран | UI intents | Соответствующие views |
| `forcePremium` | DEBUG-only `DebugPremiumOverride` | Между Debug-запусками | Developer control через EntitlementStore | Только EntitlementStore |

| Question | Answer |
| --- | --- |
| Where does app-wide state live? | `SessionStore` и `EntitlementStore`, созданные один раз в composition root; бизнес-снимок не дублируется в каждом экране |
| How does a view get it? | Через явно переданный observable presentation model; вложенным view передаются значения и действия |
| What survives a launch? | Активная/последняя завершённая игра, правила, сервисный anchor, undo, последние настройки и usage ledger; entitlement заново сверяется со StoreKit |
| What survives backgrounding but not termination? | Несохранённый draft и позиция прокрутки могут жить пока жив процесс; восстановление draft после termination не обещано, сохранённая игра остаётся |
| Single source of truth for each piece of derived data | Выигранные сеты вычисляются из `completedSets`; американо `played = ourPoints + theirPoints`, `remaining = totalRallies - played`; локализованные подписи и доступные действия — из snapshot, rule phase и entitlement |

Последний результат можно исправить/продолжить только до начала следующей игры,
как предложено в PRODUCT. При наличии новой активной игры старый результат доступен
только для просмотра и заменяется при следующем завершении; два независимых
редактируемых матча одновременно не создаются.

### Снимок игры и команды

`GameSnapshot` содержит stable game ID, mode, lifecycle status, rules, команды/роли,
полный счёт, завершённые сеты, текущий незавершённый сет, фазу deuce/tie-break,
`ServiceAnchor`, finish metadata и revision. У обычного матча нет `bestOf`,
`maxSets` или автоматического завершения всей игры после выигранного сета.
Правило сета и tie-break зафиксировано в PRODUCT (H2 закрыт 2026-10-20). Движок
получает его явным значением `SetPolicy` в правилах матча; других политик нет,
и константы прототипа не используются.

`ServiceAnchor` хранит порядок четырёх игроков, конкретного следующего подающего,
позицию следующего розыгрыша в серии американо и нужный контекст подачи tie-break.
Эта информация задаётся явно при создании/исправлении. После ручной правки счёта
нельзя вычислять подающего из суммы очков: неизвестные розыгрыши не становятся
вымышленной историей. Обычное начисление очка двигает anchor по утверждённым правилам.
В тай-брейке anchor хранит игрока, начавшего его подачу, и сколько из двух очков
текущий подающий ещё подаёт. На границе сета anchor получает предложенный порядок
нового сета без подтверждения; начисление очка до подтверждения отклоняется,
а подтверждение может поменять игроков внутри пар, но не пару, которой правило
отдаёт первую подачу.

В коде с M02 `GameSnapshot` хранит `GameID` и формат: `MatchState` либо
`AmericanoState`; lifecycle, finish metadata, revision и history добавляются
с хранением в M03. Anchor американо — отдельный `AmericanoServiceAnchor`: порядок,
подающий и место следующего розыгрыша в серии от 1 до B. Начисление сдвигает его и
после N-го розыгрыша, поэтому он называет подающего, если исправление освободит место
для новых розыгрышей. Исправление раунда принимает все значения явно, проверяет их
целиком и сохраняет `GameID` той же игры.

С M03 сессия — чистое значение Domain `Session`: `current` (играемая игра либо её
результат, пока его можно исправить и продолжить, вместе с history), `previousResult`
(результат предыдущей игры только для просмотра; он перестаёт быть последним
результатом, когда завершается `current`, и исчезает со стартом следующей игры),
`recentSettings` (правила каждого формата и подача последнего старта), `usage`,
монотонная `revision` и `lastCommand`. `GameSnapshot` получил lifecycle `status`
(`active`/`finished`); как игра закончилась — ранняя остановка американо, незавершённый
сет — выводится из snapshot, поэтому отдельного finish metadata нет. `HistoryEntry`
хранит вид изменения, command ID, ревизию и полное предыдущее состояние игры.
`Session.applying(_:id:expectedRevision:access:)` применяет команду целиком либо не
меняет ничего: запрос со старой ревизией отклоняется, повтор последнего command ID ничего
не меняет, ревизия растёт и при undo. Последний розыгрыш американо и правка, доводящая
играемый раунд до N, завершают игру; Resume раунда на N отклоняется до правки или undo.
`UsageLedger` — множество учтённых game ID и признак точности. Учитывать ли
`gameStarted`/`gameFinished` и разрешать ли старт, решает единый `AccessPolicy`: приложение использует `LifetimeAccess` со снимком
из `EntitlementStore` на момент команды. Пять завершённых game ID закрывают новый
старт без покупки. `OpenAccess` остаётся только для изолированных тестовых fixtures.

Команды: create, award point, undo, replace current snapshot from draft, finish,
resume, delete local game data. Запись history содержит предыдущее полное игровое
состояние без вложенной history, тип команды и revision. Undo восстанавливает всё:
счёт, сеты, режим, правила, конкретного подающего, deuce phase и lifecycle status.
Глубина не обрезается произвольным числом; сохраняется история редактируемой игры,
в том числе при продолжении последнего результата. Это не каталог прошлых матчей.
Undo заменяет только игровой snapshot: актуальный `UsageLedger` и отметки уже
учтённых game ID не откатываются. Поэтому Finish → Undo → Finish той же игры не
списывает ещё одну единицу и не возвращает уже использованную бесплатную единицу.

Смена формата — явный replacement draft с preview нового состояния и проверкой
всех обязательных полей. Старый формат, очки и правила сохраняются одним undo
снимком; прошлые розыгрыши автоматически не переигрываются по новым правилам.
Изменения правил действуют вперёд, конфликт с текущим счётом блокирует Save
с конкретной причиной. Редактор не «исправляет» результат начислением гейма.

## Business-logic placement

| Question | Answer |
| --- | --- |
| Where does business logic live? | `ScoreEngine.apply(command, snapshot)` и validators в Domain; access policy и idempotent usage rules — отдельные value rules |
| What may a view contain? | Layout, typography, accessibility, локализованные подписи, отправку intents; никаких условий победы, сдвига подачи или записи в файл |
| What may a view model contain? | Draft, ошибки полей, focus/navigation и вызов команды; не второй движок счёта |
| How is logic made testable without a UI? | Value input → validated result или typed error; clock/ID/StoreKit/file I/O инъецируются на границе; test fixtures не требуют запуска view |

В частности, стадия второго 40:40 при одном преимуществе — самостоятельное поле,
а не функция видимых `40–40`. Автоматическая остановка американо, допустимость ничьей
и короткой последней серии следуют утверждённому PRODUCT; не наследуются из JS.

Создание игры (M04): `SetupDraft` — значение в памяти, им владеет `NewGameFlow`
(`@MainActor`, Observation), которого создаёт экран New game. Черновик берёт правила своего
формата и подачу из `recentSettings`; без прежней игры все поля ждут выбора. Уход назад за
Setup выбрасывает черновик, ничего не записав. `Start game` с недостающим значением
называет поле и ничего не сохраняет. Редакторы полей пишут в черновик сразу: Done и Back
сохраняют выбор, Cancel возвращает значение, которое поле имело при открытии редактора
(DESIGN → Navigation). Полный черновик отправляет одну команду `.start`
с новыми `GameID` и `CommandID` против текущей ревизии. Неудавшаяся запись остаётся
в `SessionStore` для `Retry` с теми же идентификаторами; `Cancel` или уход из Setup от неё
отказываются. Верхний уровень маршрута не хранится, а выводится из `SessionStore`; путь
стека New game принадлежит `NewGameFlow`. Редакторы чисел предлагают Total rallies 1–999
и Rallies per server 1–99: продукт верхней границы не задаёт, Domain требует лишь
положительных целых, и это обратимый выбор Builder далеко за пределами раунда на корте.
В Debug UI-тесты дают приложению собственный store через launch environment
(`UITestStore`); в Release этого пути нет.

Живой счёт (M05): `LiveScore` (`@MainActor`, Observation) создаёт `RootView` один раз на процесс.
Он отправляет в `SessionStore` розыгрыш, Undo и подтверждение подачи нового сета — по одному
запросу: пока запрос записывается или ждёт решения после неудачи, новые не отправляются, а второе
касание команды в пределах 0,5 с после записанного розыгрыша считается тем же касанием (два
розыгрыша так быстро не заканчиваются). Haptic и VoiceOver-объявление следуют только за успешной
записью: протокол `HapticPlayer` и его WatchKit-адаптер `WatchHaptics` лежат в Services, адаптер
передаёт composition root, тесты — запись. Неудачная запись (E3) закрывает игру состоянием
`Couldn’t save.` с `Retry` (тот же `CommandID`, записывается один раз) и `Cancel`; оно не исчезает,
пока повтор не записан. Что показывает экран (`ScoreBoard`) и что произносит VoiceOver
(`ScoreAnnouncement`), выводится только из сохранённого snapshot и outcome, поэтому экран после
перезапуска тот же. Раунд американо, завершённый последним розыгрышем на экране, остаётся на нём
(без касаний счёта, с Undo) до `New game` в меню, пока жив процесс; после перезапуска открывается
New game, а экран результата S10 добавляет M07. Lifecycle: вне `active` и при Always On
(`isLuminanceReduced`) экран счёта не принимает касаний; при уходе из `active` меню и About
закрываются, выбор подачи нового сета остаётся. Система задаёт `isLuminanceReduced` заново внутри
`NavigationStack`, поэтому Debug-переключатель Always On для UI-тестов применяется внутри стека.

Исправление (M06): `CorrectionDraft` — значение Features: сохранённая игра и её правка по полям
(`MatchDraft` / `AmericanoDraft`). Ничего не конвертируется и не выводится из счёта: фаза (гейм или
тай-брейк) следует из геймов, очки гейма и тай-брейка хранятся раздельно, стадия 40:40 — отдельным полем
и спрашивается только при One advantage. `ServingContext` (геймы и очки тай-брейка матча; очки и B
американо) решает, когда подачу нужно проверить: он отличается и от сохранённого, и от последней
проверки. Проверка — визит на экран подачи или явный выбор; в начатом сете с неподтверждённым порядком
она подтверждает его. После первого очка тай-брейка нужны ход подающего и пара, начавшая подачу; из пары
берётся игрок, которого порядок даёт первому очку, считая назад от следующего подающего. `CorrectionProblem`
называет поля; последнее слово остаётся за `MatchState.issues` / `AmericanoState.issues`. Смена формата —
replacement: значения исходного формата хранятся до возврата к нему. `GameEditor` (`@MainActor`,
Observation) держит черновик, ревизию, с которой он сделан, и последние настройки; им владеет `LiveScore`.
Пока редактор открыт, `LiveScore` не записывает розыгрыш, Undo и подтверждение подачи. Save отправляет
`.correct(format)` против ревизии черновика тем же последовательным путём: неудачная запись — E3 с тем же
`CommandID`, и черновик не меняется до Retry или Cancel; отказ хранилища ничего не меняет и называется в
редакторе; Save без изменений закрывает редактор без записи. Экраны редактора лежат в стеке игры и
остаются при уходе из `active`; termination теряет черновик, сохранённая игра остаётся.

Завершение и результат (M07): `LiveScoreView` — один стек текущей игры от первого розыгрыша до результата.
Для завершённой игры корень стека — результат (`ResultView`, S10) вместо счёта, поэтому сохранённый Finish
возвращает стек к результату, а Resume — к счёту. `LiveScore.finish()` и `resume()` идут тем же
последовательным путём, что розыгрыш: неудачная запись — E3 с тем же `CommandID`. Раунд на N `resume()` не
отправляет: экран открывает Game settings черновика с пометкой `makesRoomToResume`; правка завершённой игры
оставляет её завершённой, и продолжение — отдельное Resume. Игра, завершённая на экране не через Finish
(последний розыгрыш, правка до N, Undo после Resume), остаётся на счёте с Undo (`finishedRound`), а кнопка ✓ на
месте меню переводит к результату. `ResultSummary` (Features, без SwiftUI) выводит итог только из snapshot: у
матча — выигранные сеты, завершённые сеты и отдельно начатый незавершённый сет с очками, без победителя; у
раунда — результат при N либо `Ended early` с лидером и сыгранными из N. `LaunchScreen` открывает `.result`,
пока последний результат можно изменить. New game с результата ставит экраны `NewGameFlow` в тот же стек
проекцией пути (строки настройки открывают редакторы через `flow.path`, а не `NavigationLink(value:)`),
поэтому Back из настройки возвращает редактируемый результат. Старт новой игры делает результат
`previousResult`: меню показывает его только для просмотра (`EarlierResultView`), пока новая игра не
завершится. `LocalDataSettings` (About → Settings) удаляет игру, историю, результаты и настройки одной
командой `.deleteLocalData` (`saveErasingCopies`); неудачная запись держит запрос для Retry или Cancel, уход
с экрана от него отказывается. Учёт использования не менялся: `gameFinished` возникает только при переходе
active → finished, ledger — множество game ID, поэтому Finish → Resume → Finish, правка результата, Undo и
повтор записи не учитывают игру дважды, а удаление данных ledger не трогает (H4d).

## Persistence

| Question | Answer |
| --- | --- |
| Mechanism | Версионированный `Codable` store envelope в app Application Support; serial repository actor; временный файл и атомарная замена в том же каталоге |
| What is stored | Active + latest completed snapshot и их undo, last-used settings, schema version/revision, idempotent usage ledger; только необходимые доменные поля |
| What is deliberately not stored | Каталог всех результатов, телеметрия, здоровье, координаты, аудио, пароль Apple Account, сырые платёжные реквизиты; редакторский draft после termination |
| Where large binary data lives | Таких данных нет; ресурсы интерфейса и on-watch legal copy находятся в bundle |
| Schema versioning approach | Явное целочисленное `schemaVersion`; декодирование каждой поддерживаемой версии и преобразование в актуальную модель |
| Migration strategy | Копия исходного файла, миграция во временную модель, domain validation, атомарная публикация; подробности ниже |
| Encryption at rest | Системная защита sandbox/device; дополнительное самодельное шифрование не предлагается. M03 выбрал `completeUntilFirstUserAuthentication` для папки и каждого файла: игра читается и пишется, когда часы блокируются во время игры (например, сняты с руки), а счёт не настолько чувствителен, чтобы терять запись ради `.complete`. Симулятор watchOS класс защиты не хранит; поведение при блокировке на настоящих часах проверяет REL-207 финального аудита |
| What deleting user data removes | Матчи, undo и последние игровые настройки; entitlement покупки остаётся у Apple. Usage ledger сохраняется при удалении игровых данных; после переустановки/смены часов сохранность не гарантируется |

Одна логическая мутация включает счёт, подачу, history, usage change и revision
в одном envelope. UI подтверждает очко и haptic после успешной записи. Пока запись
выполняется, команда сериализована; одинаковая command ID не применяется дважды.
При ошибке записи сохраняется прежнее подтверждённое состояние и показывается
возможность повторить действие. Нельзя показать устойчиво новый счёт, а на диске
оставить старый без явной ошибки.

Последняя корректная резервная копия служит recovery, не cloud backup. Повреждённый
файл сохраняется отдельно; fallback к более старой копии сопровождается сообщением
о восстановлении, а не выдаётся за точный последний счёт. Если обе копии непригодны,
не создавать пустую игру поверх данных: показать ошибку и явное действие сброса.
Известные актуальные отметки usage сохраняются при восстановлении игрового snapshot.
Если повреждение уничтожило и последние данные ledger, точный счётчик не обещается:
его состояние обозначается неопределённым, без молчаливого нового trial. Дальнейший
reset соответствует выбранной H4d, восстановленную начатую игру не блокирует
повторная загрузка цены или entitlement.

С M03 `SessionRepository` (actor) хранит один JSON-файл `SessionFile`
(`schemaVersion` 1, сессия, уведомление) в Application Support/Session. Новый файл
пишется рядом и синхронизируется на диск, прежний `session.json` становится
`session-backup.json`, затем новый переименовывается в `session.json`: это переименование
и есть момент сохранения, неудача на любом шаге оставляет последнее сохранённое
состояние читаемым. Повреждённый main откладывается в `session-damaged.json`, backup
восстанавливается с сохранённым уведомлением `restoredFromBackup` до явного dismiss;
ledger повреждённого файла сохраняется, если читается, иначе ledger backup помечается
неточным. Если ни одна копия не читается, файл новее схемы или чтение недоступно, запись
запрещена, пока повторное чтение не удастся или человек явно не начнёт заново
(`startOver`): тогда нечитаемый файл откладывается, а известный usage переносится,
утраченное помечается неточным. Удаление локальных данных сначала удаляет backup и
отложенную копию. `SessionStore` (`@MainActor`, Observation) публикует сессию только после
успешной записи, не принимает второй запрос во время записи и хранит неудавшийся запрос
для повтора с тем же ID; до повтора или отказа другие запросы не принимаются.
С M04 composition root (`PadelScoreWatch/App`) создаёт этот store один раз, над
Application Support/Session и с `LifetimeAccess` по H4, а первый экран выводится из его
состояния (`LaunchScreen`): пока сессия читается — пустой холст, через секунду
`Loading game…`; при нечитаемых данных — S14 с `Try again`, а для повреждённого файла ещё
и `Start over` после подтверждения. Недоступный файл и файл более новой версии не
откладываются: первый может прочитаться при следующей попытке, второй — после обновления
приложения. Играемая игра открывается сразу, иначе New game; `restoredFromBackup`
показывается alert, пока человек его не подтвердит.

Размер файла и скорость записи проверяются длинной игрой и большим числом undo.
Если устройство исчерпало место, операция завершается ошибкой с сохранением
последнего подтверждённого состояния; ограничения памяти не превращаются в
скрытый лимит числа сетов. Разрешённые оптимизации не меняют semantics undo.

## Concurrency

| Question | Answer |
| --- | --- |
| Model | Single-writer SessionStore + serial repository actor; независимый EntitlementStore обрабатывает StoreKit async sequences |
| Default actor isolation | Явный `@MainActor` только для presentation и application stores; чистый Domain не зависит от main actor; project default не должен молча изолировать всю модель |
| Which types are `Sendable` | Domain value snapshots, commands, validation errors и immutable DTO; concrete mutable owners не передаются между actors |
| What must run on the main actor | SwiftUI observed state, navigation, публикация подтверждённого snapshot и системная haptic команда |
| How long-running work is cancelled | Screen-owned загрузка продукта отменяется при ненужности; единственный transaction listener живёт с EntitlementStore; принятая запись завершается независимо от исчезновения view |
| Known reentrancy hazards | Второй tap во время await; stale editor revision; purchase success одновременно с transaction update; finish и повторный launch. Защита: command IDs, revision check, сериализованная очередь и idempotent обработка transaction IDs |

### Жизненный цикл

`scenePhase` инициирует контроль сохранения и обновление presentation при возврате.
Последнее сохранённое игровое состояние загружается до показа активных кнопок счёта.
Не полагаться на `onDisappear` как единственное сохранение: система может завершить
процесс. На inactive/Always On сокращать анимацию, сохранять читаемую статичную
информацию и не запускать периодическую работу без нужды. Поведение возврата и
случайного касания проверяется на настоящих часах.

Постоянно светящийся/активный экран на весь матч не обещан. Не запускать фиктивную
HealthKit workout или extended runtime session ради обхода системного жизненного
цикла. [Apple: состояния приложения](https://developer.apple.com/documentation/watchkit/handling-common-state-transitions),
[Apple: Always On](https://developer.apple.com/documentation/watchos-apps/designing-your-app-for-the-always-on-state/).

## Networking

| Question | Answer |
| --- | --- |
| Does the app make network requests? | Собственного HTTP API нет. StoreKit использует сеть Apple; открытие публичной страницы по действию человека создаёт отдельный сетевой поток |
| Client | StoreKit/system URL handling; `URLSession` для игрового сценария не нужен |
| Base URLs per configuration | Только публичный `SUPPORT_SITE_URL` после H1; backend URL отсутствует |
| Authentication | Собственного аккаунта нет; Apple управляет авторизацией покупки, приложение не получает пароль |
| Retry policy | Для загрузки продукта/restore — явный retry без бесконечного цикла; запись очка сети не ждёт |
| Timeouts | Системное поведение StoreKit плюс видимое cancellable/loading state; не держать экран счёта заблокированным из-за сети |
| Offline behavior | Все игровые операции локальны; начатая игра доступна независимо от новой загрузки цены; правила допуска новой игры и ранее проверенной покупки описывает PRODUCT/H4 |
| Certificate pinning | Не нужен: собственного endpoint нет; не вмешиваться в транспорт StoreKit |
| How responses are validated | Только `.verified` StoreKit transactions, правильный product ID/type, актуальный entitlement; неподтверждённый результат не открывает paid access |

## External integrations

| Integration | Present? | Purpose | Fallback when unavailable | Approval/rationale |
| --- | --- | --- | --- | --- |
| Backend service | Нет | Сценарий локальный | Не требуется | Подтверждено общим архитектурным направлением 2026-10-20 |
| Authentication provider | Нет | Собственный аккаунт не нужен | Не требуется | Apple Account обслуживает только Apple |
| StoreKit | StoreKit 2, H4 утверждён | Lifetime non-consumable entitlement | Retry/restore; не прерывать активную игру | Единый EntitlementStore и StoreKitPurchaseClient |
| Review request (StoreKit) | INAPPLICABLE | Watch-only не имеет обязательного rating flow в этом workflow | Нет запроса оценки и ручного rate-entry | REL-208/REL-209: платформенное исключение watchOS, не пропуск проверки |
| HealthKit | Нет | Учёт тренировки не входит в MVP | Счёт работает без разрешений | Не использовать для удержания экрана |
| Push notifications | Нет | Основному loop не нужны | Не требуется | Не включать entitlement |
| Analytics | Предложено: нет | Проверка гипотез ранними наблюдениями и доступными агрегатами магазина | Полевой тест без встроенной отправки событий | Любая телеметрия требует новой privacy-оценки и решения владельца |
| Crash reporting | Стороннего SDK нет | Системные диагностические средства во время разработки | Ошибки хранения видны локально | Не обещать отсутствие системной диагностики Apple |
| AI / LLM | Нет | Правила детерминированы | Не требуется | Нет сетевого AI сценария |
| CloudKit / iCloud | Предложено: нет | Синхронизация/облачная история не включены | Локальное восстановление своей игры | Между устройствами перенос не обещан |
| Published site (Cloudflare Pages) | Да, отдельный `Web/` | Публичные privacy/terms/support + landing | Читаемая bundle-копия legal/support на часах | H1 задаёт `SUPPORT_SITE_URL`, `SUPPORT_EMAIL`, `DEVELOPER_NAME`; публикация — действие владельца |

### StoreKit и единый владелец доступа

Этот подраздел применяется к варианту lifetime-разблокировки H4a. При бесплатной
v1 или платном скачивании игровой access owner остаётся, но IAP, trial, restore
и debug premium override не добавляются. Покупка платного скачивания происходит
в App Store; повторной покупки внутри приложения нет.

`EntitlementStore` слушает `Transaction.updates` с запуска, читает
`Transaction.currentEntitlements`, проверяет product ID и verification result,
обрабатывает success/pending/cancel/error и revoked entitlement. Одна транзакция,
полученная через purchase result и updates, не выдаёт доступ дважды. `finish()`
вызывается после успешной обработки проверенной покупки. Restore — явное действие
пользователя, которое вызывает `AppStore.sync()`, затем обновляет entitlement.
[Current entitlements](https://developer.apple.com/documentation/storekit/transaction/currententitlements),
[Transaction updates](https://developer.apple.com/documentation/storekit/transaction/updates),
[Restore через sync](https://developer.apple.com/documentation/storekit/appstore/sync()).

Цена выводится только из загруженного `Product.displayPrice`. В исходниках,
каталогах строк и milestones нет суммы или символа валюты. У единственного lifetime
продукта нет выдуманной сравнительной цены, процента скидки, срока подписки или
renewal. При незагруженном продукте кнопка покупки не показывает выдуманную цену.
Любое будущее допустимое сравнение — **computed, never authored**: вычисляется
из настоящих продуктов StoreKit, а не вводится как рекламная опорная цена.

H4 утверждён: пять завершённых игр, ledger сохраняется при удалении данных;
offline/reinstall правила описаны в PRODUCT. Технический инвариант: стабильный game ID и idempotent ledger
не списывают дополнительную игру при reopen, finish/resume, undo или повторе
записи. Коммерческий учёт не выводится из текущего списка сохранённых результатов.

`DebugPremiumOverride` входит в тот же milestone, что и EntitlementStore. Он полностью
обёрнут в `#if DEBUG`, хранит `forcePremium` в инъецированном `UserDefaults` suite,
влияет только на итог single entitlement owner и не создаёт, не меняет и не завершает
StoreKit transaction. Ни одна view не проверяет этот флаг. Выключение возвращает
ровно настоящий store result. Unit-тесты доказывают on/off, отсутствие вызовов
transaction API и изолированное defaults-хранилище. Отсутствие override в поставке
проверяют source gate, чистая Release-сборка и REL-1101; условно исключённый из Debug
тест не является доказательством.
Обязательная граница override: **compiled out of Release**.

### Legal и support на часах

`Web/` содержит четыре статические страницы без форм, серверного кода и аналитики.
`/terms` ссылается на Apple Standard EULA, собственная лицензия не пишется.
Приложение хранит читаемые английские privacy/terms/support сведения в bundle,
показывает публичные URL и контакт на часах; доступ к сути не требует iPhone или
доступности сайта. Синхронность on-watch copy и Web проверяет Legal and Support.
Deployment сайта не выполняется verification gate.

## Security and privacy

| Question | Answer |
| --- | --- |
| What personal data is processed | Локальный счёт, режим, правила и роли игроков; имя не обязательно. Usage ledger для принятой коммерческой модели; сведения права покупки от StoreKit |
| What leaves the device, and to where | Игровая история собственному серверу не отправляется. StoreKit взаимодействует с Apple; открытые URL — с host сайта; добровольное письмо поддержки — с владельцем mailbox |
| Where secrets live | ASC key ID/issuer/key path — окружение разработчика; закрытый `.p8`, signing и Cloudflare token вне Git. Содержимое ключей не печатается и не копируется |
| Keychain usage | Для MVP не предлагается: собственных login tokens нет; платное право не хранится как самодельный Keychain-флаг |
| Required-reason API usage | Проверять реально используемые API. Для app-only UserDefaults — применимый reason `CA92.1`; остальные категории не объявлять без использования |
| Privacy manifest needed? | Да: `PrivacyInfo.xcprivacy` отражает фактические required-reason APIs и data practices; релизный аудит проверяет consistency с App Store privacy и сайтом |
| Data retention | Игровой store — пока нужна активная/последняя игра или пока пользователь не удалит её; полный архив и сроки внешнего support mailbox не подставляются молча |
| How a user deletes their data | Явное on-watch удаление игровых данных с подтверждением и понятным перечнем; не отзывает покупку Apple. Полный reset/trial semantics — H4 |

`Config/project.env` содержит публичную конфигурацию, никогда не credential.
`UserDefaults` reason относится к фактическому доступу, а не разрешает fingerprinting.
[Apple: required-reason APIs](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype).

Получатель support-писем, действующий адрес и срок хранения определяются владельцем
в H1 PRODUCT. Предложение: использовать письмо только для ответа и хранить не дольше
объявленного срока; не прикладывать игровые данные автоматически. Эти сведения
одинаковы в on-watch Privacy, Web и документах. Публиковать фиктивный контакт нельзя.

## Modularization

| Question | Answer |
| --- | --- |
| Single target, or several? | Современный Xcode Watch-only: один executable Watch target, его packaging container, unit/UI test targets; без отдельного WatchKit extension или iPhone executable |
| Local Swift packages? | Нет на старте; логические слои каталогами и API, без преждевременного дробления маленького продукта |
| Where new files go | `App/<Project>/Domain`, `Services`, `Features`, `Resources`, `App`; тесты рядом в test targets, test fixtures в их ресурсах |
| Are folders synchronized groups? | В M00 выбраны явные PBXGroups и membership source/resource/test файлов; проект редактируется напрямую в Xcode, отдельный генератор для сборки не требуется |

Packaging container нужен Xcode для упаковки Watch-only продукта; это не companion
приложение и не устанавливаемый iPhone UI. Shared scheme собирает container и Watch
executable, выполняет Watch unit/UI tests. `APP_TARGET` и `BUNDLE_IDENTIFIER`
указывают на Watch executable; версия/build container синхронизированы с Watch app.
[Apple: Watch-only targets](https://developer.apple.com/documentation/watchos-apps/creating-independent-watchos-apps).

## Testing strategy

В M00 Watch unit/UI targets подключены к общему scheme; их фактический запуск
проверен на собственном Watch simulator.
[Apple: setting up tests for a watchOS app](https://developer.apple.com/documentation/watchos-apps/setting-up-tests-for-your-watchos-app).

| Level | Framework | What it covers | What it does not | Where it lives |
| --- | --- | --- | --- | --- |
| Unit | Swift Testing | Переходы обычного счёта/трёх deuce modes, утверждённого tie-break, американо, service anchor, validation, exact undo, usage idempotency, entitlement mapping | Читаемость и надёжность реального касания | Watch unit test target, Domain/Service tests |
| Integration | Swift Testing/XCTest + временные файлы + StoreKit Testing | Атомарный store, launch recovery, миграции, повреждение/запрет записи, duplicate StoreKit updates, purchase/cancel/pending/restore | Настоящую покупку и системные UI/сеть App Store | Watch test target, fixtures и `.storekit` конфигурация |
| UI | XCUITest | English создание двух режимов, score taps, исправление, undo через границу, завершение/resume, paywall и legal navigation, accessibility labels | Поведение на мокром запястье, солнце, тактильные ощущения, все VoiceOver и lifecycle особенности | Watch UI test target shared scheme |
| Device/audit | Ручная проверка на настоящих Apple Watch + evidence | Digital Crown, VoiceOver, размер текста, солнце, inactive/Always On, возвращение и работа без телефона, sandbox purchase | Не заменяет domain и persistence tests | Handoff owning milestone и финальный audit |

| Question | Answer |
| --- | --- |
| What must always have a test | Каждая ветвь счёта и смены подачи; все deuce phases; валидные/конфликтные ручные правки; undo через game/set/mode/finish; persisted consistency; failed-write rollback; trial и transaction idempotency |
| What is deliberately not unit-tested, and why | Системный purchase dialog, реальные haptics/VoiceOver и визуальная читаемость; это UI/device evidence, а не mock-утверждение |
| How dependencies are substituted | Протоколы repository/store/haptics/clock/ID factory; отдельный defaults suite и temp directory для каждого теста |
| How persistence is tested | Записать → создать новый repository → прочитать; fault injection до/после атомарного commit, truncated file, backup recovery, migrated fixtures; проверять весь snapshot и revision |
| Fixtures and their location | Committed fixtures внутри test target; граничные счёты и схемы хранения без персональных данных; StoreKit config содержит тестовый продукт после H4 |
| Are UI tests in the shared scheme? | Да; строгие milestone/integration/release gates запускают обязательный полный scheme, пропуск не считается успехом |

Нужно доказать конкретные случаи: оба победителя golden point; потеря единственного
advantage и возврат к deciding point; длинный deuce; начало следующего сета без
закрытия матча; нечётный total американо; укороченная последняя серия по PRODUCT;
ручная коррекция в той же видимой фазе с другим подающим; перезапуск сразу после
сохранённого очка; resume результата не расходует новую бесплатную игру.

Минимум watchOS 10 утверждён, но совместимость не считается проверенной до
выполнения проверок на соответствующей среде. В M00 добавлены два hosted
Swift Testing теста bundle identity и один UI-тест Home → About → Back.
`make fast` 2026-10-20 прошёл на watchOS 26.5: 3/3, без failures/skips.
Clean-HEAD и explicit-candidate milestone gates прошли для одного SHA;
команды, отчёты и counts записаны в [handoff M00](handoffs/M00-handoff.md).
Эти результаты не доказывают работу на watchOS 10.

## Migration strategy

| Question | Answer |
| --- | --- |
| How schema changes ship | Новая schema version и явная односторонняя transform chain; старые shipped fixtures остаются в тестах |
| How a migration is tested before release | Реальные формы предыдущих схем, boundary states, undo, service context и usage ledger; повторный запуск миграции идемпотентен |
| Upgrade path from the last shipped build | До первого релиза shipped schema отсутствует; после релиза поддерживается переход от каждой реально опубликованной версии без потери счёта |
| What happens if a migration fails on a user's device | Исходный файл/backup сохраняются, игра не перезаписывается пустой; показывается recovery/error с явным reset, блокируется небезопасная запись |
| Is a rollback possible? | Код может прочитать только известные версии; downgrade не записывает поверх более новой схемы. Предыдущая резервная копия даёт recovery при явном выборе, не обещание автоматического отката приложения |

При новой shipped версии upgrade smoke с реальными prior fixtures обязателен в
функциональном аудите. Нельзя «лечить» миграцию сбросом trial или удалением undo.

## Rejected alternatives

Это отклонённые варианты в одобренном направлении. Условия пересмотра не означают
одобрения новых возможностей или выбора открытых H-решений.

| # | Alternative | Rejected because | Reconsider when |
| --- | --- | --- | --- |
| R1 | Companion iPhone + Watch Connectivity как основной store | Противоречит прямому Watch-only требованию | Только при новом продуктовом решении пользователя |
| R2 | WebView с кодом интерактивного макета | JS модели и ограничения — демонстрация UX; нет нативного жизненного цикла и доказанных правил | Не предполагается для MVP |
| R3 | SwiftData/Core Data для текущей игры | Нет запросов по архиву; explicit small snapshot проще контролировать в миграциях и атомарном undo | Если одобрен большой searchable history или sync |
| R4 | UserDefaults как база матча | Счёт, подача, undo и usage должны сохраняться согласованно одной транзакцией | Не пересматривать для игрового состояния |
| R5 | Event sourcing с повторным проигрыванием после изменения правил | Ручной счёт не раскрывает прошлые розыгрыши; replay может изменить уже сыгранный результат | Только для отдельной доказанной функции анализа, не коррекции |
| R6 | Backend, account, RevenueCat/аналитический SDK | Добавляет сеть, персональные данные и поддержку без необходимого MVP-сценария | При подтверждённой потребности, отдельном решении и privacy review |
| R7 | HealthKit workout для удержания экрана | Учёт здоровья не запрошен; системный lifecycle нельзя обходить фиктивной тренировкой | Если владелец добавит полноценный workout-сценарий |
| R8 | Ограничить число сетов или урезать undo молча для памяти | Меняет подтверждённый продукт/доверие к исправлению | Только явное новое продуктовое решение; сначала оптимизировать хранение |
| R9 | Подписка, сравнительная цена, promotional offers | Предложен простой lifetime; дополнительных продуктов и доказанного сравнения нет | Если H4 выберет иную коммерческую модель |

## Unresolved decisions

Ни один milestone не подставляет конкретный исход вместо решения. После утверждения
владелец и Builder обновляют owning contract и конкретную проверяемую конфигурацию.
H2 закрыт 2026-10-20; утверждённое правило сета и подачи записано в PRODUCT.

| # | Question | Options | Blocks | Who decides |
| --- | --- | --- | --- | --- |
| H1 → PRODUCT | Публичные контакты/URLs и support retention; локальная identity уже задана | Варианты и требуемые данные в [PRODUCT.md](PRODUCT.md#unresolved-decisions); имя в App Store Connect ещё не зарезервировано | Legal and Support и финальные материалы | Владелец |
| H4 → PRODUCT | Lifetime/trial contract, доступ, deletion/reinstall semantics | Варианты в PRODUCT; StoreKit и local usage не выбирают коммерческую модель сами | Entitlement/paywall и audit покупок | Владелец |

Технические вопросы, которые Builder вправе закрыть в рамках утверждённого решения:
точные native protection options, политика резервной копии файлов, file-size
оптимизация без изменения поведения, конкретные test fixtures и доступные simulator
identifiers. Они фиксируются в owning milestone с доказательствами; это не повод
менять продукт или объявлять заранее выполненные проверки.
