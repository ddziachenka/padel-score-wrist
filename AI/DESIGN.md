# Product design contract

Документ задаёт пути, экраны, состояния, визуальный язык, доступность и локализацию.
Поведение счёта и бизнес-решения принадлежат [PRODUCT.md](PRODUCT.md), хранение,
платформа и приватность — [ARCHITECTURE.md](ARCHITECTURE.md).

**Status:** approved direction — H1/H4 закрыты 2026-10-21; план покупки M11–M15 утверждён 2026-10-22
**Approved by:** владелец проекта, сообщение «одобряю»
**Approved on:** 2026-10-20
**Updated:** 2026-10-22

Подтверждены Watch-only, два формата своей игры, исправление всех введённых данных,
ручное завершение обычного матча, английский язык v1 и премиальный минимализм.
Описанные ниже компоновка, обратная связь и восстановление одобрены как направление
2026-10-20. Числа и русские подписи HTML-макетов не задают правила или язык v1.

## Information architecture

```text
Launch (app icon, or the watch-face / Smart Stack button from M14)
├─ Active game → Live score
│  ├─ Undo
│  └─ Game menu
│     ├─ Edit score → points / games / completed sets / deuce stage
│     ├─ Game settings → mode / rules / Serving
│     ├─ Finish match / Finish round → Result
│     ├─ Last result → read-only previous result
│     ├─ History (M13) → finished games → read-only result
│     └─ About → Access / Privacy / Terms / Support
├─ No active game, latest result exists → Result
│  ├─ Play again (M11) → Setup of the same format from this result → Start game
│  ├─ New game → formats
│  ├─ Edit result → editor draft
│  ├─ Resume game → Live score or correction draft
│  ├─ History (M13)
│  └─ About
└─ No game → New game
   ├─ Match → Setup → rule / Serving → Start game
   ├─ Americano → Setup → total rallies / service block / Serving → Start game
   ├─ Try the scoreboard (M12) → in-memory Demo
   ├─ History (M13)
   └─ About → Try the scoreboard (M12) / Watch face help (M14)

Shared field editors: choice picker / number picker / serving order / set editor.
About → Settings → Delete local data (confirmed destructive action; with M13 also history).
Access: Keep your focus on the game / Unlock forever / Restore purchases (H4, M11).
Legal: readable on-watch pages with public URLs and support contact.
```

| Question | Answer |
| --- | --- |
| Where does the app open? | Сохранённая активная игра имеет приоритет, затем последний результат, затем `New game`. После восстановления не открывать paywall поверх матча. |
| What appears before any data exists? | Два выбора `Match` и `Americano`, короткое пояснение каждого, доступ к `About`; с M12 под ними необязательная строка `Try the scoreboard`, с M13 — `History` с пустым состоянием. Демонстрация не открывается сама; без регистрации и обязательного onboarding. |
| Maximum navigation depth | До пяти уровней для редкой правки предыдущего сета: игра → меню → редактор → сеты → конкретный сет. Числа сета редактируются там же через нативный picker; дополнительную цепочку экранов не добавлять. Основной ввод очка не меняет экран. |
| Which navigation state survives relaunch? | Только сохранённая игра/результат. Черновик живёт в памяти процесса и сохраняется при переходах внутри редактора и background, пока процесс жив; после холодного запуска открывается последний сохранённый счёт. Меню, черновик, покупка и подтверждение завершения автоматически не восстанавливаются. |

Один navigation stack, без постоянных вкладок. Digital Crown прокручивает длинные
экраны и меняет значение только у явно активного редактора. Вращение Crown на
игровом экране никогда не начисляет очки. Для всех редактируемых значений есть
доступное касанием управление.

## Primary journeys

### J1 — Начать игру и вести счёт

| Field | Value |
| --- | --- |
| Goal | Видеть собственный счёт и подающего, отмечать каждый розыгрыш одним касанием. |
| Entry point and starting condition | `New game`; активной игры нет, условия доступа проверены по PRODUCT. |
| Steps | Выбрать `Match` или `Americano` → проверить параметры → указать первого подающего и очередь → `Start game` → нажимать область `US` или `THEM` после розыгрыша. |
| Success looks like | Очки, вторичный счёт и следующий подающий согласованно обновились, экран остался на месте. |
| Recovery path | `Undo` возвращает предыдущее действие целиком; `Edit score` исправляет произвольную ошибку. |
| Abandonment: what is kept | До старта черновик настройки живёт в памяти процесса; после старта каждое принятое действие и активная игра сохраняются на устройстве. |
| Must never break | `US` означает нашу пару, `THEM` — соперников. Не начислять очко от касания меню, Crown или активации дисплея. Число сетов у матча не запрашивается. |
| Acceptance evidence | M04/M05: оба режима от первого запуска до очков, маленький и большой поддерживаемые экраны; M05/M10: проверка на настоящих часах между розыгрышами. |

### J2 — Исправить ошибку без потери контекста

| Field | Value |
| --- | --- |
| Goal | Вернуть правильные очки, правила и подачу, включая прошлые сеты. |
| Entry point and starting condition | `Undo` на Live score либо меню → `Edit score` / `Game settings`; возможна правка последнего результата. |
| Steps | Быстрая ошибка: `Undo`. Сложная: открыть черновик → исправить поля → проверить подающего → `Save changes`. Вложенное `Done` меняет только черновик. |
| Success looks like | Один атомарный сохранённый переход; все связанные числа и подача соответствуют показанному черновику. |
| Recovery path | При конфликте перейти к названному полю; при ошибке записи `Retry`; исходная игра остаётся доступной. |
| Abandonment: what is kept | Возврат внутри редактора сохраняет черновик в памяти. Выход из всего редактора предлагает `Keep editing` / `Discard changes`. Background сохраняет черновик, пока жив процесс; termination теряет несохранённый черновик, но оставляет исходную игру. Подсказка редактора: `Changes are saved when you tap Save.` |
| Must never break | Правка очков не угадывает подающего. Смена правила не пересчитывает прошлое. Смена формата требует явного целевого счёта; ничего не стирается молча. |
| Acceptance evidence | M06: текущие очки/геймы, предыдущие сеты добавить/исправить/удалить, стадия 40:40, формат, правила, очередь и позиция в серии; отмена через переход гейма/сета; конфликт и отказ записи. |

### J3 — Завершить, проверить и продолжить

| Field | Value |
| --- | --- |
| Goal | Закончить свою игру при фактическом счёте и исправить случайное завершение. |
| Entry point and starting condition | Меню → `Finish match / Finish round`; американо также достигает принятого общего числа розыгрышей. |
| Steps | Увидеть сводку → `Finish` → результат; затем `Play again` (M11), `New game`, `Edit result` или `Resume game`. |
| Success looks like | `Match finished` или `Round finished`; главный элемент — фактический счёт с устойчивыми колонками команд, незавершённый сет отдельным блоком `Set N · Incomplete`; `Saved` — вторичное подтверждение (M11). |
| Recovery path | До сохранения `Keep playing`; после — `Resume game`. Для исчерпанного американо сначала увеличить лимит или исправить очки. |
| Abandonment: what is kept | Закрытие подтверждения не завершает игру. Закрытие результата сохраняет результат. |
| Must never break | Обычный матч не завершается после фиксированного числа сетов и не получает вымышленного общего победителя. Сохранение результата не объявляется до успешной записи. После старта следующей игры предыдущий результат доступен только для просмотра до следующего завершения; Edit/Resume больше не доступны. |
| Acceptance evidence | M07: завершение посреди гейма/сета, на границе сета, раннее/полное американо по PRODUCT, повторный запуск и продолжение без дублирования. |

### J4 — Разблокировать доступ и найти помощь

| Field | Value |
| --- | --- |
| Goal | Понять условия, приобрести согласованный доступ или прочитать правила и поддержку на часах. |
| Entry point and starting condition | `About` в состоянии до игры/результата/меню; предложение покупки только в согласованной точке между играми. |
| Steps | Прочитать `Keep your focus on the game`, что разблокируется, свой лимит, `Unlock forever` с ценой StoreKit и `One payment. No subscription.` → системная покупка или `Restore purchases`; `Privacy`, `Terms`, `Support` открываются без оплаты. |
| Success looks like | Проверенное право доступа видно; разрешённая новая игра доступна. Юридический текст и контакт читаются на Watch. |
| Recovery path | Закрыть предложение, повторить покупку/restore после ошибки, прочитать локальные legal-страницы без сети. |
| Abandonment: what is kept | Результат и активная игра не теряются; черновик остаётся в живом процессе. Отмена покупки не считается покупкой. |
| Must never break | Ни доступ к поддержке, ни текущая игра не зависят от наличия приложения для iPhone. |
| Acceptance evidence | M08/M09: согласованные условия H4, все StoreKit-состояния, legal offline, корректные публичные страницы и контакт. |

### Purchase-appeal journeys (approved 2026-10-22)

| Journey | Entry | Steps | Success looks like | Must never break | Milestone |
| --- | --- | --- | --- | --- | --- |
| J5 — Play again | Текущий завершённый результат | `Play again` → Setup того же формата с правилами и порядком результата → проверить подачу → `Start game` | Новая игра 0–0 тех же правил; результат остался для просмотра | Back ничего не создаёт; лимит проверяется при Start; закрытие Access оставляет черновик и результат; покупка не стартует игру | M11 |
| J6 — Попробовать счётчик | `Try the scoreboard` на New game или в About | Нажимать команды, Undo, `Reset demo`, `Close` | Видно смену очков, гейма и подающего и точный Undo | Метка `Demo` всегда; ничего не пишется; лимит, игра, история, настройки и покупка не меняются | M12 |
| J7 — Найти прошлую игру | `History` на New game, результате или в меню | Список новые сверху → подробный результат | Дата, формат и счёт читаются; во время матча игра не меняется | Без покупки доступно всегда; нет автоудаления; `Date unavailable` вместо выдуманной даты | M13 |
| J8 — Открыть с циферблата | Кнопка на циферблате или в Smart Stack | Одно касание | Обычный запуск: игра, результат или New game | Открытый редактор и экран не сбрасываются; кнопка не показывает счёт | M14 |

## Screen inventory and navigation

| ID | Screen/surface | Purpose | Entry | Exit | Empty | Loading | Error | Offline | Persistent state |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S1 | New game | Выбрать свой формат | Первый запуск, результат | S2, S11 | Два режима с пояснениями | Чтение локального состояния | E5, без ложного обнуления | Работает | Черновик создания |
| S2 | Setup | Проверить правила и подачу | S1 | S3 или назад | Обязательные поля помечены `Choose` | Сохранение старта | E1/E3 | Работает при разрешённом доступе | Параметры черновика |
| S3 | Live score | Очко, счёт и подающий | S2, resume, relaunch | S4 или результат американо | 0–0 — обычное состояние | Краткая запись действия, без замены счёта spinner | E3 | Полностью работает | Текущая игра, undo |
| S4 | Game menu | Вход в редактирование и завершение | S3 | S5/S6/S9/S11 или S3 | Не бывает при активной игре | Не нужен | Ошибки дочерних экранов | Работает | Нет |
| S5 | Edit score / Edit result | Все числа, сеты и стадия игры | S4/S10 | S7/S8 или Save/Discard | Нет завершённых сетов → `Add set` | Сохранение всего черновика | E1/E2/E3 | Работает | Отдельный черновик |
| S6 | Game settings | Формат, правило, лимит, серия | S4 или S5 | S7/S8 или Save/Discard | Незаполненное новое поле при смене формата | Сохранение всего черновика | E1/E2/E3 | Работает | Тот же черновик |
| S7 | Field / Set editors | Выбрать значение или изменить прошлый сет | S2/S5/S6/S8 | `Done` к родителю | Только новый обязательный параметр | Не нужен | E1/E2 | Работает | Значение в черновике |
| S8 | Serving | Кто подаёт, порядок, позиция в серии | S2/S5/S6 | `Done` к родителю | Выбор первого подающего | Не нужен | E2 | Работает | Подача в черновике |
| S9 | Finish match / Finish round | Проверить фактический результат | S4 | S10 либо S3 | 0–0 показывается честно | Сохранение | E3 | Работает | До подтверждения игра активна |
| S10 | Result / Last result | Счёт последней игры, повтор и восстановление | S9, полный американо, relaunch, S4 → Last result | S2 через `Play again` (M11), S1/S5/S11 или Resume; во время следующей игры только просмотр и Back | Игры нет → S1 | Чтение/правка/продолжение | E3/E5 | Работает | Последний результат |
| S11 | About / Access | Информация, доступ и legal | S1/S4/S10 | S12/S13 либо назад | Разблокировка ещё не куплена | Проверка entitlement по ARCHITECTURE | E4 | Сохранённый статус + legal | Проверенное право доступа |
| S12 | Unlock | `Keep your focus on the game`: условия одной покупки | Доступ или Start game (в том числе после Play again) после лимита | StoreKit, S2 или назад | Продукт недоступен → цена не выдумывается | Загрузка продукта/покупка/restore | E4 | Покупка/restore недоступны, чтение доступно | StoreKit entitlement |
| S13 | Privacy / Terms / Support | Читаемая информация на Watch | S11/S12 | Назад | Не допускается в релизе | Локальный текст сразу; URL отдельно | E6 | Локальный текст доступен | Версия legal-контента |
| S14 | Recovery | Не скрыть сбой хранения | Launch или E3/E5 | Retry или доступные сохранённые данные | Нет достоверного снимка → объяснение | Повторное чтение | Причина без технического дампа | Работает | Сохраняет существующие данные |
| S15 | Settings / Delete local data | Управление локальными данными | S11 | Подтверждение удаления или Back | Нет данных → описание и недоступное удаление | Атомарная очистка | E3 | Работает | Игра, результат, настройки (с M13 — и история) удаляются только после подтверждения |
| S16 | Demo (M12) | Попробовать счётчик на фиксированном примере | S1, S11 | Close к источнику | Не бывает: пример фиксирован | Не нужен | Не бывает: нет записи | Работает | Только память процесса |
| S17 | History (M13) | Все завершённые игры, новые сверху | S1, S4, S10 | S18 или назад | `Your finished games will appear here.` | Чтение сохранённого архива | E5 | Работает | Архив завершённых игр |
| S18 | History result (M13) | Подробный итог архивной игры | S17 | Назад | Не бывает | Не нужен | E5 | Работает | Только просмотр |
| S19 | Watch face / Smart Stack button (M14) | Открыть приложение одним касанием | Циферблат, Smart Stack | Обычный запуск | Не бывает | Системный | Системный | Работает | Нет: статическая кнопка |

В колонке Persistent state черновик означает состояние в памяти до явного Save,
а не долговременное восстановление после termination. Долговременно сохраняется
только принятый результат записи по ARCHITECTURE.

| Navigation question | Answer |
| --- | --- |
| Pattern: tabs, stack, modal, or mixed | Один нативный stack; alerts для подтверждения потери черновика; системный StoreKit. Основные экраны не перекрываются каскадом sheets. |
| Back behavior from the deepest screen | Вернуться на один уровень с черновиком; явный `Cancel` конкретного поля возвращает его предыдущее значение. Уход из редактора с изменениями — выбор discard/keep. |
| Modal surfaces and dismissal behavior | Подтверждения завершения/отбрасывания; dismiss отменяет действие. Покупкой управляет системный экран; отмена оставляет доступный исходный экран. |
| Surfaces that block dismissal and why | Нет бессрочных ловушек. На время локальной атомарной записи повторные действия блокируются, но сбой возвращает `Retry` и безопасный выход. Pending-покупка не блокирует приложение. |
| Deep links and invalid-link recovery | Публичного контракта deep links в MVP нет; системный запуск открывает сохранённое состояние. Внешняя ошибка URL не закрывает legal-текст. |
| Selection/focus restoration | Возврат из поля фокусирует его строку; после Save — изменённое значение или счёт; после модального отказа — инициировавший контроль. Автообновление подающего не крадёт VoiceOver-фокус. |

## Interface states

| State | Required contract |
| --- | --- |
| Empty | `New game` вместо пустой истории. В редакторе `No completed sets` и `Add set`. С M13 пустая история: `Your finished games will appear here.` |
| First run | Без регистрации, запросов разрешений и вымышленных данных в реальной игре. В выборе режима одна строка смысла: `Games and sets` / `A fixed total of rallies`. С M12 фиксированный пример открывается только по `Try the scoreboard` и всегда помечен `Demo`. |
| Loading | Сохранять контекст и цифры; disable только повторное конфликтующее действие; по длительности показывать понятный статус. |
| Partial | Достоверный снимок остаётся виден; неподтверждённое право покупки помечается `Checking access…`. Повреждённые числа не дорисовывать. |
| Recoverable error | Сохранить поля, назвать конфликт/сбой, дать действие рядом. Не показывать технический код вместо причины. |
| Unrecoverable error | `We couldn’t read this game.` Без автоматического сброса данных; Retry и доступная помощь. Восстановление из последнего валидного снимка явно обозначается. |
| Offline | Счёт, исправления, завершение и legal работают локально. Сеть относится к покупке/restore и открытию публичных страниц. |
| Interrupted | Активная игра восстанавливается; черновик переживает background только пока жив процесс. Закрытие/блокировка не завершают матч. |
| Destructive | Удаление сета в черновике обратимо до Save; весь Save отменим. Потеря черновика требует подтверждения. |
| Success | Видимое изменение счёта достаточно для очка. `Changes saved`, `Saved`, `Access unlocked` появляются только после подтверждённого результата. |

### Empty and loading details

| Screen | Empty reason | Empty copy | Primary action |
| --- | --- | --- | --- |
| S1 | Игра ещё не начата | `New game` | Выбрать `Match` или `Americano` |
| S5 | Нет предыдущих сетов | `No completed sets` | `Add set` |
| S11 | Нет покупки | Точные утверждённые бесплатные условия; без неподтверждённого числа | `View access` |
| S12 | StoreKit не вернул продукт | `Purchase unavailable right now.` | `Try again`; закрытие видно |
| S14 | Нет читаемого снимка | `We couldn’t read this game. Your saved data has not been deleted.` | `Try again` |
| S17 | Завершённых игр нет (M13) | `Your finished games will appear here.` | Назад или `New game` |

| Screen | Trigger | Under 1s | 1–5s | Over 5s | Timeout/cancel |
| --- | --- | --- | --- | --- | --- |
| S1/S3 | Чтение сохранённой игры | Стабильная оболочка без фиктивного счёта | `Loading game…` | То же с `Try again` при ошибке | По завершению операции либо явной ошибке; не сбрасывать данные по таймеру |
| S2/S3/S5/S9 | Запись действия | Pressed state и защита от повторного submit | `Saving…`, исходный контекст виден | `Still saving…`, не выдавать успех | Архитектура сериализует операцию; Retry только после установленной ошибки, без второго параллельного действия |
| S12 | Продукт/restore | Устойчивая кнопка со статусом | `Loading price…` / `Restoring…` | Сообщение о задержке, Close доступен | Локальный сетевой запрос ограничен по ARCHITECTURE; ошибка → Retry; отмена не отменяет уже поступившую транзакцию |
| S12 | Системная покупка | Системное подтверждение | Системный процесс | Pending показан отдельно | Не придумывать собственный таймер транзакции; её итог может прийти позже |

### Errors and offline behavior

| ID | Error/cause | User-facing message | Recovery | Logged safely? |
| --- | --- | --- | --- | --- |
| E1 | Неверное число | `Enter a whole number greater than zero.` либо точная допустимая граница поля | Исправить выделенное поле | Категория, без содержимого игры |
| E2 | Сумма больше лимита | `More rallies have been played than the total. Increase the total or correct the score.` | Ссылка к Total / Score | Категория конфликта |
| E2 | AD при Golden point | `Advantage isn’t used with Golden point. Change the rule or correct the score.` | Rule / Score | Категория конфликта |
| E2 | Номер в серии больше новой серии | `Choose a rally position within the new service block.` | Serving | Категория конфликта |
| E2 | Неопределённая подача после правки | `Check who serves next before saving.` | Serving; показать текущий выбор | Категория конфликта |
| E3 | Не удалось записать действие | `Couldn’t save. Your last saved score is unchanged.` | `Retry`; сохранить черновик/намерение; не принимать дальнейшие очки до решения | Ошибка хранилища без счёта и идентификаторов покупки |
| E4 | Нет сети/сбой StoreKit | `Couldn’t connect to the App Store. Try again when you’re online.` | Retry / Close; игра не теряется | Категория и безопасный системный код |
| E4 | Pending | `Purchase pending. Access will update when it’s approved.` | Close, позже обновить статус | Категория; не receipt |
| E5 | Повреждённое хранилище | `We couldn’t read this game. Your saved data has not been deleted.` | Retry / Support; валидная резервная версия, если существует | Версия схемы и категория; без дампа |
| E6 | URL не открылся | `This page couldn’t open. You can read the information here.` | Локальный текст и видимые URL/контакт | Тип назначения без персональных данных |

| Offline question | Answer |
| --- | --- |
| Does the app work with no network? | Предложенная основная модель полностью локальная; счёт не ждёт интернет. |
| Available offline | Создание при имеющемся разрешении доступа, игра, все исправления, завершение, последний результат, восстановление, legal-текст. |
| Unavailable and how it is shown | Покупка/restore и внешние страницы: честное сообщение без цены-заглушки. Проверенное сохранённое entitlement обрабатывается по ARCHITECTURE/PRODUCT H4. |
| Actions queued or refused | Игровые действия записываются локально. Покупки не ставятся в собственную очередь приложения. |
| How offline status appears | Нет постоянного offline-баннера на счёте. Контекстное сообщение появляется только там, где запрос требует сети. |
| What happens when connectivity returns | Обновить доступ/цену при обращении к соответствующему экрану; не открывать предложение поверх игры. |

### Interruptions and destructive actions

| Interruption | Expected behavior |
| --- | --- |
| Backgrounded | Сохранённый счёт остаётся истиной; закрыть визуальное pressed state. На возврате не повторять очко. |
| System termination | Восстановить последнее успешное действие. Несохранённый черновик утрачен; до Save UI не обещает его запись. Повреждённое состояние не выдавать за новую игру. |
| Incoming call | Никаких новых очков или завершения от системных жестов; после возврата тот же матч. |
| Device locked | Игровое состояние сохраняется; приложение не обходит блокировку. |
| Low Power Mode | Нет обязательных анимаций и постоянной фоновой работы; достоверные цифры и обычное возобновление. |
| Storage full | E3, исходный сохранённый счёт; не подтверждать очко и не продолжать незаметно в несохраняемой сессии. |
| Permission revoked while running | MVP не запрашивает опасных разрешений. Изменение доступа к покупке не уничтожает текущую игру и результаты. |

| Destructive action | Reversible? | Confirmation copy | Undo/recovery |
| --- | --- | --- | --- |
| Discard editor draft | Да: можно остаться в редакторе; после подтверждения исходная игра цела | `Discard changes? Your saved game will stay the same.` | `Keep editing` / `Discard changes` |
| Remove completed set | Да, изменение черновика и отмена его Save | В строке `Remove set`; показывается конкретный номер | До Save отменить/восстановить черновик; после Save — Undo полного действия |
| Change mode | Да, целевой черновик плюс undo после Save | `Change game format? Enter the score for the new format. Nothing changes until you save.` | Cancel сохраняет исходный формат, Save требует полного целевого состояния |
| Finish match / Finish round | Да | `Finish this game? Your current score will be saved.` | `Keep playing`; после сохранения `Resume game` |
| Start another game after result | Последний результат остаётся для просмотра, его правка/продолжение закрываются | `Starting a new game will keep this result for viewing only.` перед фактическим стартом | Вход в Setup ничего не меняет; Back возвращает редактируемый результат |
| Delete local data | Нет после подтверждённой очистки | `Delete local data? This removes your game, last result and saved settings from this Watch. Your free-game count and purchase are kept.` С M13 текст перечисляет и историю завершённых игр | `Cancel` / `Delete data`; счётчик сохраняется по H4 |

## Permissions and privacy UX

В одобренном MVP нет запросов Location, HealthKit, Microphone, Contacts,
Notifications или иных разрешений для счёта. Нет регистрации. Не запрашивать их
ради удержания дисплея включённым. Настройки системной покупки не маскируются под
разрешение приложения. Локальная модель ARCHITECTURE одобрена; новый сбор данных
требует отдельного решения и не добавляется только ради метрик. Детали trial — H4.

## Purchases and paywalls

H4 утверждён 2026-10-21: пять завершённых игр, затем lifetime unlock; ledger
сохраняется при удалении данных. Цена UI только из StoreKit.
Таблица описывает lifetime IAP. При бесплатной v1 или платном скачивании нет
Unlock, trial, Restore purchases или debug premium override; About и legal
остаются доступны, повторная покупка внутри приложения не предлагается.

| Question | Answer |
| --- | --- |
| Where the paywall appears | Между играми при `Start game` после принятого лимита (в том числе после `Play again`) либо добровольно из `About → Access`. Никогда автоматически после результата. |
| What remains visible for free | Условия доступа, уже созданные данные, исправление результата, помощь, legal и restore; активную игру не перекрывать. Точное право начать новую игру задаёт PRODUCT. |
| How the paid value is demonstrated before the paywall asks for money | Согласованный бесплатный опыт полноценных игр; с M12 необязательный пример `Try the scoreboard`; без обязательного paywall на первом запуске. |
| Exactly what is sold | Одна нерасходуемая lifetime-разблокировка после пяти завершённых игр. Бесплатные игры автоматические, без отдельного запуска и слова trial в UI. |
| Price and term presentation from StoreKit | Одна локализованная фактическая цена StoreKit второй строкой кнопки `Unlock forever`, непосредственно под ней `One payment. No subscription.` (до M11 — `One-time purchase`). Без вписанного в UI числа. |
| Content order (M11) | `Keep your focus on the game` → `Unlimited Match & Americano scoring.` → состояние лимита → `Unlock forever` с ценой → `One payment. No subscription.` → статус и ход покупки → `Restore purchases` → сохранность игры и результата → `Terms`, `Privacy` → `Close`. Повторяющиеся объяснения убраны; на компактных часах допустима короткая прокрутка, но не уменьшение текста. |
| Which offer is recommended, and how that is marked | Одно предложение; нет искусственной плашки `Best value`. |
| Comparison price shown, and the StoreKit product it is derived from | Не предлагается: нет второго реально продаваемого продукта. |
| Saving claimed, and the two real prices it is the difference between | Экономия не заявляется. |
| Introductory or promotional offer: its duration, and the price after it | Не предлагается. Бесплатный опыт объясняется отдельно от цены покупки. |
| What the paywall shows when a compared product does not load | Сравниваемого продукта нет. При отсутствии основного продукта `Purchase unavailable right now.`, Retry/Close/Restore/legal доступны. |
| Restore purchases placement | Видимая строка `Restore purchases` на Unlock и в About → Access, не спрятанная в жесте. |
| Terms and Privacy links (see [Legal and support](#legal-and-support)) | Две подписанные строки `Terms` и `Privacy`, открывающие читаемый локальный контент. |
| Success, failure, cancellation, and pending behavior | Успех после проверки → `Access unlocked`; ошибка → причина/Retry; отмена → прежний экран; pending → описание и свободный выход. |
| Already purchased / family sharing | При проверенном праве показать `Unlocked`, не продавать повторно. Family Sharing не обещать без решения PRODUCT/StoreKit. |
| Expiry, refund, and offline entitlement | Lifetime не изображать подпиской. Возврат/отзыв и offline-политика принадлежат PRODUCT/ARCHITECTURE; статус не стирает счёт. |
| What happens to already-created content | Данные не удаляются из-за оплаты, ошибки магазина или restore. |
| Dismissal | Системный Back/Close сразу доступен. Нет таймера, скрытой кнопки и ловушки. |

Development-only premium override не имеет пользовательского экрана, жеста или
пути навигации; принадлежит ARCHITECTURE и отсутствует в распространяемом Release.

## Review request

**INAPPLICABLE: watchOS Watch-only.** Продукт не имеет iOS-приложения; rating prompt,
ручной пункт оценки и milestone `Review Request` не генерируются. Строки REL-208
и REL-209 фиксируются как INAPPLICABLE с этой причиной в релизном аудите. Никакое
игровое действие не зависит от показа рейтинга.

Platform policy: watchOS has no required rating request.

## Legal and support

| Question | Answer |
| --- | --- |
| The settings or about surface that carries all three, and how it is reached | `About` из New game, Result и игрового меню. Доступ без покупки и без собственного аккаунта. |
| Their wording and order on that surface | `Privacy`, `Terms`, `Support`; сверху имя приложения после решения PRODUCT H1, версия и Access. |
| Where Terms and Privacy appear on the paywall | Отдельные строки под действием покупки и restore; они доступны и при ошибке магазина. |
| Platform-supported access: browser/URL action or readable on-watch content | Локально читаемые английские страницы на Watch, публичные URL и контакт поддержки. Terms указывает Apple Standard EULA; локальный текст должен позволять прочитать условия. Системное открытие URL — дополнение только при фактической поддержке ОС. |
| What the person sees when the link cannot open | E6; локальная страница остаётся открытой, URL/контакт видны и не требуют iPhone. |

M09 `Legal and Support` наполняет четыре страницы Web: главную, privacy, terms и
support. Privacy URL ведёт на `<site>/privacy`, Support — на `<site>/support`, Terms
на [Apple Standard EULA](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/);
публичная `/terms` ссылается на тот же документ. `<site>` и контакт — не строки для
релиза, а нерешённая публичная идентичность PRODUCT H1. Публикация требует отдельного
действия владельца; локальная страница не доказывает доступность публичного URL.

V1 app, сайт и on-watch тексты — английские. Support объясняет счёт, исправление,
возврат в игру, покупку и восстановление в рамках утверждённых правил; не отправляет
пользователя на чужой маркетинговый сайт.

## Visual direction

| Question | Answer |
| --- | --- |
| Three or four adjectives | Спокойный, точный, минималистичный, премиальный. |
| Reference products and the specific lesson from each | Сторонний продукт не выбран. [Главный экран](prototypes/padel-watch.html): крупные две колонки и стабильная подача. [Остальные экраны](prototypes/padel-watch-flow.html): одна задача на экран, черновик и ясное завершение. |
| Density | На игре только текущие очки, геймы/сеты либо прогресс американо, конкретный подающий, Undo/Menu. Подробности доступны отдельным экраном. |
| Personality | Спортивный инструмент: быстрый и спокойный, без соревнования с самим матчем. |
| Amount and purpose of color | Чёрный canvas, светлый текст, мягкий лаймовый акцент нашей стороны и активного действия. Другие цвета только для предупреждения/ошибки; смысл всегда дублирован словами. |
| Imagery/illustration | В core UI не нужны фотографии, рисунки корта и декоративная ракетка. SF Symbols для Undo/Menu/навигации. Иконка приложения — отдельный нативный asset в своём этапе. |
| What this app must never look like | Таблица турнира, фитнес-dashboard, полноэкранный рекламный оффер, набор крохотных кнопок или буквальная копия HTML-размеров. |

Нативная версия обязана исправить ограничения макетов: их back controls и некоторые
CTA меньше выбранного ниже target, текст задан фиксированно, контраст и доступность
не проверены на часах. Это направление, не pixel-perfect технический образец.

Основа выбора — короткое взаимодействие, неглубокая вертикальная навигация и
независимая работа из [Apple HIG: Designing for watchOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-watchos/).
Crown используется как предсказуемая навигация/выбор с визуальной обратной связью
по [Apple HIG: Digital Crown](https://developer.apple.com/design/human-interface-guidelines/digital-crown).
Доступность и читаемость проверяются по [Apple HIG: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility).
Источники проверены 2026-10-20; численные цели этого контракта — критерии продукта.

## Craftsmanship and signature experience

| Question | Answer |
| --- | --- |
| Interaction personality, in one sentence | Короткое касание даёт уверенный результат, короткая отмена возвращает весь контекст. |
| What a person should notice first on any screen | Live: наш и чужой счёт; Setup/Editor: текущее значение; Finish: фактический результат; Unlock: условия и реальная цена. |
| What this app does faster, or in fewer steps, than the obvious alternative | Одно касание крупной области начисляет очко; Undo рядом; последние правила сокращают повторную настройку без обязательного ввода имён. |

### Action hierarchy

| Level | How it is expressed | How many per screen |
| --- | --- | --- |
| Primary | Заполненная нативная кнопка `Start game`, `Save changes`, `Finish`, `New game` | Не более одной; исключение Live — одна составная задача `Award point` с двумя равноправными исходами |
| Secondary | Нейтральная кнопка/строка `Keep playing`, `Edit result`, `Resume game` | Только необходимые альтернативы, обычно 1–2 |
| Tertiary or navigational | Нативные строки/Back, подписанный контекст, Undo/Menu с accessibility labels | По содержимому; не конкурируют с очками |
| Destructive | Явное название и destructive tint; не делать завершение красным как удаление | Обычно одна в соответствующем редакторе |

Две зоны очка одинаково удобны: акцент `US` обозначает принадлежность, а не
рекомендацию начислять очки себе. Одна зона не делается крупнее другой.

### Interaction feedback

| Question | Answer |
| --- | --- |
| Acknowledgement for an action that completes immediately | Нативный pressed state немедленно; подтверждённое новое число и подающий в одной транзакции UI. |
| Acknowledgement for one that takes longer than a moment | Статус на прежней кнопке; цифры остаются читаемыми, повторное действие временно не принимается. |
| How a change of screen or of major state is expressed | Короткий системный переход по иерархии; завершение показывает Result после записи. |
| Pressed and selected state for a primary control | Видимый тон/яркость поверхности, выбранный пункт дополнен checkmark и selected trait; без обязательного изменения геометрии. |
| Which results earn a success transformation rather than a message | Переход через гейм/сет — смена нужных чисел и подающего; финальный результат — новая иерархия Result. |
| Where inline feedback replaces a modal interruption | Ошибки поля, сохранение, Undo, новый подающий, переход гейма. Не подтверждать каждый розыгрыш. |
| Which destructive actions offer undo instead of a confirmation | Удаление сета внутри черновика и сохранённая коррекция; окончательное отбрасывание несохранённого черновика подтверждается. |
| Which results earn a haptic (see [Motion and haptics](#motion-and-haptics)) | Подтверждённое очко, Undo, завершение и явная ошибка; не каждое открытие строки. |

### Signature experience

| Question | Answer |
| --- | --- |
| The moment, and where it happens | S3/J1–J2: `point → next server → full undo`. Касание обновляет все связанные уровни счёта и подачу; Undo возвращает их вместе, даже через границу гейма или сета. |
| Why it makes the product feel unusually well made | Игроку не нужно исправлять последствия ошибки вручную в нескольких полях или угадывать, кто подаёт. Стабильные позиции помогают проверить всё одним взглядом. |
| Its behavior under Reduce Motion, VoiceOver, and the largest text size | Без перемещения цифр при Reduce Motion; VoiceOver объявляет новую пару очков и изменившегося подающего без кражи фокуса. В доступной крупной компоновке тот же порядок и те же функции. |
| How it is judged finished rather than merely present | На работающих часах исправить ошибку до/после гейма и сета, проверить точное восстановление, читаемость и отсутствие повторного ввода. Нативный UI-тест подтверждает действие, реальное устройство — тактильность/удобство; это M05/M06/M10. |

### Delight opportunities

| ID | The moment and its surface | What it should improve | Chosen treatment and medium | How it is judged worth keeping |
| --- | --- | --- | --- | --- |
| DO1 | Очко и смена подачи, S3 | Уверенность, что отмечен правильный розыгрыш | Нативный pressed state, плавная смена значения, один короткий haptic; только изменённый server получает краткий акцент | Не замедляет следующее действие и не отвлекает от чисел; проверка на запястье |
| DO2 | Undo, S3 | Уверенность в полном восстановлении | Синхронно вернулись цифры/подача, тихий haptic, короткое `Action undone` с VoiceOver announcement | Игрок понимает восстановление без отдельного диалога |
| DO3 | Сохранённый результат, S10 | Понятное завершение без ощущения потери | С M11 главный — фактический счёт; `✓ Saved` — вторичная строка после него; краткий success haptic; `Incomplete` виден сразу; `Play again` первым действием | Нет конфетти, выдуманной победы и задержки доступа к Resume |

Все три используют нативные возможности. При отсутствии пользы анимация удаляется,
а текст и состояние сохраняются. Ни один эффект не требует image-generation или сети.

They are opportunities, not features. Native first, and a bespoke asset only where native cannot express it.

### Bespoke visual assets

Для этих сценариев bespoke иллюстрации не нужны. Пустое место оставлено намеренно.
One strong asset is worth more than several decorative ones.
Будущая иконка приложения должна быть оригинальной/лицензированной, без текстовых
подписей внутри bitmap, с исходником и результатом в репозитории. Никакие картинки
не загружаются во время матча. Наличие инструмента генерации не создаёт новую фичу.

Иконка M04 — оригинальный мяч для падела цвета accent со швом `text.onAccent` на чёрном
холсте, без текста и прозрачности. Исходник — `App/Design/render-app-icon.swift`
(CoreGraphics), результат — `AppIcon.png` 1024×1024 в каталоге Watch target; watchOS сам
вписывает его в круг.

## Semantic colors

Предложенная палитра берёт визуальный тон макетов. Значения определяются один раз
семантическими assets, не в отдельных views. Watch-интерфейс намеренно тёмный;
вариант Light для system traits сохраняет эту же продуктовую палитру. Отдельной
светлой страницы со счётом не предлагается. Значения ниже — исходные кандидаты,
не утверждение о проверке реального рендера.

| Token | Role | Light | Dark | Contrast checked |
| --- | --- | --- | --- | --- |
| `background.primary` | Canvas | `#000000` | `#000000` | Проверить все пары в runtime |
| `background.secondary` | Группа/зона счёта | `#19191C` | `#19191C` | Не является единственным индикатором кнопки |
| `background.elevated` | Выбранный/поднятый элемент | `#242427` | `#242427` | Текстовые пары по AX5 |
| `text.primary` | Главные цифры и текст | `#F5F5F7` | `#F5F5F7` | Цель ≥4.5:1 на трёх backgrounds |
| `text.secondary` | Пояснения и вторичный счёт | `#A6A6AE` | `#A6A6AE` | Цель ≥4.5:1; не снижать opacity |
| `text.onAccent` | Подпись заполненной CTA | `#181E0E` | `#181E0E` | Цель ≥4.5:1 на accent |
| `accent` | Наша сторона, выбранное действие | `#DCF79B` | `#DCF79B` | Цель ≥4.5:1 для текста |
| `destructive` | Удаление / ошибка | `#FFAAA3` | `#FFAAA3` | Цель ≥4.5:1 + название действия |
| `success` | Подтверждённое сохранение | `#DCF79B` | `#DCF79B` | Смысл дополняют checkmark и текст |
| `warning` | Решающий мяч / конфликт | `#EFD48B` | `#EFD48B` | Цель ≥4.5:1 + текст |
| `separator` | Существенная граница/контур | `#808089` | `#808089` | Цель ≥3:1; декоративный divider не несёт смысла |

Increase Contrast увеличивает различимость интерактивных границ; Reduce Transparency
оставляет непрозрачные поверхности. Состояние сервера и команд понятно в grayscale.

С M04 токены — color sets каталога `Assets.xcassets` (`BackgroundPrimary`,
`BackgroundSecondary`, `BackgroundElevated`, `TextPrimary`, `TextSecondary`, `TextOnAccent`,
`AccentColor`, `Destructive`, `Success`, `Warning`, `Separator`) с одним значением для всех
appearance; views берут их через `Palette`. Hosted-тест по фактическим значениям каталога
проверяет 4.5:1 для текстовых цветов на трёх фонах и `text.onAccent` на accent, 3:1 для
`separator`. Это не заменяет проверку рендера на настоящих часах.

## Typography and layout

| Token | Dynamic Type style | Weight | Use |
| --- | --- | --- | --- |
| `title` | Системный title, доступный выбранной watchOS | semibold | Заголовок экрана; не конкурирует с цифрами |
| `heading` | headline | semibold | Названия параметров/главный результат |
| `body` | body | regular | Значения настроек, ошибки, legal |
| `caption` | caption с масштабированием | regular/medium | Контекст и вторичные подписи; важное не превращается в микротекст |
| `numeric` | Системный масштабируемый title с monospaced digits | semibold | Основные очки; `AD` полностью видно |

С M04 эти токены — `Typography` и `Spacing` в `Features/Shared/DesignSystem.swift`: title — title3.

Использовать системный шрифт и семантическое масштабирование. Не копировать
фиксированные размеры HTML. На стандартном размере основной счёт заметно крупнее
геймов/сетов. Многозначные очки американо остаются полным числом; сокращений `1k` нет.
Предельные вводимые значения — PRODUCT/ARCHITECTURE, а не ограничение макета.

| Spacing token | Value | Use |
| --- | --- | --- |
| `xs` | 4 logical pt | Внутри связки подпись/значение |
| `sm` | 8 logical pt | Между неперекрывающимися зонами очков и связанными строками |
| `md` | 12 logical pt | Внутренний отступ обычной строки |
| `lg` | 16 logical pt | Между смысловыми блоками |
| `xl` | 24 logical pt | Редкие разделы длинного legal/результата |

Базовая сетка 4 logical pt; отступы подстраиваются под системную safe area и
скругления конкретного Watch, не являются миллиметрами корпуса. Полезная ширина
равна safe area; клавиатура/системный ввод не закрывает активное поле. В цифровых
редакторах достаточно нативного picker, без обязательного ввода с клавиатуры.

**Основной экран в обычных размерах текста:** верхний короткий контекст
`Set 2`, `Golden point`, `Tie-break` или `Americano`; ниже две одинаковые крупные
кнопки, `US` слева и `THEM` справа; под ними две компактные строки `Games`/`Sets`
либо `Rallies left`/`Service block`; внизу Undo, `Serving` + конкретная роль, Menu.
Все числа команды находятся под её колонкой. Предыдущие сеты не уплотняют главный
экран. Подающий — `You`, `Partner`, `Opponent 1`, `Opponent 2`; имя не обязательно.
В узкой нижней строке допустимы две строки роли, но не неоднозначное `Opp…`.

**Настройка и редакторы:** вертикальный список, одна задача на строку. Сводка команд
над числами всегда видима в редактируемом блоке. CTA не перекрывает контент; на
небольшом экране или крупном тексте она становится последней строкой scroll content,
а не отнимает место у обязательного текста. Crown и touch одинаково позволяют
достичь каждого поля.

**Крупный доступный текст:** читаемость важнее сохранения плотности макета.
Двухколоночный блок остаётся пока помещается; далее `US` и `THEM` становятся двумя
полноширинными подписанными секциями одного экрана. Счёт/подача/Undo не исчезают,
экран допускает вертикальную прокрутку. Это предлагаемый accessibility-вариант,
а не уменьшение пользовательского шрифта. Требование чтения всего Live score без
прокрутки проверяется на стандартном и Large text size на минимальном устройстве,
из матрицы M00 для утверждённого минимума watchOS 10. Максимальный поддерживаемый системой размер отдельно
проверяется на полноту, достижимость и отсутствие обрезанного важного текста.

С M05 так устроен Live score. Одно касание команды записывает один розыгрыш; второе касание в
течение 0,5 с после записанного считается тем же касанием (так быстро розыгрыш не кончается), а
после Undo следующее касание сразу новый розыгрыш. Контекст занимает левую часть строки системных часов. Две колонки
остаются, пока очки помещаются крупно (`ViewThatFits` по высоте): на 40 mm — до XL включительно;
крупнее команды становятся двумя полноширинными секциями прокручиваемого экрана в том же порядке, а
`Games`/`Sets` — подписанными строками `US 3` / `THEM 2`. Роль подающего между круглыми Undo и Menu
держится в одной строке (уменьшается до 75 %), в секциях — до двух строк. Пока новый сет ждёт
порядка подачи, место очков занимает карточка `Set 2` / `Confirm serving`: очко нового сета до
подтверждения не записывается, а Undo рядом отменяет выигравший сет розыгрыш. Экран подтверждения
показывает пару, которой правило отдаёт первую подачу (`Your team serves first in this set.` либо
`The opponents serve first in this set.`), выбор первого подающего из неё и второго из соперников,
порядок всех четырёх и `Confirm serving` последней строкой; предложен порядок прошлого сета. После
последнего розыгрыша раунда экран показывает `Round finished` и результат (`Draw`, `US won`,
`THEM won`) вместо подающего, касания счёта не принимает, Undo доступен; `New game` — в меню, пока
экран результата не добавит M07. Неудачная запись — не alert, а состояние поверх игры: `Couldn’t
save.` / `Your last saved score is unchanged.`, `Retry` (на время записи `Saving…`) и `Cancel`. Меню
игры (S4) показывает правила (`At 40–40: …` или `16 rallies in total, 4 per server.`) и About; M06
поставил над ними исправления.
Always On: те же места и цифры, контуры вместо заливок, круги кнопок без заливки, касаний нет.
Новые цифры меняются коротким numeric-переходом (с Reduce Motion — сразу). Новый подающий
появляется коротким cross-fade роли (DO1): без цвета, чтобы акцент оставался знаком US. После Undo
строка контекста на 1,5 с говорит `Action undone` (DO2).

С M06 так устроены исправления (S5–S8). Меню игры начинается с `Edit score` и `Game settings`; оба
открывают один черновик (`Changes are saved when you tap Save.`) и ведут друг к другу строкой, а `Save
changes` на любом из них сохраняет его целиком. Edit score: `Points` (при 6:6 — `Tie-break`), `Games`,
`Sets`, `Serving`; Game settings (заголовок экрана `Settings`: длинный рядом с Back на 40 mm
обрезается): `Format`, `At 40–40` либо `Total rallies` и `Rallies per server`, `Serving`. Строки подписывают значения обеих команд (`US 40 THEM 0`), конфликт стоит под строкой текстом
E2 цвета destructive. Числа обеих команд правит один экран: `US` слева и `THEM` справа колонками
+ / число / −; Crown меняет обведённое accent число (US при открытии, другое — касанием), VoiceOver —
свайпом. При One advantage на 40:40 тот же экран спрашивает `First deuce` / `Second deuce`; AD без 40
у соперника, AD у обеих и AD при Golden point называются там же. Сеты — отдельным списком (`No completed
sets`, `Add set`); сет правится своим экраном с `Remove set 2`, а вместо подтверждения удаления список
показывает `Set 2 removed.` и `Restore set 2`. Изменение геймов, очков тай-брейка, очков или серии
американо требует проверить подачу (`Check who serves next before saving.`): экран Serving начинает с
порядка от следующего подающего (в американо и `Serve 2 of 4`), затем `Next server` и `After them`;
открыть его значит проверить, Cancel возвращает непроверенное. После первого очка тай-брейка он
спрашивает `Next point` (`Serve 1 of 2` / `Serve 2 of 2`) и `Opened the tie-break` (`Your team` / `The
opponents`). `Format` спрашивает `Change game format?` / `Enter the score for the new format. Nothing
changes until you save.`; новый счёт начинается с 0:0 и правил последней игры этого формата (иначе
`Choose`), над строками стоит `Replace game puts this round in place of the match’s score. Undo brings the
match back.`, кнопка — `Replace game`. Экран, открытый из меню, вместо Back имеет круглую ✕ (`Cancel`);
с изменениями она спрашивает `Discard changes?` / `Your saved game will stay the same.` / `Keep editing`,
так же отвечает escape VoiceOver, а жест от края экрана его не закрывает. Save с конфликтом ничего не
сохраняет: прокручивает к первой строке с ним, объявляет его и играет `failure`. Сохранённая правка
возвращает на экран счёта: строка контекста на 1,5 с говорит `Changes saved`, VoiceOver — `Changes saved.`,
очки и подающего, если он сменился. Своего haptic у правки нет, кроме правки, доводящей раунд до N:
черновик показывает `All rallies are played. Saving finishes the round.` и итог, а сохранение завершает
раунд с `success`. Неудачная запись — то же состояние E3 поверх экрана; Cancel возвращает к черновику.
Черновик переживает уход приложения в фон, пока жив процесс.

С M07 так устроены завершение и результат (S9, S10, S15). Меню играемой игры под исправлениями
показывает `Finish match` / `Finish round`, а во время следующей игры — `Last result`. S9 показывает итог,
который будет сохранён, затем `Finish this game?` / `Your current score will be saved.`, `Finish` (primary) и
`Keep playing`; запись — `Saving…` на кнопке, неудача — E3 поверх, Cancel возвращает к S9 с той же игрой.
Итог (общий для S9, S10 и Last result) повторяет колонки счёта: две плитки `US` / `THEM` с выигранными сетами
(`Sets`) или очками раунда (`Points`), под ними строки «наше — название — их»: каждый завершённый сет, затем
начатый сет с пометкой `Incomplete` цвета warning и строкой `Points` или `Tie-break`; новый сет 0:0 не
выводится, матч без единого очка говорит `No points played.` У матча победителя нет. Раунд при N называет
`US won` / `THEM won` / `Draw`, раунд, остановленный раньше, — `Ended early` и лидера (`US ahead`, `THEM
ahead`, `Points level`), и всегда `18 of 32 rallies played.` На крупнейшем тексте строки становятся названием
и строками `US 6` / `THEM 4`. S10 озаглавлен `Match finished` / `Round finished`, первым идёт `✓ Saved`
(success; на 1,5 с после правки результата — `Changes saved`), затем итог, `New game` (primary) с пояснением
`Starting a new game will keep this result for viewing only.`, `Resume game`, `Edit result` и `About`. Раунд
на N подписывает Resume текстом `All rallies are played. To resume, increase the total or correct the score.`;
его Resume открывает Game settings черновика с тем же текстом, а после сохранения большего N результат
остаётся (`Ended early`) до отдельного Resume. Правка, доводящая N до сыгранного, показывает у строки Total
rallies `All rallies are played.` и итог. New game с результата открывает выбор формата и настройку в том же
стеке, Back возвращает к редактируемому результату. Finish играет `success`; после записи стек возвращается к
результату, VoiceOver говорит `Match finished. Saved.`; после Resume строка контекста на 1,5 с говорит `Game
resumed`, VoiceOver — `Game resumed.`, очки и подающего. Раунд, завершённый последним розыгрышем, остаётся на
счёте (DO3: `success` при розыгрыше) с Undo слева и круглой ✓ (`Done`) вместо меню, которая переводит к
результату. About ведёт в `Settings`: `Local data`, список хранимого (`The game being played`, `The last
result`, `Settings saved for the next game`) и `Delete local data` цвета destructive с подтверждением
`Delete local data?` / `Cancel` / `Delete data`; без данных — `No game data is kept on this Watch.` и
недоступная кнопка, после удаления — New game. В последней, укороченной серии раунда строка серии называет её
настоящую длину: при 10/4 после восьми розыгрышей `Serve 1 of 2`.

С M11 так устроены предложение покупки, итог и повтор игры (S9, S10, S12). Access начинается
заголовком `Keep your focus on the game` и строкой `Unlimited Match & Americano scoring.`, затем
состояние лимита (`Free games left: 3 of 5`, `Five free games completed.` либо неточный счётчик без
повторной фразы о текущей игре), кнопка `Unlock forever` с ценой `Product.displayPrice` второй строкой
и сразу под ней `One payment. No subscription.`; пока право проверяется, цена грузится или продукт
недоступен, на месте кнопки `Checking purchase…`, `Loading price…` либо `Purchase unavailable right
now.` с `Retry`, а строка условий остаётся. Ниже — сообщение состояния и ход покупки или
восстановления, `Restore purchases`, `Your current game and last result stay available, even without a
purchase.`, `Terms`, `Privacy` и `Close`; sheet после отказа в старте также имеет круглую ✕. С
проверенным правом вместо предложения — `✓ Unlocked` и та же строка о безлимитном счёте, без продажи.
Итог матча больше не начинается плитками выигранных сетов: над счётом подписи колонок `US` и `THEM`,
каждый завершённый сет — строка «наше — `Set 1` — их» крупными цифрами в постоянных колонках,
незавершённый сет — отдельная карточка `Set 2 · Incomplete` со строками `Games` и `Points` (или
`Tie-break`) в тех же колонках, и, только если завершён хотя бы один сет, вторичная строка `Sets won`.
Без завершённого сета карточка — главный элемент с крупными цифрами; матч без очков говорит `No points
played.` Раунд сохраняет крупные плитки `Points`, исход и `18 of 32 rallies played.` `✓ Saved`
(на 1,5 с после правки — `Changes saved`) стоит после счёта мелкой строкой. Действия S10: `Play again`
(primary), `New game`, пояснение `Starting a new game will keep this result for viewing only.`, `Resume
game`, `Edit result`, `About`. Play again открывает Setup того же формата в том же стеке с правилами и
порядком подачи этого результата и подающим, начавшим игру; над строками `Same rules and serving as your
last game. Check who serves first.` Back возвращает к редактируемому результату, ничего не создав.

## Components and system controls

| Component | Variants | Required states | Notes |
| --- | --- | --- | --- |
| Primary button | Start / Save / Finish / New game | default, pressed, disabled, loading | Нативная семантика; размер не прыгает при loading |
| Secondary/destructive button | Keep playing / Remove set / Discard | default, pressed, disabled | Название отражает последствие |
| Text field | В MVP числовой picker вместо свободного ввода | empty, focused, filled, error, disabled | Клавиатура не является условием создания игры |
| List row | Параметр/выбранное значение/переход | default, selected, disabled | Label + value; checkmark для выбора; swipe не единственный путь |
| Empty/loading/error surface | Локальное восстановление/покупка/валидация | Все применимые interface states | Причина и действие рядом, данные не скрыты |
| Score area | US / THEM | default, pressed, saving, disabled | Нативный Button с крупным составным label; уникальная компоновка нужна для счёта, отдельный жестовый движок не нужен |
| Serving block | Standard / Americano | current, changed, needs confirmation | Текстовая роль и следующая позиция в серии; не кнопка размером в одну строку |
| Number/choice editor | Score / totals / block / rule | focused, selected, boundary, invalid | Crown работает только у явного выбора; touch-альтернатива доступна |

Навигация, списки, alerts, selection и StoreKit используют системные механизмы.
Составной score label не отменяет button traits, VoiceOver actions, hit targets
или поддержку текста. Свой control допустим только если нативный не выражает
конкретное действие и все требования доступности сохранены.

## Motion and haptics

| Motion question | Answer |
| --- | --- |
| Purpose | Связать нажатие и результат, сохранить контекст смены экрана, показать восстановление Undo. |
| Standard duration and curve | Системные transitions по умолчанию; для локального акцента предложено 120–180 ms ease-out. Запись и начисление не ждут окончания эффекта. |
| What animates / never animates | Кратко изменённое число/подающий; не вся сетка и не фон. Никаких циклических декоративных эффектов, скачков колонок или анимированного таймера. |
| Reduce Motion equivalent | Мгновенная смена значения или короткий cross-fade; pressed tone и текст сохраняются, масштаб/перемещение выключаются. |

| Event | Haptic | Why |
| --- | --- | --- |
| Успешно сохранённое очко | Один короткий нативный feedback | Подтвердить регистрацию, не спрашивать подтверждение |
| Гейм/сет тем же розыгрышем | Не накладывать несколько импульсов; один различимый нативный результат | Избежать тактильного шума |
| Undo | Один тихий нативный feedback | Подтвердить восстановление |
| Finish / confirmed unlock | Нативный success | Закончено существенное действие |
| Неверное сохранение | Нативный failure + видимый текст | Подсказать, что изменение не принято |

Точные нативные типы выбирает реализация для утверждённой watchOS и проверяет
на устройстве. M05 выбрал `WKHapticType`: очко — `click`; очко, выигравшее гейм или сет, — один
`directionUp` вместо очка; последний розыгрыш раунда и ручное завершение — `success`; Undo —
`directionDown`; неудачная запись — `failure`. Подтверждение подачи нового сета и отклонённые
касания своего haptic не имеют. Симулятор тактильность не воспроизводит: ощущение и различимость —
проверка на настоящих часах. Не обещать haptic при выключенной пользователем тактильности;
никакая информация не передаётся только вибрацией. Тап по навигационной строке
не требует собственного haptic сверх системного поведения.

## Accessibility

| ID | Requirement |
| --- | --- |
| AX1 | Каждый интерактивный элемент имеет действие, значение и trait. Score label: `Our score, 40`, hint `Double-tap to add a point`; соперники аналогично. |
| AX2 | Важное изменение объявляется один раз: новая пара очков и, если изменился, подающий. Ошибка сохранения объявляется явно; `AD` озвучивается `Advantage`. |
| AX3 | Логический порядок: контекст → US → THEM → вторичный счёт → подающий → Undo → Menu; редактор возвращает фокус на изменённую строку. |
| AX4 | Команда/подача/выбор понятны по словам и положению без цвета. Цвет не меняет идентичность. |
| AX5 | Проверить фактические пары: обычный текст ≥4.5:1, крупный ≥3:1, существенные нетекстовые индикаторы ≥3:1; все варианты appearance/contrast. |
| AX6 | Цель продукта для каждого самостоятельного touch control — минимум 44×44 logical pt с неперекрывающимися областями; фиксировать размеры на минимальном выбранном Watch. |
| AX7 | Все размеры текста, которые предоставляет поддерживаемая watchOS, доступны без отключения масштабирования. Максимальный размер использует reflow, не обрезает счёт, команды, server и действия. |
| AX8 | Reduce Motion не теряет информацию; анимация не обязательна для ввода. |
| AX9 | Нет вспышек и стробирования. |
| AX10 | Декоративные SF Symbols скрыты от accessibility; meaningful icon-only кнопки подписаны. |
| AX11 | Alert/purchase переводит фокус в своё содержимое и возвращает после закрытия. Асинхронный server update не меняет текущий control. |
| AX12 | Проверить Bold Text, Increase Contrast, Reduce Transparency и доступные на целевой watchOS средства альтернативного управления/фокуса. Неподдерживаемое устройство ввода отмечается INAPPLICABLE с фактической причиной. |

VoiceOver должен позволять провести J1–J4 без зрения; крупный текст — провести
их без помощи другой платформы. Один видимый score button не может оказаться
двумя accessibility-кнопками из-за отдельно объявленной подписи/цифры. В редакторе
порядок команд совпадает с игрой. Физические кнопки/Crown не перехватываются для
скрытых игровых действий.

## Localization

| Question | Answer |
| --- | --- |
| Languages built by the milestones | English only — подтверждено пользователем. Русские макеты служат визуальным референсом. |
| Planned languages | Будут добавлены позже; список/приоритеты владелец определит после проверки английской версии на устройстве и release readiness. Переводов в плане milestones нет. |
| Right-to-left support | Ресурсы, leading/trailing, системные направленные иконки и псевдолокализация подготовлены. В v1 US слева/THEM справа; будущая RTL-компоновка может зеркалить геометрию только вместе с подписями и числами одной semantic team. Никогда не менять ownership по индексу visual column. |
| Dates, numbers, currency, units | Системное форматирование по locale; цена — строка StoreKit. `0, 15, 30, 40, AD` — семантика матча, не арифметические единицы. |
| Pluralization | String Catalog plural variations для rallies/sets/games; полные сообщения с именованными параметрами. |
| Longest expansion assumption | Проверка минимум +40% длины и псевдо-RTL; text reflow без обрезки важных чисел/ролей. |
| Tone/formality | Короткий спокойный английский. `You`, `Partner`, `Opponent 1`, `Opponent 2`; без шуток, мотивационных лозунгов и обвинения пользователя. |

Все строки, включая accessibility labels/errors/legal, имеют локализуемый источник.
Не собирать предложение из фрагментов. Идентификаторы команд/игроков независимы от
перевода. Дополнительные локализации выполняются отдельными worktrees по WORKFLOW,
не становятся зависимостью M00–M10. Для каждого будущего языка нужны соответствующие
публичные и on-watch legal/support тексты.

Ключевые строки v1: `New game`, `Match`, `Americano`, `At 40–40`, `Golden point`,
`One advantage`, `Advantage`, `Total rallies`, `Rallies per server`, `First server`,
`Serving`, `Service order`, `Next rally in block`, `Start game`, `Edit score`,
`Game settings`, `Save changes`, `Undo`, `Finish match`, `Finish round`, `Finish`,
`Keep playing`, `Saved`, `Match finished`, `Round finished`, `Incomplete`, `Edit result`, `Resume game`.
Правило `One advantage` поясняется: `At the second deuce, the next point wins.`
Никакая подпись не использует `Star Point` как один из согласованных режимов.
M04 добавил тексты создания и восстановления: `Choose`, `From your last game. Check
before you start.`, `Second server`, `Sets aren’t limited. Finish the match
whenever you like.`, `The round ends when both teams’ points add up to the total.`,
`From 1 to 999.`, `Couldn’t save. The game hasn’t started.`, `Earlier save restored`,
`Start over`; полный список с комментариями — `Localizable.xcstrings`. M05 добавил тексты
живого счёта: `Tie-break`, `Round finished`, `Draw`, `US won`, `THEM won`, `Action undone`,
`Confirm serving`, `Your team serves first in this set.`, `Couldn’t save.`, `Your last saved score is
unchanged.`, VoiceOver-подписи `Undo`, `Game menu` и подсказку `Double-tap to add a point`, а также
объявления вроде `Us 15, them 0.`, `Game to us. Games: us 1, them 0. Serving: Opponent 1.` и
`Action undone.` — каждое из целых предложений. M06 добавил тексты исправлений: `Edit score`, `Game
settings`, `Points`, `Format`, `Save changes`, `Replace game`, `Add set`, `Remove set 2`, `Restore set 2`,
`First deuce`, `Second deuce`, `Next server`, `After them`, `Next point`, `Opened the tie-break`, `Next rally
in block`, `Changes saved`, тексты E2 из таблицы ошибок и подтверждения `Discard changes?`, `Change game
format?`; счёт в них (`40–40`, `7–5`) держится на одной строке word joiner, `5 of 10 rallies played.`
имеет plural. M07 добавил тексты завершения: `Finish this game?`, `Your current score will be saved.`,
`Keep playing`, `Saved`, `Incomplete`, `No points played.`, `Ended early`, `US ahead`, `Points level`, `Edit
result`, `Resume game`, `Last result`, `Game resumed`, `Delete local data?` и пояснения S10/S15. M11 добавил
`Keep your focus on the game`, `Unlimited Match & Americano scoring.`, `One payment. No subscription.`,
`Play again`, `Sets won`, `Set 2 · Incomplete` (номер — параметр) и `Same rules and serving as your last
game. Check who serves first.`

## Appearance and device coverage

| Question | Answer |
| --- | --- |
| Light and dark appearance | Одна намеренно тёмная Watch-палитра сохраняет контраст при обоих системных traits; страницы не инвертируются автоматически. Системные экраны сохраняют нативное оформление. |
| Elevation and imagery variants in dark mode | Непрозрачные тональные поверхности; изображения не нужны. Increase Contrast может добавить различимый контур. |
| Smallest supported screen | M00 выбирает конкретную модель в рамках утверждённого минимума watchOS 10; область 162×197 в HTML — лишь проверочный макет, не обещание поддерживаемой модели. M00 фиксирует реальные модели/runtime, M05/M10 доказывают layout. |
| Largest supported layout / iPad behavior | Самый большой выбранный Watch увеличивает свободное пространство, не добавляет новые панели. iPhone/iPad не поддерживаются продуктом. |
| Orientation and multitasking policy | Нативная ориентация Watch; при изменении руки/ориентации Crown смысл US/THEM остаётся тем же. Нет телефонного split view. |
| Screens that reflow vertically at large text | Все формы, result, legal и доступная компоновка Live score; нативная прокрутка Crown/touch. |
| Text that may truncate / must never truncate | Нельзя обрезать счёт, команды, текущего server, смысл правила, цену/условия и действие ошибки. Необязательный длинный app title может уступить место системному Back. |

Always On, опущенное запястье и системный возврат к циферблату требуют runtime- и
hardware-проверки на утверждённой ОС. Не обещать постоянно включённый экран или
приём касания в неактивном состоянии. Сниженная яркость сохраняет понятные
достоверные цифры; декоративное движение выключено. При активации экран сначала
возвращает сохранённое состояние, и лишь отдельное игровое действие начисляет очко.

## Prohibited patterns

- Decoration standing in for resolution — украшение вместо ясной иерархии.
- A premium override that ships — доступный в распространяемом приложении обход оплаты.
- An invented reference price — сравнение с ценой, которую не продаёт реальный продукт StoreKit.
- Legal or support reachable only from the paywall — legal и поддержка доступны отдельно.
- A sentiment gate — запрос оценки только после предварительного выбора положительного отзыва; Watch-only вообще не добавляет rating flow.
- Неподписанные команды, смена их принадлежности при смене сторон корта или цвета.
- Скрытый ввод очков Crown, long press, жестом пробуждения или кнопкой системы.
- Мелкие отдельные `+`, подтверждение каждого очка или меню вместо доступной отмены.
- Принудительный best-of-N, обязательные четыре имени, турнирная таблица или iPhone.
- Автоматическое стирание/пересчёт при правке правила, формата, подачи или результата.
- `Saved` до завершения записи; новый пустой матч вместо сообщения о повреждении.
- Декоративный градиент, blur, фон или анимация, скрывающие плохую иерархию.
- Raw RGB в views; цвет как единственное объяснение ошибки/команды/подачи.
- Фиксированный шрифт, подавленный Dynamic Type, обрезка essential text, перекрывающиеся hit areas.
- Важное действие только через swipe, маленькая непомеченная иконка или недостижимый VoiceOver control.
- Анимация, задерживающая следующее очко; несколько haptics за один розыгрыш; вспышки.
- Иллюстрации со встроенным UI-текстом, generic artwork и загрузка изображений во время игры.
- Тёмный paywall с невидимым Close, выдуманная скидка, hard-coded цена/лимит или неподтверждённый free trial.
- Покупка поверх активной игры; стирание данных при refund/restore failure; ложное `Unlocked` при pending.
- Legal/support только после оплаты, на другой платформе или в неоткрывающемся внешнем URL.
- Фиктивная HealthKit-тренировка ради активного экрана или новый сбор данных без решения.
- Rating prompt для этого Watch-only продукта и development premium override в Release/UI.
- Автоматическое предложение покупки после результата, вторичный тариф или подписка (M11).
- Крупный бессодержательный итог `0–0 Sets` или объявление победителя обычного матча (M11).
- Демонстрация, которая пишет в реальные данные, расходует лимит или выглядит как реальная игра без метки `Demo` (M12).
- Счёт на циферблате без общей базы и гарантии актуальности (M14).

## Unresolved design decisions

Отдельного нерешённого вопроса по стилю или управлению после подготовки предложения
нет: направление и адаптивная компоновка одобрены владельцем 2026-10-20. Изменения
продуктового направления требуют нового решения владельца.
Не дублируем вопросы с альтернативами, которыми владеют другие контракты:

Минимальная watchOS 10 утверждена владельцем 2026-10-20 (H3 закрыт).
Конкретные размеры часов и проверки доступности фиксируются по
[ARCHITECTURE → Deployment target](ARCHITECTURE.md#deployment-target);
выбор ОС не означает выполненной проверки компоновки.

PRODUCT H2 закрыт 2026-10-20: сет до шести геймов, тай-брейк при 6:6, подтверждение
порядка подачи перед каждым следующим сетом. Для интерфейса это значит контекст
`Tie-break` с числовыми очками и текущим подающим на игровом экране, подтверждение
порядка на границе сета (M05) и правку очков и позиции подачи тай-брейка (M06);
их компоновка и тексты следуют разделам этого документа.

| ID | Question | Options | Blocks | Developer decision needed |
| --- | --- | --- | --- | --- |
| PRODUCT H1 (closed) | Публичные реквизиты и retention утверждены 2026-10-21 | Dzmitry Dziachenka; dzmitry.dziachenka@gmail.com; padel-score-wrist.pages.dev; см. PRODUCT | M09 проверяет About/legal/support | Решено владельцем |
| PRODUCT H4 (closed) | Пять завершённых игр, затем lifetime unlock; ledger сохраняется | Утверждено 2026-10-21 | M08 реализует и проверяет | Решено владельцем |
| План покупки (closed) | История для всех, фиксированный Match-демо, M11–M15 до M10 | Утверждено 2026-10-22, [план](purchase-appeal-plan.md) | M11–M15 реализуют и проверяют | Решено владельцем |

Общее одобрение получено; до выбора зависимых H-решений соответствующая нативная
реализация не начинается.
