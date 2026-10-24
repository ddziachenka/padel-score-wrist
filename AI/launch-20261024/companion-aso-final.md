# Companion ASO revalidation — 2026-10-25

Prepared for the owner's renewed ASO review and neutral-marketing decision. This is
Builder source/runtime/store assessment, not an independent audit or ranking promise.
Saved ASC fields were read through official API for14 locales before editing;
new copy was saved to the unsubmitted ASC draft and42locale records were read
back exactly; .artifacts/M17/aso-readback-verification.json. No build selected
or submitted by this metadata operation.

## Evidence and decisions

Apple confirms the app is searchable by its name; do not duplicate it in keywords:
https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
Product-page guidance covers name/subtitle, relevant keywords, first images,
limits and lack of search-ranking effect from promotional text:
https://developer.apple.com/app-store/product-page/

Padel already appears in retained brand Padel Score — Wrist in every locale. Its
absence from keywords is intentional, not a missing sport. Russian падел is a
different, relevant script and is retained. No search-volume/ranking/conversion
measurements are available; none are invented. No competitor names, fitness,
remote live iPhone scoring, tournament organization, rankings or cloud sync added.

Live primary competitor pages reread: Padel Score Watch Counter
https://apps.apple.com/us/app/padel-score-watch-counter/id6742797108;
PadelWrist https://apps.apple.com/us/app/padelwrist-padel-score/id6799725420;
Efecto https://apps.apple.com/es/app/efecto-padel-americano/id6813393257.
Observed promises: first emphasizes multi-screen/fitness/statistics, second wrist
scoring/sync/insights, third Classic/Americano plus phone scoring/tournaments.
Our supported benefit is simple independent Watch score/next server/Undo, real
Match and own-round Americano, local history and offline use. These are practical
benefits, not claims of exclusivity. Existing native first images communicate them.

Owner: «В promotional text лучше вообще не писать про подписку» and requested no
aggressive marketing. All14 promo/evergreen fields now identical, only features;
no purchase/lifetime/subscription/price/free-offer/deadline/urgency. Removed the
repeated early purchase paragraph in13 descriptions, retaining factual five-free-
completed-games and one-time lifetime conditions later. German already has one
access section later. No mandatory onboarding/paywall added. Phone guide/demos/
access are distinguished from real Watch scoring. No product model changed.
The launch0-price period still covers public launch day plus7full regional days.
Monitor updated/readback verified via automation_update; it must never restore
promotional offer text. Evidence: automation-before-quiet-aso.json and
automation-quiet-aso-update.json under .artifacts/M17.

## Locale decisions

A/B here are editorial alternatives, not measured App Store A/B experiments.
Selected concrete function/device/modes over abstract slogan; regional prose
preserves ES/MX independence wording and PT marcador/serviço/campo vs BR
placar/saque/quadra. Exact title/subtitle words are not repeated in keywords.
Keyword lengths conservatively <=100 UTF-8 bytes; unused bytes are not filled
with low-relevance promises.

| Locale | Selected subtitle | Alternative | Keyword bytes | Promo characters |
| --- | --- | --- | ---: | ---: |
| en-US | Match & Americano scorekeeper | Score and serve on your Watch | 88 | 140 |
| es-ES | Marcador y saque en tu Watch | Partidos y Americano en Watch | 80 | 145 |
| es-MX | Marcador y saque en tu Watch | Cuenta puntos desde tu muñeca | 80 | 145 |
| it | Segnapunti Match e Americano | Punti e servizio sul tuo Watch | 93 | 147 |
| fr-FR | Points, service et Americano | Le score au poignet | 97 | 150 |
| pt-PT | Marcador e serviço no pulso | Partidas e Americano no Watch | 99 | 145 |
| pt-BR | Placar e saque no seu pulso | Partidas e Americano no Watch | 99 | 149 |
| nl-NL | Puntenteller voor je Watch | Score en service op je pols | 87 | 144 |
| de-DE | Punktezähler für deine Watch | Spielstand und Aufschlag | 88 | 150 |
| sv | Poängräknare på din Watch | Poäng och serve på handleden | 73 | 128 |
| da | Pointtæller på dit Watch | Point og serv på håndleddet | 71 | 137 |
| fi | Pistelaskuri ranteessasi | Pisteet ja seuraava syöttäjä | 84 | 144 |
| no | Poengteller på Apple Watch | Poeng og serve på håndleddet | 71 | 136 |
| ru | Счёт матчей и американо | Табло и подача на часах | 94 | 139 |

## Visual and technical recheck

Viewed the actual final native iPhone set through all7 final-contact-sheets (14
locales,4images each), plus direct English originals and all14 Header/Search pairs.
Older development contact-sheets were also encountered but are not submission
sources: those contain price0/setup banner states. Only canonical
AI/store-assets/iphone-m16/manifest.json resolves the submitted56 opaque1320x2868
native dark-mode files: Start, Match demo, Americano demo, owned Access. No price,
launch discount, award, urgency or false phone scoring claim in this final gallery.
Demo labels/next server/undo and explicit Apple Watch requirement remain legible;
Access ownership view shows purchase verified rather than demanding an immediate buy.
The native scroll/tab-bar continuation is not cosmetically reconstructed.

Header/Search use real localized Watch scores and quiet graphite/lime court
geometry, short glance benefit, no prices/discounts/awards. New subtitles in text
fields may differ from still-valid descriptive lines baked into older Search
creative; neither asserts unsupported behavior. No cosmetic rerender is necessary.
Existing84 Watch originals and28 creative files preserved; their previous hashes
are retained. No new expensive screenshot run required for metadata-only changes.

python3 Scripts/verify-iphone-store-materials.py exit0:56 native images14locales,
order/hash/provenance/dimensions/opacity. Existing localized original store-material
check exit0:72 originals and website copies. Final launch package manifest separately
identifies the84 larger416x496 Watch placements. Field validation0errors14locales:
.artifacts/M17/aso-final-validation.json. Public URLs were previously reread131/131
identical after prepared companion site publication. All42 ASC metadata records were reread and exactly matched after upload. All56 phone placements and unchanged112 Watch/creative placements were read
back in14 locales (168total). Fresh ASC client previews were checked in English
(light/dark) and Finnish(light), in addition to all14 canonical native contact
sheets and all14 Header/Search pairs. A batch locale-switch preview attempt hit
ASC client cache/locator failures and is not counted as completed14-locale UI
proof; all14 field/asset associations are separately exact API readback.
Evidence: aso-readback-verification.json and asc-preview-*-fresh-light.png /
asc-preview-en-US-current-dark.png under .artifacts/M17/.

## Final local metadata (reviewable source)

Exact final upload fields and SHA256. Broad equipment/court terms in French and
Portuguese were replaced with supported deuce/advantage/tiebreak/draw intent.
Watch query coverage exists in every locale through subtitle or keywords, without
repeating the same word in both. Cyrillic падел is retained for Russian queries.

### da

SHA256: `55e429cc81d91bff04ee2353f1217e6386a87ff5ecc1668da3c51a38189d4997`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Pointtæller på dit Watch",
  "promotionalText": "Stillingen og næste server med et blik. Tæl point i Kamp og Americano på Apple Watch, fortryd et tryk, og find dine tidligere resultater.",
  "description": "Hold fokus på spillet.\n\nSe stillingen og næste server med et hurtigt blik. Tryk på et hold efter hver duel, brug Fortryd ved et fejltryk, og tæl point offline på dit Apple Watch. Uret fungerer selvstændigt. Ingen konto er nødvendig.\n\nUNDER KAMPEN\n• Kamp: partier og sæt med tie-break ved 6–6.\n• Vælg Golden point, Én fordel eller Fordel ved lige.\n• Bekræft serverækkefølgen for hvert nyt sæt.\n• Americano: tæl point i din egen runde med et samlet antal dueller og server pr. spiller.\n• Se begge holds point, dueller tilbage og næste server.\n• Fortryd et tryk, eller ret stillingen og serverækkefølgen.\n• Vend tilbage til din gemte kamp, når du åbner appen igen.\n\nEFTER KAMPEN\n• Se sætcifrene for afsluttede sæt og et eventuelt uafsluttet sæt. Afslut en kamp, når du vil.\n• Se de endelige point i en Americano-runde, også ved uafgjort eller afslutning før tid.\n• Vælg Spil igen fra det seneste resultat for at genbruge regler og serverækkefølge. Kontrollér første server før start.\n• Se alle dine afsluttede kampe i den lokale Historik med datoer og detaljerede resultater. Historikken er gratis, også efter grænsen på fem kampe.\n\nPRØV PÅ DIT UR\nPrøv pointtavlen åbner et fast kampeksempel mærket Demo. Tryk, fortryd eller nulstil, uden at det ændrer dine kampe eller bruger en gratis kamp. Eksemplet slutter efter ét parti, ikke efter en hel kamp.\n\nFøj Padel Score-genvejen til en kompatibel urskive eller Smart stak for at åbne appen hurtigt. Genvejen åbner appen og viser ikke en løbende stilling.\n\nFEM GRATIS KAMPE\nDe første fem afsluttede rigtige kampe er automatisk gratis. Derefter giver ét køb adgang til ubegrænset mange nye kampe for altid. Din igangværende kamp, det seneste resultat, historikken og demoen er stadig tilgængelige uden køb. Sletning af lokale kampdata nulstiller ikke antallet af afsluttede kampe.\n\nKøb og gendannelse kræver en internetforbindelse til App Store. Brug Om → Adgang → Gendan køb med den Apple-konto, du brugte til købet.\n\nKampe og historik bliver lokalt på dette ur. Appen har ingen overførsel mellem ure, synkronisering i skyen eller sikkerhedskopiering i skyen. Lokale data kan gå tabt, hvis du fjerner appen eller skifter ur. Americano gælder din egen runde uden turneringsplanlægning eller rangliste.\n\nKræver Apple Watch med watchOS 10 eller nyere. Dansk grænseflade. Ingen reklamer.\n\nAnonymitet: https://padel-score-wrist.pages.dev/da/privacy/\nVilkår: https://padel-score-wrist.pages.dev/da/terms/\n\nPÅ DIN IPHONE\nKom i gang med en kort guide, prøv interaktive demoer af Kamp og Americano, og køb eller gendan adgang på livstid. Rigtige kampe tælles på Apple Watch, som fungerer selvstændigt. Demoerne virker offline og bruger ingen gratis kampe. Brug samme Apple-konto på begge enheder; historik og tælleren for gratis kampe bliver på uret. iPhone-appen kræver iOS 17 eller nyere.",
  "keywords": "pointtavle,americano,kamp,serv,tiebreak,double,historik,fortryd,offline",
  "iapName": "Ubegrænset adgang for altid",
  "iapDescription": "Ubegrænsede kampe i Kamp og Americano. Ét køb.",
  "evergreenPromotionalText": "Stillingen og næste server med et blik. Tæl point i Kamp og Americano på Apple Watch, fortryd et tryk, og find dine tidligere resultater.",
  "headline": "Dit spil.\nMed ét blik.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/da/",
  "supportUrl": "https://padel-score-wrist.pages.dev/da/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/da/privacy/"
}
```

### de-DE

SHA256: `6933072d41f7dbd5dbce5e4def3c575a62bfbce26d912d101e24e26f80d11178`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Punktezähler für deine Watch",
  "promotionalText": "Spielstand und Aufschläger auf einen Blick. Zähle Match und Americano auf deiner Apple Watch, mache einen Tipp rückgängig und sieh frühere Ergebnisse.",
  "keywords": "spielstand,aufschlag,americano,tiebreak,sätze,ergebnis,verlauf,doppel,offline,korrektur",
  "iapName": "Dauerhafte Freischaltung",
  "iapDescription": "Unbegrenzt Match und Americano. Ohne Abo.",
  "description": "Konzentriere dich aufs Spiel. Padel Score — Wrist zeigt dir den Spielstand und den nächsten Aufschläger direkt auf deiner Apple Watch. Tippe nach jedem Ballwechsel auf ein Team. Einen falschen Tipp nimmst du mit „Rückgängig“ zurück.\n\nZÄHLEN AUF DER WATCH\n• Match: Punkte, Spiele und Sätze, Tie-Breaks bei 6–6 sowie Vorteil, Golden Point oder einmal Vorteil als Einstand-Regel. Bei „Einmal Vorteil“ entscheidet nach dem ersten Vorteil beim zweiten Einstand der nächste Punkt.\n• Americano: deine eigene Runde mit einer festen Gesamtzahl an Ballwechseln für beide Teams zusammen und einer gewählten Zahl pro Aufschläger.\n• Sieh, wer als Nächstes aufschlägt. Bestätige die Aufschlagreihenfolge vor jedem neuen Satz.\n• Zähle offline, ohne Konto, Werbung oder iPhone-Begleitapp.\n\nKORRIGIEREN UND FORTSETZEN\nMit „Rückgängig“ nimmst du die letzte Aktion zurück. Im Partiemenü kannst du Punkte, Spiele, Sätze und Aufschläge korrigieren. Das Match beendest du selbst, wenn du möchtest. Es gibt keine feste Zahl an Sätzen und keinen automatisch bestimmten Gesamtsieger.\n\nKehre später zu deiner gespeicherten Partie zurück. Ergebnisse zeigen die Satzergebnisse oder den Endstand der Americano-Runde, auch bei Unentschieden oder vorzeitigem Ende. Mit „Noch mal spielen“ beim letzten Ergebnis übernimmst du Regeln und Aufschlagreihenfolge. Prüfe vor dem Start, wer zuerst aufschlägt.\n\nAlle beendeten Partien findest du mit Datum und ausführlichen Ergebnissen im lokalen Verlauf. Dieser bleibt kostenlos, auch nach dem Limit von fünf Partien. Nur das letzte Ergebnis kannst du bearbeiten oder fortsetzen.\n\nAUF DEINER WATCH AUSPROBIEREN\n„Spielstand ausprobieren“ öffnet ein festes Match-Beispiel mit Demo-Kennzeichnung. Tippe Punkte ein, nutze „Rückgängig“ oder setze die Demo zurück. Deine echten Partien und kostenlosen Partien bleiben unberührt. Das Beispiel endet nach einem Spiel, nicht nach einem ganzen Match.\n\nFüge den Padel-Score-Schnellstart einem kompatiblen Zifferblatt oder dem Smart-Stapel hinzu. Er öffnet die App und zeigt keinen Live-Spielstand.\n\nFÜNF PARTIEN KOSTENLOS\nDie ersten fünf abgeschlossenen echten Partien sind automatisch kostenlos. Danach schaltet ein einmaliger Kauf unbegrenzt neue Partien dauerhaft frei. Deine laufende Partie, das letzte Ergebnis, der Verlauf und die Demo bleiben auch ohne Kauf zugänglich. Das Löschen lokaler Partiedaten setzt den Zähler abgeschlossener Partien nicht zurück.\n\nFür Kauf und Wiederherstellung brauchst du eine Internetverbindung zum App Store. Wähle „Über die App → Freischaltung → Käufe wiederherstellen“ mit dem Apple Account, den du beim Kauf verwendet hast.\n\nPartien und Verlauf bleiben lokal auf dieser Watch. Die App bietet keine Übertragung zwischen Watches, Cloud-Synchronisierung oder Cloud-Sicherung. Beim Entfernen der App oder beim Wechsel der Watch können lokale Daten verloren gehen. Americano zählt deine eigene Runde, ohne Turnierplanung oder Rangliste.\n\nFür Apple Watch ab watchOS 10. Deutsche Oberfläche. Keine Werbung.\n\nDatenschutz: https://padel-score-wrist.pages.dev/de/privacy/\nNutzungsbedingungen: https://padel-score-wrist.pages.dev/de/terms/\n\nAUF DEINEM IPHONE\nStarte mit einer kurzen Anleitung, probiere die interaktiven Match- und Americano-Demos aus und kaufe oder stelle deinen lebenslangen Zugang wieder her. Echte Partien zählst du auf der Apple Watch, die eigenständig funktioniert. Die Demos laufen offline und verbrauchen keine Gratispartien. Nutze auf beiden Geräten denselben Apple Account; Verlauf und Gratispartien-Zähler bleiben auf der Watch. Die iPhone-App benötigt iOS 17 oder neuer.",
  "evergreenPromotionalText": "Spielstand und Aufschläger auf einen Blick. Zähle Match und Americano auf deiner Apple Watch, mache einen Tipp rückgängig und sieh frühere Ergebnisse.",
  "headline": "Dein Spiel.\nAuf einen Blick.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/de/",
  "supportUrl": "https://padel-score-wrist.pages.dev/de/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/de/privacy/"
}
```

### en-US

SHA256: `191d99ac2f54e26d17f53056562de00a5e7aeab3eeb5236931742cc7a9339823`

```json
{
  "name": "Padel Score — Wrist",
  "description": "Keep your focus on the game.\n\nSee the score and the next server at a glance. Tap a team after each rally, use Undo for a mistaken tap, and keep scoring offline on your Apple Watch. Your Watch works independently. No account needed.\n\nDURING THE GAME\n• Match: games and sets, with a tie-break at 6–6.\n• Choose Golden point, One advantage, or Advantage at deuce.\n• Confirm serving order for each new set.\n• Americano: score your own round with a shared rally total and serves per player.\n• See each team’s points, rallies remaining, and the next server.\n• Undo a tap or correct the score and serving order.\n• Return to your saved game after closing the app.\n\nAFTER THE GAME\n• Read completed set scores and any incomplete set. Finish a Match whenever you choose.\n• See an Americano round’s final points, including a draw or an early finish.\n• Use Play again from the latest result to reuse its rules and serving order. Check the first server before starting.\n• Browse all your finished games in local History, with dates and detailed results. History is free, including after the five-game limit.\n\nTRY IT ON YOUR WATCH\nTry the scoreboard opens a fixed Match example with a Demo label. Tap, Undo, or reset it without changing your games or using a free game. The example ends after one game, not a whole match.\n\nAdd the Padel Score launcher to a compatible watch face or Smart Stack to open the app quickly. The launcher opens the app; it does not display a live score.\n\nFIVE GAMES FREE\nThe first five completed real games are free automatically. After that, one lifetime purchase unlocks unlimited new games. Your current game, latest result, history, and demo stay accessible without purchasing. Deleting local game data does not reset the completed-game count.\n\nBuying and restoring require an internet connection to the App Store. Use About → Access → Restore purchases with the Apple Account used for the purchase.\n\nGames and history stay locally on this Watch. There is no transfer between Watches, cloud sync, or cloud backup service in the app. Removing the app or changing Watches may lose local data. Americano scoring covers your own round, without tournament scheduling or standings.\n\nRequires Apple Watch with watchOS 10 or later. Available in English, Spanish, Italian, French, Portuguese (Portugal and Brazil), Dutch, German, Swedish, Danish, Finnish, Norwegian Bokmål, and Russian. No ads.\n\nPrivacy: https://padel-score-wrist.pages.dev/privacy/\nTerms: https://padel-score-wrist.pages.dev/terms/\n\nON YOUR IPHONE\nGet started with a short guide, try interactive Match and Americano demos, and get or restore lifetime access. Real games stay on your Apple Watch, which works independently. Demos work offline and do not use your free games. Use the same Apple Account on both devices; history and the free-game count stay on the Watch. The iPhone companion requires iOS 17 or later.",
  "iapName": "Lifetime unlock",
  "iapDescription": "Unlimited Match and Americano games. Yours for life.",
  "subtitle": "Match & Americano scorekeeper",
  "promotionalText": "Keep the score and next server in view. Score Match and Americano on your Apple Watch, undo a misplaced tap and revisit your finished games.",
  "evergreenPromotionalText": "Keep the score and next server in view. Score Match and Americano on your Apple Watch, undo a misplaced tap and revisit your finished games.",
  "keywords": "scoreboard,counter,serve,tiebreak,points,doubles,undo,deuce,golden,offline,history,watch",
  "headline": "Your game.\nAt a glance.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/",
  "supportUrl": "https://padel-score-wrist.pages.dev/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/privacy/"
}
```

### es-ES

SHA256: `d8b36f60ef0916d23d2b21786e75dc0802fa16b9e9849523c7f2afcfe06cb710`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Marcador y saque en tu Watch",
  "promotionalText": "El marcador y el próximo saque, de un vistazo. Cuenta puntos en Partido y Americano desde tu Apple Watch, deshaz errores y consulta tu historial.",
  "description": "Concéntrate en el juego.\n\nConsulta de un vistazo el marcador y quién saca después. Toca un equipo tras cada punto, usa Deshacer si te equivocas y sigue llevando el marcador sin conexión en tu Apple Watch. El reloj funciona de forma independiente. No necesitas una cuenta.\n\nDURANTE LA PARTIDA\n• Partido: juegos y sets, con tie-break al llegar a 6–6.\n• Elige Punto de oro, Una ventaja o Ventaja al llegar a iguales.\n• Confirma el orden de saque en cada nuevo set.\n• Americano: lleva el marcador de tu propia ronda con un total de puntos compartido y puntos por sacador.\n• Consulta los puntos de cada equipo, los puntos restantes y el siguiente sacador.\n• Deshaz un toque o corrige el marcador y el orden de saque.\n• Cierra la app y vuelve a tu partida guardada.\n\nDESPUÉS DE LA PARTIDA\n• Consulta los marcadores de los sets terminados y del que haya quedado sin terminar. Finaliza el partido cuando quieras.\n• Consulta los puntos finales de una ronda de Americano, también si termina en empate o antes de tiempo.\n• Usa Volver a jugar desde el último resultado para reutilizar sus reglas y su orden de saque. Comprueba quién saca primero antes de empezar.\n• Revisa todas tus partidas terminadas en el historial local, con fechas y resultados detallados. El historial es gratis, incluso tras agotar las cinco partidas.\n\nPRUÉBALO EN TU WATCH\nProbar el marcador abre un ejemplo fijo de Partido con la etiqueta Demo. Suma un punto, deshazlo o reinicia la demo sin modificar tus partidas ni consumir una partida gratuita. El ejemplo termina tras un juego, no tras un partido completo.\n\nAñade el acceso rápido de Padel Score a una esfera compatible o al Grupo inteligente para abrir la app rápidamente. Este acceso abre la app; no muestra el marcador en directo.\n\nCINCO PARTIDAS GRATIS\nLas primeras cinco partidas reales completadas son gratis, sin activar nada. Después, un único pago te da acceso de por vida para iniciar partidas sin límite. Tu partida actual, el último resultado, el historial y la demo siguen disponibles sin comprar. Eliminar los datos locales no reinicia el contador de partidas completadas.\n\nPara comprar o restaurar compras, necesitas conexión a internet con el App Store. Ve a Acerca de → Acceso → Restaurar compras con la cuenta de Apple que usaste para comprar.\n\nLas partidas y el historial se guardan localmente en este Watch. La app no permite transferirlos entre relojes ni ofrece sincronización o copias de seguridad en la nube. Si eliminas la app o cambias de Watch, puedes perder los datos locales. Americano abarca tu propia ronda, sin programación de torneos ni clasificaciones.\n\nRequiere Apple Watch con watchOS 10 o posterior. Interfaz en español. Sin anuncios.\n\nPrivacidad: https://padel-score-wrist.pages.dev/es/privacy/\nCondiciones: https://padel-score-wrist.pages.dev/es/terms/\n\nEN TU IPHONE\nDescubre cómo empezar, prueba las demostraciones interactivas de Partido y Americano y consigue o restaura el acceso de por vida. Los partidos reales se juegan en el Apple Watch, que funciona de forma independiente. Las demostraciones funcionan sin conexión y no consumen partidos gratuitos. Usa la misma cuenta de Apple en ambos dispositivos; el historial y el contador de partidos gratuitos se quedan en el reloj. El complemento para iPhone requiere iOS 17 o posterior.",
  "keywords": "contador,partido,puntos,americano,deshacer,tiebreak,dobles,historial,ventaja,oro",
  "iapName": "Acceso de por vida",
  "iapDescription": "Partidos y rondas de Americano sin límite.",
  "evergreenPromotionalText": "El marcador y el próximo saque, de un vistazo. Cuenta puntos en Partido y Americano desde tu Apple Watch, deshaz errores y consulta tu historial.",
  "headline": "Tu partido.\nDe un vistazo.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/es/",
  "supportUrl": "https://padel-score-wrist.pages.dev/es/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/es/privacy/"
}
```

### es-MX

SHA256: `51fec1444761668edf5cfdfb5775d6fbf73b1b45278b9436012f567fc7ec985e`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Marcador y saque en tu Watch",
  "promotionalText": "Consulta el marcador y quién saca de un vistazo. Lleva tus partidos y rondas de Americano en Apple Watch, corrige un toque y revisa tu historial.",
  "description": "Concéntrate en el juego.\n\nConsulta de un vistazo el marcador y quién saca después. Toca un equipo tras cada punto, usa Deshacer si te equivocas y sigue llevando el marcador sin conexión en tu Apple Watch. El reloj funciona por su cuenta. No necesitas una cuenta.\n\nDURANTE LA PARTIDA\n• Partido: juegos y sets, con tie-break al llegar a 6–6.\n• Elige Punto de oro, Una ventaja o Ventaja al llegar a iguales.\n• Confirma el orden de saque en cada nuevo set.\n• Americano: lleva el marcador de tu propia ronda con un total de puntos compartido y puntos por sacador.\n• Consulta los puntos de cada equipo, los puntos restantes y el siguiente sacador.\n• Deshaz un toque o corrige el marcador y el orden de saque.\n• Cierra la app y vuelve a tu partida guardada.\n\nDESPUÉS DE LA PARTIDA\n• Consulta los marcadores de los sets terminados y del que haya quedado sin terminar. Finaliza el partido cuando quieras.\n• Consulta los puntos finales de una ronda de Americano, también si termina en empate o antes de tiempo.\n• Usa Volver a jugar desde el último resultado para reutilizar sus reglas y su orden de saque. Comprueba quién saca primero antes de empezar.\n• Revisa todas tus partidas terminadas en el historial local, con fechas y resultados detallados. El historial es gratis, incluso tras agotar las cinco partidas.\n\nPRUÉBALO EN TU WATCH\nProbar el marcador abre un ejemplo fijo de Partido con la etiqueta Demo. Suma un punto, deshazlo o reinicia la demo sin modificar tus partidas ni consumir una partida gratuita. El ejemplo termina tras un juego, no tras un partido completo.\n\nAñade el acceso rápido de Padel Score a una esfera compatible o al Grupo inteligente para abrir la app rápidamente. Este acceso abre la app; no muestra el marcador en directo.\n\nCINCO PARTIDAS GRATIS\nLas primeras cinco partidas reales completadas son gratis, sin activar nada. Después, un único pago te da acceso de por vida para iniciar partidas sin límite. Tu partida actual, el último resultado, el historial y la demo siguen disponibles sin comprar. Eliminar los datos locales no reinicia el contador de partidas completadas.\n\nPara comprar o restaurar compras, necesitas conexión a internet con el App Store. Ve a Acerca de → Acceso → Restaurar compras con la cuenta de Apple que usaste para comprar.\n\nLas partidas y el historial se guardan localmente en este Watch. La app no permite transferirlos entre relojes ni ofrece sincronización o copias de seguridad en la nube. Si eliminas la app o cambias de Watch, puedes perder los datos locales. Americano abarca tu propia ronda, sin programación de torneos ni clasificaciones.\n\nRequiere Apple Watch con watchOS 10 o posterior. Interfaz en español. Sin anuncios.\n\nPrivacidad: https://padel-score-wrist.pages.dev/es/privacy/\nCondiciones: https://padel-score-wrist.pages.dev/es/terms/\n\nEN TU IPHONE\nEmpieza con una guía breve, prueba las demostraciones interactivas de Partido y Americano y obtén o restaura el acceso de por vida. Los partidos reales se juegan en el Apple Watch, que funciona por su cuenta. Las demostraciones funcionan sin conexión y no usan tus partidos gratuitos. Usa la misma Cuenta de Apple en ambos dispositivos; el historial y el contador de partidos gratuitos permanecen en el reloj. La app para iPhone requiere iOS 17 o posterior.",
  "keywords": "contador,partido,puntos,americano,deshacer,tiebreak,dobles,historial,ventaja,oro",
  "iapName": "Acceso de por vida",
  "iapDescription": "Partidos y rondas de Americano sin límite.",
  "evergreenPromotionalText": "Consulta el marcador y quién saca de un vistazo. Lleva tus partidos y rondas de Americano en Apple Watch, corrige un toque y revisa tu historial.",
  "headline": "Tu partido.\nDe un vistazo.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/es/",
  "supportUrl": "https://padel-score-wrist.pages.dev/es/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/es/privacy/"
}
```

### fi

SHA256: `2c7cd49f7c47ed06d143122c17175daab475ba5d6aca2eea589da6fb94656b38`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Pistelaskuri ranteessasi",
  "promotionalText": "Pisteet ja seuraava syöttäjä yhdellä vilkaisulla. Laske Ottelun ja Americanon pisteet Apple Watchilla, kumoa napautus ja katso aiemmat tulokset.",
  "description": "Keskity peliin.\n\nNäet pistetilanteen ja seuraavan syöttäjän yhdellä vilkaisulla. Napauta joukkuetta jokaisen pallon jälkeen ja korjaa virhenapautus Kumoa-toiminnolla. Apple Watch laskee pisteet itsenäisesti ilman verkkoyhteyttä tai käyttäjätiliä.\n\nPELIN AIKANA\n• Ottelu: pelit ja erät sekä tie-break tilanteessa 6–6.\n• Valitse tasatilanteeseen Ratkaiseva piste, Yksi etu tai Etu.\n• Vahvista jokaisen uuden erän syöttöjärjestys.\n• Americano: oman kierroksesi pistelasku, joukkueiden yhteinen pallomäärä ja pallot syöttäjää kohti.\n• Näet joukkueiden pisteet, jäljellä olevat pallot ja seuraavan syöttäjän.\n• Kumoa napautus tai korjaa pistetilanne ja syöttöjärjestys.\n• Palaa tallennettuun peliin sovelluksen sulkemisen jälkeen.\n\nPELIN JÄLKEEN\n• Katso valmiiden erien tulokset ja mahdollinen keskeneräinen erä. Voit päättää ottelun milloin haluat.\n• Näet Americano-kierroksen loppupisteet myös tasapelissä tai kesken päätetyllä kierroksella.\n• Viimeisimmän tuloksen Pelaa uudelleen käyttää samoja sääntöjä ja syöttöjärjestystä. Tarkista ensimmäinen syöttäjä ennen aloittamista.\n• Selaa kaikkia päättyneitä pelejä paikallisessa Historiassa päivämäärineen ja tarkkoine tuloksineen. Historia on ilmainen myös viiden ilmaispelin jälkeen.\n\nKOKEILE KELLOSSASI\nKokeile pistetaulua avaa valmiin otteluesimerkin, jossa on Demo-merkintä. Napauta, kumoa tai aloita demo alusta muuttamatta omia pelejäsi tai kuluttamatta ilmaispelejä. Esimerkki päättyy yhden pelin, ei kokonaisen ottelun jälkeen.\n\nLisää Padel Scoren käynnistyspainike yhteensopivaan kellotauluun tai älykkääseen pinoon. Se avaa sovelluksen nopeasti, mutta ei näytä reaaliaikaista pistetilannetta.\n\nVIISI ILMAISPELIÄ\nEnsimmäiset viisi päättynyttä oikeaa peliä ovat automaattisesti ilmaisia. Sen jälkeen kertaosto avaa pysyvän käyttöoikeuden ja rajattomasti uusia pelejä. Nykyinen peli, viimeisin tulos, historia ja demo ovat käytettävissä ilman ostoa. Paikallisten pelitietojen poistaminen ei nollaa käytettyjen ilmaispelien määrää.\n\nOstaminen ja ostojen palauttaminen vaativat verkkoyhteyden App Storeen. Valitse Tietoja → Käyttöoikeus → Palauta ostot ja käytä ostossa käytettyä Apple-tiliä.\n\nPelit ja historia säilyvät paikallisesti tässä kellossa. Sovelluksessa ei ole siirtoa kellojen välillä, pilvisynkronointia eikä pilvivarmuuskopiointipalvelua. Sovelluksen poistaminen tai kellon vaihtaminen voi johtaa paikallisten tietojen menettämiseen. Americano-pistelasku kattaa oman kierroksesi. Turnausaikatauluja tai sarjataulukoita ei ole.\n\nVaatii Apple Watchin ja watchOS 10:n tai uudemman. Käyttöliittymä suomeksi. Ei mainoksia.\n\nTietosuoja: https://padel-score-wrist.pages.dev/fi/privacy/\nKäyttöehdot: https://padel-score-wrist.pages.dev/fi/terms/\n\nIPHONESSA\nAloita lyhyen oppaan avulla, kokeile Ottelu- ja Americano-tilojen interaktiivisia demoja ja osta tai palauta pysyvä käyttöoikeus. Oikeiden pelien pisteet lasketaan itsenäisesti toimivalla Apple Watchilla. Demot toimivat ilman verkkoyhteyttä eivätkä kuluta ilmaisia pelejä. Käytä molemmissa laitteissa samaa Apple-tiliä; historia ja ilmaisten pelien laskuri pysyvät kellossa. iPhone-sovellus vaatii iOS 17:n tai uudemman.",
  "keywords": "pistetaulu,americano,ottelu,syöttö,tiebreak,nelinpeli,historia,kumoa,offline,watch",
  "iapName": "Pysyvä käyttöoikeus",
  "iapDescription": "Rajattomasti Ottelu- ja Americano-pelejä kertaostolla.",
  "evergreenPromotionalText": "Pisteet ja seuraava syöttäjä yhdellä vilkaisulla. Laske Ottelun ja Americanon pisteet Apple Watchilla, kumoa napautus ja katso aiemmat tulokset.",
  "headline": "Pelisi.\nYhdellä silmäyksellä.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/fi/",
  "supportUrl": "https://padel-score-wrist.pages.dev/fi/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/fi/privacy/"
}
```

### fr-FR

SHA256: `f25b6a608c75470ce18eb075c3b1bd5aa9176e94d04795cacc96069470ff1eec`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Points, service et Americano",
  "promotionalText": "Le score et le prochain serveur, d’un coup d’œil. Comptez les points en Match et Americano sur Apple Watch, annulez un appui et retrouvez vos parties.",
  "description": "Concentrez-vous sur le jeu.\n\nLe score et le prochain serveur, d’un coup d’œil. Touchez une équipe après chaque point, annulez un appui accidentel et suivez la partie hors ligne sur votre Apple Watch. La montre fonctionne de manière autonome. Aucun compte nécessaire.\n\nPENDANT LA PARTIE\n• Match : jeux et sets, avec jeu décisif à 6–6.\n• À égalité : point décisif, un seul avantage ou avantage classique.\n• Confirmez l’ordre de service à chaque nouveau set.\n• Americano : suivez votre propre manche avec un total de points commun aux deux équipes et un nombre de services par joueur.\n• Retrouvez les points de chaque équipe, les points restants et le prochain serveur.\n• Annulez un appui ou corrigez le score et l’ordre de service.\n• Retrouvez votre partie enregistrée après avoir fermé l’app.\n\nAPRÈS LA PARTIE\n• Consultez les scores des sets terminés et du set incomplet. Terminez un Match quand vous le souhaitez.\n• Retrouvez les points finaux d’une manche Americano, même en cas d’égalité ou d’arrêt anticipé.\n• Depuis le dernier résultat, Rejouer reprend les règles et l’ordre de service. Vérifiez le premier serveur avant de commencer.\n• Consultez toutes vos parties terminées dans l’historique local, avec dates et résultats détaillés. L’historique reste gratuit après les cinq parties gratuites.\n\nESSAYEZ SUR VOTRE WATCH\nEssayer le tableau de score ouvre un exemple Match prédéfini portant la mention Démo. Ajoutez des points, annulez ou réinitialisez la démo sans modifier vos parties ni consommer de partie gratuite. L’exemple se termine après un jeu, et non après un match entier.\n\nAjoutez le lanceur Padel Score à un cadran compatible ou à la pile intelligente pour ouvrir l’app rapidement. Il ouvre l’app sans afficher le score en direct.\n\nCINQ PARTIES GRATUITES\nLes cinq premières parties réelles terminées sont gratuites, sans démarche à effectuer. Ensuite, un achat à vie débloque un nombre illimité de nouvelles parties. La partie en cours, le dernier résultat, l’historique et la démo restent accessibles sans achat. Supprimer les données de jeu locales ne remet pas le compteur de parties terminées à zéro.\n\nL’achat et sa restauration nécessitent une connexion Internet à l’App Store. Ouvrez À propos → Accès → Restaurer les achats avec le compte Apple utilisé lors de l’achat.\n\nLes parties et l’historique restent sur cette Watch. L’app ne propose ni transfert entre Watch, ni synchronisation, ni service de sauvegarde dans le cloud. Supprimer l’app ou changer de Watch peut entraîner la perte des données locales. Le suivi Americano couvre votre propre manche, sans organisation de tournoi ni classement.\n\nNécessite une Apple Watch avec watchOS 10 ou version ultérieure. Interface en français. Sans publicité.\n\nConfidentialité : https://padel-score-wrist.pages.dev/fr/privacy/\nConditions : https://padel-score-wrist.pages.dev/fr/terms/\n\nSUR VOTRE IPHONE\nDécouvrez le guide de démarrage, essayez les démos interactives de Match et d’Americano et achetez ou restaurez l’accès à vie. Les vraies parties se jouent sur l’Apple Watch, qui fonctionne de manière autonome. Les démos fonctionnent hors ligne et ne consomment pas de parties gratuites. Utilisez le même compte Apple sur les deux appareils ; l’historique et le compteur de parties gratuites restent sur la montre. L’app pour iPhone nécessite iOS 17 ou une version ultérieure.",
  "keywords": "compteur,marqueur,match,égalité,avantage,double,historique,poignet,jeu,annuler,hors ligne,watch",
  "iapName": "Accès illimité à vie",
  "iapDescription": "Matchs et manches Americano sans limite. Achat unique.",
  "evergreenPromotionalText": "Le score et le prochain serveur, d’un coup d’œil. Comptez les points en Match et Americano sur Apple Watch, annulez un appui et retrouvez vos parties.",
  "headline": "Votre match.\nEn un coup d’œil.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/fr/",
  "supportUrl": "https://padel-score-wrist.pages.dev/fr/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/fr/privacy/"
}
```

### it

SHA256: `b19302e98bf4efc9ff326cc58d6f70260602b5c73a42f8ee0a143d2a338e6807`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Segnapunti Match e Americano",
  "promotionalText": "Il punteggio e chi serve, a colpo d’occhio. Segna Incontro e Americano sul tuo Apple Watch, annulla un tocco e ritrova le partite nella cronologia.",
  "description": "Concentrati sulla partita.\n\nGuarda il punteggio e chi batte con un’occhiata. Tocca una squadra dopo ogni punto, annulla un tocco sbagliato e continua a segnare offline sul tuo Apple Watch. L’orologio funziona in autonomia. Non serve un account.\n\nDURANTE LA PARTITA\n• Incontro: game e set, con tie-break sul 6–6.\n• Sul 40 pari scegli Punto de oro, Un solo vantaggio o Vantaggio.\n• Conferma l’ordine di battuta a ogni nuovo set.\n• Americano: segna i punti del tuo turno con un totale comune alle due squadre e una serie di battute per giocatore.\n• Vedi i punti delle squadre, quelli rimasti e il prossimo battitore.\n• Annulla un tocco o correggi punteggio e ordine di battuta.\n• Chiudi l’app e torna alla partita salvata.\n\nDOPO LA PARTITA\n• Consulta i punteggi dei set completati e del set eventualmente incompleto. Termina un Incontro quando vuoi.\n• Vedi i punti finali di un turno di Americano, anche in caso di pareggio o termine anticipato.\n• Dall’ultimo risultato, Gioca ancora riutilizza regole e ordine di battuta. Controlla il primo battitore prima di iniziare.\n• Consulta tutte le partite concluse nella Cronologia locale, con date e risultati dettagliati. La cronologia è gratuita anche dopo il limite delle cinque partite.\n\nPROVA SUL TUO WATCH\nProva il segnapunti apre un esempio fisso di Incontro contrassegnato da Demo. Tocca, annulla o reimposta senza modificare le tue partite e senza consumarne una gratuita. L’esempio termina dopo un game, non dopo un incontro intero.\n\nAggiungi il pulsante di Padel Score a un quadrante compatibile o a Raccolta smart per aprire l’app rapidamente. Il pulsante apre l’app e non mostra il punteggio in tempo reale.\n\nCINQUE PARTITE GRATUITE\nLe prime cinque partite reali completate sono gratuite, senza attivazione. Poi un solo acquisto sblocca per sempre nuove partite illimitate. Partita in corso, ultimo risultato, cronologia e demo restano disponibili anche senza acquistare. Eliminare i dati locali non azzera il conteggio delle partite completate.\n\nAcquisto e ripristino richiedono una connessione internet all’App Store. Usa Info → Accesso → Ripristina acquisti con l’Apple Account usato per acquistare.\n\nPartite e cronologia restano su questo Watch. L’app non offre trasferimento tra Watch, sincronizzazione o backup sul cloud. Rimuovendo l’app o cambiando Watch potresti perdere i dati locali. Il segnapunti Americano riguarda solo il tuo turno: non gestisce calendario o classifica di un torneo.\n\nRichiede Apple Watch con watchOS 10 o successivo. Interfaccia in italiano. Nessuna pubblicità.\n\nPrivacy: https://padel-score-wrist.pages.dev/it/privacy/\nCondizioni: https://padel-score-wrist.pages.dev/it/terms/\n\nSULL’IPHONE\nScopri come iniziare, prova le demo interattive di Incontro e Americano e acquista o ripristina l’accesso a vita. Le partite vere si giocano sull’Apple Watch, che funziona in autonomia. Le demo funzionano offline e non consumano partite gratuite. Usa lo stesso Apple Account sui due dispositivi: cronologia e conteggio delle partite gratuite restano sull’orologio. L’app per iPhone richiede iOS 17 o successivo.",
  "keywords": "punteggio,contatore,partita,servizio,battuta,tiebreak,doppio,cronologia,annulla,offline,watch",
  "iapName": "Accesso illimitato",
  "iapDescription": "Incontri e Americano senza limiti, per sempre.",
  "evergreenPromotionalText": "Il punteggio e chi serve, a colpo d’occhio. Segna Incontro e Americano sul tuo Apple Watch, annulla un tocco e ritrova le partite nella cronologia.",
  "headline": "La tua partita.\nA colpo d’occhio.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/it/",
  "supportUrl": "https://padel-score-wrist.pages.dev/it/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/it/privacy/"
}
```

### nl-NL

SHA256: `02546044a53ee6f0356488c324ea48568435a53fd75d3f14bc83bd29feae9dd8`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Puntenteller voor je Watch",
  "promotionalText": "De stand en de volgende serveerder in één oogopslag. Tel Match en Americano op je Apple Watch, herstel een tik en bekijk je eerdere wedstrijden.",
  "keywords": "scorebord,americano,wedstrijd,service,tiebreak,dubbelspel,geschiedenis,ongedaan,offline",
  "iapName": "Levenslange toegang",
  "iapDescription": "Onbeperkt Match en Americano. Eén betaling.",
  "description": "Houd je aandacht bij het spel.\n\nDe score en de volgende serveerder in één oogopslag. Tik na elke rally op een team, maak een verkeerde tik ongedaan en houd offline de score bij op je Apple Watch. Je Watch werkt zelfstandig. Je hebt geen account nodig.\n\nTIJDENS HET SPELEN\n• Match: games en sets, met een tiebreak bij 6–6.\n• Kies Golden point, Eenmaal voordeel of Voordeel bij deuce.\n• Bevestig de servicevolgorde voor elke nieuwe set.\n• Americano: houd je eigen ronde bij met een gezamenlijk rallytotaal en een aantal services per speler.\n• Zie de punten per team, de resterende rally’s en de volgende serveerder.\n• Maak een tik ongedaan of corrigeer de score en servicevolgorde.\n• Keer na het sluiten van de app terug naar je opgeslagen wedstrijd.\n\nNA HET SPELEN\n• Bekijk voltooide setstanden en een eventuele onvoltooide set. Beëindig een Match wanneer je wilt.\n• Bekijk de eindscore van een Americano-ronde, ook bij gelijkspel of voortijdig stoppen.\n• Gebruik Opnieuw spelen bij je laatste resultaat voor dezelfde regels en servicevolgorde. Controleer vóór de start wie er eerst serveert.\n• Bekijk al je voltooide wedstrijden in de lokale Geschiedenis, met datums en gedetailleerde resultaten. Geschiedenis blijft gratis na de limiet van vijf wedstrijden.\n\nPROBEER HET OP JE WATCH\nProbeer het scorebord opent een vast Match-voorbeeld met het label Demo. Tik, maak acties ongedaan of start de demo opnieuw. Dit verandert niets aan je wedstrijden en gebruikt geen gratis wedstrijd. Het voorbeeld eindigt na één game, niet na een hele match.\n\nVoeg de Padel Score-knop toe aan een geschikte wijzerplaat of de slimme stapel om de app snel te openen. De knop opent de app en toont geen actuele score.\n\nVIJF GRATIS WEDSTRIJDEN\nDe eerste vijf voltooide echte wedstrijden zijn automatisch gratis. Daarna ontgrendel je met één aankoop levenslang onbeperkt nieuwe wedstrijden. Je huidige wedstrijd, laatste resultaat, geschiedenis en demo blijven ook zonder aankoop beschikbaar. Het wissen van lokale wedstrijdgegevens zet de teller voor voltooide wedstrijden niet terug.\n\nVoor kopen en herstellen is een internetverbinding met de App Store nodig. Ga naar Info → Toegang → Aankopen herstellen met het Apple Account waarmee je hebt gekocht.\n\nWedstrijden en geschiedenis blijven lokaal op deze Watch. De app biedt geen overdracht tussen Watches, cloudsynchronisatie of reservekopieën in de cloud. Als je de app verwijdert of een andere Watch gebruikt, kunnen lokale gegevens verloren gaan. Americano houdt alleen je eigen ronde bij, zonder toernooiplanning of ranglijsten.\n\nVereist Apple Watch met watchOS 10 of nieuwer. Nederlandse interface. Geen advertenties.\n\nPrivacy: https://padel-score-wrist.pages.dev/nl/privacy/\nVoorwaarden: https://padel-score-wrist.pages.dev/nl/terms/\n\nOP JE IPHONE\nGa aan de slag met een korte uitleg, probeer de interactieve demo’s van Match en Americano en koop of herstel levenslange toegang. Echte wedstrijden houd je bij op de Apple Watch, die zelfstandig werkt. De demo’s werken offline en kosten geen gratis wedstrijden. Gebruik op beide apparaten dezelfde Apple Account; je geschiedenis en de teller voor gratis wedstrijden blijven op de Watch. De iPhone-app vereist iOS 17 of nieuwer.",
  "evergreenPromotionalText": "De stand en de volgende serveerder in één oogopslag. Tel Match en Americano op je Apple Watch, herstel een tik en bekijk je eerdere wedstrijden.",
  "headline": "Jouw wedstrijd.\nIn één oogopslag.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/nl/",
  "supportUrl": "https://padel-score-wrist.pages.dev/nl/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/nl/privacy/"
}
```

### no

SHA256: `202d247746b0dbc63bde1b843820b53fae3c8fbb9732c3ab2bf26673896e0f53`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Poengteller på Apple Watch",
  "promotionalText": "Se stillingen og neste server med ett blikk. Tell poeng i Kamp og Americano på Apple Watch, angre et trykk og finn tidligere resultater.",
  "description": "Konsentrer deg om spillet.\n\nSe stillingen og neste server med ett blikk. Trykk på et lag etter hver ballveksling, bruk Angre ved et feiltrykk og tell poeng uten internett på Apple Watch. Klokken fungerer selvstendig. Du trenger ingen konto.\n\nUNDER SPILLET\n• Kamp: game og sett, med tie-break ved 6–6.\n• Velg Golden point, Én fordel eller Fordel ved 40–40.\n• Bekreft serverekkefølgen for hvert nytt sett.\n• Americano: tell poeng i din egen runde med et felles antall ballvekslinger og et valgt antall server per spiller.\n• Se lagenes poeng, ballvekslinger som gjenstår og neste server.\n• Angre et trykk eller rett stillingen og serverekkefølgen.\n• Kom tilbake til det lagrede spillet etter at du har lukket appen.\n\nETTER SPILLET\n• Se stillingen i fullførte sett og et eventuelt ufullført sett. Avslutt en kamp når du vil.\n• Se sluttresultatet i en Americano-runde, også ved uavgjort eller tidlig avslutning.\n• Velg Spill igjen fra det nyeste resultatet for å bruke samme regler og serverekkefølge. Sjekk hvem som server først før du starter.\n• Se alle avsluttede spill i lokal Historikk med datoer og detaljerte resultater. Historikken er gratis, også etter grensen på fem spill.\n\nPRØV PÅ KLOKKEN\nPrøv poengtavlen åpner et fast kampeksempel merket Demo. Trykk, angre eller nullstill uten å endre spillene dine eller bruke et gratisspill. Eksemplet avsluttes etter ett game, ikke en hel kamp.\n\nLegg til Padel Score-knappen på en kompatibel urskive eller i Smart stabel for å åpne appen raskt. Knappen åpner appen, men viser ikke stillingen underveis.\n\nFEM GRATISSPILL\nDe fem første fullførte, ekte spillene er gratis uten at du trenger å gjøre noe. Deretter gir ett engangskjøp varig tilgang til ubegrenset antall nye spill. Spillet du spiller, det nyeste resultatet, historikken og demoen er tilgjengelig uten kjøp. Sletting av lokale spilldata nullstiller ikke antallet fullførte spill.\n\nKjøp og gjenoppretting krever internettilkobling til App Store. Bruk Om → Tilgang → Gjenopprett kjøp med Apple-kontoen du kjøpte med.\n\nSpill og historikk lagres lokalt på denne klokken. Appen har ingen overføring mellom klokker, synkronisering i skyen eller sikkerhetskopiering i skyen. Lokale data kan gå tapt hvis du fjerner appen eller bytter klokke. Americano dekker poengtelling i din egen runde, uten turneringsoppsett eller tabeller.\n\nKrever Apple Watch med watchOS 10 eller nyere. Norsk bokmål er tilgjengelig. Ingen reklame.\n\nPersonvern: https://padel-score-wrist.pages.dev/nb/privacy/\nVilkår: https://padel-score-wrist.pages.dev/nb/terms/\n\nPÅ IPHONEN\nKom i gang med en kort veiledning, prøv interaktive demoer av Kamp og Americano og kjøp eller gjenopprett livsvarig tilgang. Ekte kamper telles på Apple Watch, som fungerer selvstendig. Demoene virker uten internett og bruker ingen gratiskamper. Bruk samme Apple-konto på begge enhetene; historikken og telleren for gratiskamper blir på klokken. iPhone-appen krever iOS 17 eller nyere.",
  "keywords": "poengtavle,americano,kamp,serve,tiebreak,dobbel,historikk,angre,offline",
  "iapName": "Varig tilgang",
  "iapDescription": "Ubegrenset Kamp og Americano. Ett engangskjøp.",
  "evergreenPromotionalText": "Se stillingen og neste server med ett blikk. Tell poeng i Kamp og Americano på Apple Watch, angre et trykk og finn tidligere resultater.",
  "headline": "Ditt spill.\nMed ett blikk.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/nb/",
  "supportUrl": "https://padel-score-wrist.pages.dev/nb/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/nb/privacy/"
}
```

### pt-BR

SHA256: `a85b55340a3417abf725ca3e7068d1761a77d392bc7cbb0444d74cb6399a3668`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Placar e saque no seu pulso",
  "promotionalText": "Veja o placar e quem saca em um instante. Marque pontos em Partida e Americano no Apple Watch, desfaça um toque e consulte seu histórico de partidas.",
  "description": "Concentre-se no jogo.\n\nVeja a pontuação e quem saca a seguir em um instante. Toque em uma equipe após cada ponto, use Desfazer se tocar por engano e continue a marcar pontos sem internet no Apple Watch. O relógio funciona por conta própria. Não precisa criar uma conta.\n\nDURANTE A PARTIDA\n• Partida: games e sets, com tie-break em 6–6.\n• Em 40–40, escolha Ponto de ouro, Uma vantagem ou Vantagem.\n• Confirme a ordem de saque em cada novo set.\n• Americano: marque sua rodada com um total de pontos compartilhado e saques por jogador.\n• Veja os pontos de cada equipe, os pontos restantes e quem saca a seguir.\n• Desfaça um toque ou corrija a pontuação e a ordem de saque.\n• Feche o app e volte à partida salva.\n\nDEPOIS DA PARTIDA\n• Consulte os resultados dos sets terminados e de qualquer set incompleto. Termine a Partida quando quiser.\n• Veja os pontos finais da rodada de Americano, incluindo empates ou rodadas terminadas antes do fim.\n• Use Jogar novamente no último resultado para reutilizar as regras e a ordem de saque. Confirme quem saca primeiro antes de começar.\n• Consulte todas as partidas terminadas no Histórico local, com datas e resultados detalhados. O Histórico é gratuito, mesmo depois do limite de cinco partidas.\n\nEXPERIMENTE NO APPLE WATCH\nExperimentar placar abre um exemplo fixo de Partida, identificado como Demonstração. Adicione pontos, use Desfazer ou reinicie sem alterar suas partidas nem gastar uma partida gratuita. O exemplo termina após um game, não após uma partida completa.\n\nAdicione o atalho Padel Score a um mostrador compatível ou ao Conjunto Inteligente para abrir o app rapidamente. O atalho não mostra a pontuação ao vivo.\n\nCINCO PARTIDAS GRATUITAS\nAs primeiras cinco partidas reais terminadas são gratuitas, sem qualquer ativação. Depois, uma única compra de acesso vitalício desbloqueia novas partidas ilimitadas. A partida atual, o último resultado, o histórico e a demonstração continuam acessíveis sem comprar. Apagar os dados locais das partidas não reinicia a contagem de partidas terminadas.\n\nComprar e restaurar compras exige conexão com a internet e com a App Store. Use Sobre → Acesso → Restaurar compras com a Conta Apple usada na compra.\n\nAs partidas e o histórico ficam salvos localmente neste Apple Watch. O app não tem transferência entre relógios, sincronização na nuvem nem serviço de backups na nuvem. Remover o app ou trocar de Apple Watch pode causar a perda de dados locais. O modo Americano marca apenas sua rodada, sem organização de torneios nem classificações.\n\nRequer Apple Watch com watchOS 10 ou posterior. Disponível em português. Sem publicidade.\n\nPrivacidade: https://padel-score-wrist.pages.dev/pt-br/privacy/\nTermos: https://padel-score-wrist.pages.dev/pt-br/terms/\n\nNO IPHONE\nVeja o guia inicial, experimente as demonstrações interativas de Partida e Americano e compre ou restaure o acesso vitalício. As partidas reais são jogadas no Apple Watch, que funciona por conta própria. As demonstrações funcionam sem internet e não usam suas partidas gratuitas. Use a mesma Conta Apple nos dois dispositivos; o histórico e a contagem de partidas gratuitas ficam no relógio. O app para iPhone requer iOS 17 ou posterior.",
  "keywords": "pontos,americano,partida,tiebreak,vantagem,empate,duplas,histórico,contador,desfazer,offline,watch",
  "iapName": "Acesso vitalício",
  "iapDescription": "Partidas ilimitadas. Compra única, sem assinatura.",
  "evergreenPromotionalText": "Veja o placar e quem saca em um instante. Marque pontos em Partida e Americano no Apple Watch, desfaça um toque e consulte seu histórico de partidas.",
  "headline": "Seu jogo.\nEm um olhar.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/pt-br/",
  "supportUrl": "https://padel-score-wrist.pages.dev/pt-br/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/pt-br/privacy/"
}
```

### pt-PT

SHA256: `de6f3d37437707370cce9796cb7784274a64d0d897770364147701efa63bb6c5`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Marcador e serviço no pulso",
  "promotionalText": "O marcador e quem serve, num instante. Conte os pontos de Partida e Americano no Apple Watch, anule um toque e consulte o histórico das partidas.",
  "description": "Concentre-se no jogo.\n\nVeja a pontuação e quem serve a seguir num instante. Toque numa equipa após cada ponto, use Anular se tocar por engano e continue a marcar pontos sem internet no Apple Watch. O relógio funciona de forma independente. Não precisa de criar conta.\n\nDURANTE A PARTIDA\n• Partida: jogos e sets, com tie-break a 6–6.\n• A 40–40, escolha Ponto de ouro, Uma vantagem ou Vantagem.\n• Confirme a ordem de serviço em cada novo set.\n• Americano: marque a sua ronda com um total de pontos partilhado e serviços por jogador.\n• Veja os pontos de cada equipa, os pontos restantes e quem serve a seguir.\n• Anule um toque ou corrija a pontuação e a ordem de serviço.\n• Feche a app e regresse à partida guardada.\n\nDEPOIS DA PARTIDA\n• Consulte os resultados dos sets terminados e de qualquer set incompleto. Termine a Partida quando quiser.\n• Veja os pontos finais da ronda de Americano, incluindo empates ou rondas terminadas antes do fim.\n• Use Jogar novamente no último resultado para reutilizar as regras e a ordem de serviço. Confirme quem serve primeiro antes de começar.\n• Consulte todas as partidas terminadas no Histórico local, com datas e resultados detalhados. O Histórico é gratuito, mesmo depois do limite de cinco partidas.\n\nEXPERIMENTE NO APPLE WATCH\nExperimentar marcador abre um exemplo fixo de Partida, identificado como Demonstração. Adicione pontos, use Anular ou reinicie sem alterar as suas partidas nem gastar uma partida gratuita. O exemplo termina após um jogo, não após uma partida completa.\n\nAdicione o atalho Padel Score a um mostrador compatível ou à Pilha inteligente para abrir a app rapidamente. O atalho não mostra a pontuação em direto.\n\nCINCO PARTIDAS GRATUITAS\nAs primeiras cinco partidas reais terminadas são gratuitas, sem qualquer ativação. Depois, uma única compra de acesso vitalício desbloqueia novas partidas ilimitadas. A partida atual, o último resultado, o histórico e a demonstração continuam acessíveis sem comprar. Apagar os dados locais das partidas não repõe a contagem de partidas terminadas.\n\nComprar e restaurar compras exige ligação à internet e à App Store. Use Sobre → Acesso → Restaurar compras com a Conta Apple usada na compra.\n\nAs partidas e o histórico ficam guardados localmente neste Apple Watch. A app não tem transferência entre relógios, sincronização na nuvem nem serviço de cópias de segurança na nuvem. Remover a app ou mudar de Apple Watch pode causar a perda de dados locais. O modo Americano marca apenas a sua ronda, sem organização de torneios nem classificações.\n\nRequer Apple Watch com watchOS 10 ou posterior. Disponível em português. Sem publicidade.\n\nPrivacidade: https://padel-score-wrist.pages.dev/pt-pt/privacy/\nTermos: https://padel-score-wrist.pages.dev/pt-pt/terms/\n\nNO IPHONE\nConsulte o guia inicial, experimente as demonstrações interativas de Partida e Americano e compre ou restaure o acesso vitalício. As partidas reais são jogadas no Apple Watch, que funciona de forma independente. As demonstrações funcionam sem internet e não gastam partidas gratuitas. Utilize a mesma Conta Apple nos dois dispositivos; o histórico e a contagem de partidas gratuitas ficam no relógio. A app para iPhone requer iOS 17 ou posterior.",
  "keywords": "pontos,americano,partida,tiebreak,vantagem,desempate,pares,histórico,contador,anular,offline,watch",
  "iapName": "Acesso vitalício",
  "iapDescription": "Partidas ilimitadas. Pagamento único, sem subscrição.",
  "evergreenPromotionalText": "O marcador e quem serve, num instante. Conte os pontos de Partida e Americano no Apple Watch, anule um toque e consulte o histórico das partidas.",
  "headline": "O seu jogo.\nNum relance.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/pt-pt/",
  "supportUrl": "https://padel-score-wrist.pages.dev/pt-pt/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/pt-pt/privacy/"
}
```

### ru

SHA256: `496f26ee0bdbd4198282549ab0203553977d3115b1b5a3e64f1c07abd0912930`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Счёт матчей и американо",
  "promotionalText": "Счёт и следующий подающий — с первого взгляда. Ведите матчи и американо на Apple Watch, отменяйте случайные нажатия и смотрите историю игр.",
  "description": "Сосредоточьтесь на игре.\n\nСчёт и следующий подающий видны с первого взгляда. Нажимайте на команду после каждого розыгрыша, отменяйте случайные нажатия и ведите счёт без интернета на Apple Watch. Часы работают самостоятельно. Регистрация не нужна.\n\nВО ВРЕМЯ ИГРЫ\n• Матч: геймы и сеты, тай-брейк при 6:6.\n• При «ровно» выберите золотое очко, одно преимущество или преимущество без ограничения числа циклов.\n• Подтверждайте порядок подачи перед каждым новым сетом.\n• Американо: ведите свой раунд с общим числом розыгрышей для обеих команд и серией подач на игрока.\n• Следите за очками команд, оставшимися розыгрышами и следующим подающим.\n• Отменяйте нажатия, исправляйте счёт и порядок подачи.\n• Вернитесь к сохранённой игре после закрытия приложения.\n\nПОСЛЕ ИГРЫ\n• Смотрите счёт завершённых сетов и незавершённого сета. Матч можно завершить в любой момент.\n• Смотрите итоговые очки раунда американо, включая ничью или досрочное завершение.\n• Кнопка «Сыграть снова» на последнем результате перенесёт правила и порядок подачи в новую игру. Перед началом проверьте первого подающего.\n• В локальной истории доступны все завершённые игры с датами и подробными результатами. Просмотр бесплатный, в том числе после пяти бесплатных игр.\n\nПОПРОБУЙТЕ НА ЧАСАХ\n«Попробовать счётчик» открывает готовый пример матча с пометкой «Демо». Добавляйте очки, отменяйте действия или сбрасывайте пример. Ваши игры не изменятся, бесплатные игры не расходуются. Пример заканчивается после одного гейма, а не целого матча.\n\nДобавьте кнопку Padel Score на совместимый циферблат или в Смарт-стопку для быстрого запуска. Она открывает приложение и не показывает текущий счёт.\n\nПЯТЬ ИГР БЕСПЛАТНО\nПервые пять завершённых реальных игр бесплатны — ничего включать не нужно. Затем для новых игр нужна разовая покупка бессрочного доступа. Текущая игра, последний результат, история и демо остаются доступны без покупки. Удаление игровых данных не сбрасывает счётчик завершённых игр.\n\nДля покупки и восстановления нужен доступ к App Store через интернет. Откройте «О приложении → Доступ → Восстановить покупки» с тем Аккаунтом Apple, который использовался для покупки.\n\nИгры и история хранятся на этих часах. В приложении нет переноса между часами, облачной синхронизации или сервиса резервного копирования. При удалении приложения или смене часов локальные данные могут быть потеряны. Американо — это счёт вашего раунда без расписания турнира и общей таблицы.\n\nНужны Apple Watch с watchOS 10 или новее. Интерфейс на русском языке. Без рекламы.\n\nКонфиденциальность: https://padel-score-wrist.pages.dev/ru/privacy/\nУсловия: https://padel-score-wrist.pages.dev/ru/terms/\n\nНА IPHONE\nНачните с краткого руководства, попробуйте интерактивные демо «Матч» и «Американо», оформите или восстановите пожизненный доступ. Реальные игры ведутся на Apple Watch, которые работают самостоятельно. Демо доступны без интернета и не расходуют бесплатные игры. Используйте один Аккаунт Apple на обоих устройствах; история и счётчик бесплатных игр остаются на часах. Компаньон для iPhone требует iOS 17 или новее.",
  "keywords": "падел,табло,подача,очки,история,отмена,тайбрейк,watch",
  "iapName": "Бессрочный доступ",
  "iapDescription": "Матчи и американо без ограничений. Один платёж.",
  "evergreenPromotionalText": "Счёт и следующий подающий — с первого взгляда. Ведите матчи и американо на Apple Watch, отменяйте случайные нажатия и смотрите историю игр.",
  "headline": "Ваша игра.\nОдним взглядом.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/ru/",
  "supportUrl": "https://padel-score-wrist.pages.dev/ru/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/ru/privacy/"
}
```

### sv

SHA256: `c97541939affc5c9087b56066f3354c3b2662dc1a15df8fa8fc72d861fa9387f`

```json
{
  "name": "Padel Score — Wrist",
  "subtitle": "Poängräknare på din Watch",
  "promotionalText": "Poängen och nästa servare med en blick. Räkna Match och Americano på Apple Watch, ångra ett tryck och se dina tidigare resultat.",
  "description": "Fokusera på spelet.\n\nSe ställningen och nästa servare med en blick. Tryck på ett lag efter varje boll, använd Ångra om du tryckt fel och fortsätt räkna offline på din Apple Watch. Klockan fungerar självständigt. Inget konto behövs.\n\nUNDER SPELET\n• Match: game och set, med tiebreak vid 6–6.\n• Välj Golden point, En fördel eller Fördel vid lika.\n• Bekräfta serveordningen inför varje nytt set.\n• Americano: räkna poäng i din egen omgång med ett gemensamt totalantal bollar och antal servar per spelare.\n• Se lagens poäng, bollar kvar och nästa servare.\n• Ångra ett tryck eller rätta ställningen och serveordningen.\n• Återgå till ditt sparade spel efter att ha stängt appen.\n\nEFTER SPELET\n• Läs avslutade setresultat och eventuellt oavslutat set. Avsluta en Match när du vill.\n• Se slutpoängen i en Americano-omgång, även vid oavgjort eller avslut i förtid.\n• Välj Spela igen från det senaste resultatet för att använda samma regler och serveordning. Kontrollera vem som servar först innan du startar.\n• Se alla avslutade spel i lokal Historik med datum och detaljerade resultat. Historiken är gratis, även efter gränsen på fem spel.\n\nPROVA PÅ KLOCKAN\nProva poängtavlan öppnar ett förinställt matchexempel märkt Demo. Tryck, ångra eller återställ utan att påverka dina spel eller använda ett gratisspel. Exemplet slutar efter ett game, inte en hel match.\n\nLägg till Padel Score på en kompatibel urtavla eller i Smart trave för att öppna appen snabbt. Genvägen öppnar appen och visar ingen liveställning.\n\nFEM GRATISSPEL\nDe första fem avslutade riktiga spelen är automatiskt gratis. Därefter ger ett engångsköp för permanent åtkomst obegränsat antal nya spel. Ditt pågående spel, senaste resultat, historik och demo är tillgängliga även utan köp. Att radera lokala speldata nollställer inte antalet avslutade spel.\n\nKöp och återställning av köp kräver en internetanslutning till App Store. Använd Om → Åtkomst → Återställ köp med det Apple-konto du köpte med.\n\nSpel och historik sparas lokalt på den här klockan. Appen saknar överföring mellan klockor, molnsynkronisering och molnsäkerhetskopiering. Lokala data kan gå förlorade om du tar bort appen eller byter klocka. Americano räknar poäng i din egen omgång, utan turneringsschema eller tabell.\n\nKräver Apple Watch med watchOS 10 eller senare. Svenskt gränssnitt. Inga annonser.\n\nIntegritet: https://padel-score-wrist.pages.dev/sv/privacy/\nVillkor: https://padel-score-wrist.pages.dev/sv/terms/\n\nPÅ DIN IPHONE\nKom igång med en kort guide, prova interaktiva demonstrationer av Match och Americano och köp eller återställ livstidsåtkomst. Riktiga matcher räknas på Apple Watch, som fungerar självständigt. Demonstrationerna fungerar utan internet och använder inga gratismatcher. Använd samma Apple-konto på båda enheterna; historiken och räknaren för gratismatcher stannar på klockan. iPhone-appen kräver iOS 17 eller senare.",
  "keywords": "poängtavla,americano,match,serve,tiebreak,dubbel,historik,ångra,offline",
  "iapName": "Permanent åtkomst",
  "iapDescription": "Obegränsat antal Match- och Americano-spel.",
  "evergreenPromotionalText": "Poängen och nästa servare med en blick. Räkna Match och Americano på Apple Watch, ångra ett tryck och se dina tidigare resultat.",
  "headline": "Ditt spel.\nMed en blick.",
  "marketingUrl": "https://padel-score-wrist.pages.dev/sv/",
  "supportUrl": "https://padel-score-wrist.pages.dev/sv/support/",
  "privacyPolicyUrl": "https://padel-score-wrist.pages.dev/sv/privacy/"
}
```
