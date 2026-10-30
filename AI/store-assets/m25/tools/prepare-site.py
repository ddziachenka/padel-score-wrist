#!/usr/bin/env python3
"""Prepare localized static drafts from approved copy and original native captures."""
from pathlib import Path
import json,re,html
ROOT=Path(__file__).resolve().parents[4]
ASSETS=ROOT/'AI/store-assets/m25'
manifest=json.loads((ASSETS/'manifest.json').read_text())
feature=json.loads((ASSETS/'feature-copy.json').read_text())
watch=json.loads(next((ROOT/'App/PadelScoreWatch').rglob('Localizable.xcstrings')).read_text())
phone=json.loads((ROOT/'App/PadelScorePhone/Localizable.xcstrings').read_text())
def tr(key,lang,catalog=watch):
 if lang=='en':return key if not key.startswith('phone.') else catalog['strings'][key]['localizations']['en']['stringUnit']['value']
 return catalog['strings'][key]['localizations'][lang]['stringUnit']['value']
def esc(s):return html.escape(s,quote=True)
privacy={
'en':'Optional player names, detailed rally journals, correction checkpoints and the current game’s gesture-scoring preference are stored locally on Watch. A pending gesture selection stays only in memory until an ordinary rally is saved. Watch practice and iPhone simulations use memory only and do not send game data.',
'es':'Los nombres opcionales, los diarios de puntos, los límites de corrección y la preferencia de gestos de la partida actual se guardan localmente en el Watch. Una selección por gestos pendiente permanece en memoria hasta guardar un punto normal. La práctica del Watch y las simulaciones del iPhone solo usan memoria y no envían datos de partidas.',
'it':'I nomi facoltativi, i diari degli scambi, i punti di controllo delle correzioni e la preferenza dei gesti della partita attuale sono salvati localmente sul Watch. Una selezione in attesa resta solo in memoria fino al salvataggio di uno scambio normale. La pratica sul Watch e le simulazioni su iPhone usano solo la memoria e non inviano dati delle partite.',
'fr':'Les noms facultatifs, les journaux des échanges, les points de contrôle des corrections et le réglage des gestes de la partie en cours sont stockés localement sur la Watch. Une sélection en attente reste en mémoire jusqu’à l’enregistrement d’un échange ordinaire. L’entraînement sur Watch et les simulations sur iPhone utilisent uniquement la mémoire et n’envoient aucune donnée de partie.',
'pt-PT':'Os nomes opcionais, os registos dos pontos, os pontos de controlo das correções e a preferência de gestos da partida atual são guardados localmente no Watch. Uma seleção pendente fica apenas na memória até se guardar um ponto normal. A prática no Watch e as simulações no iPhone usam apenas a memória e não enviam dados de partidas.',
'pt-BR':'Os nomes opcionais, os registros de pontos, os pontos de controle das correções e a preferência de gestos da partida atual ficam salvos localmente no Watch. Uma seleção pendente fica só na memória até salvar um ponto normal. A prática no Watch e as simulações no iPhone usam apenas a memória e não enviam dados das partidas.',
'nl':'Optionele spelersnamen, rallylogboeken, correctiecontrolepunten en de gebarenvoorkeur van de huidige partij worden lokaal op Watch opgeslagen. Een wachtende selectie blijft alleen in het geheugen totdat een gewone rally wordt opgeslagen. Oefenen op Watch en simulaties op iPhone gebruiken alleen het geheugen en versturen geen partijgegevens.',
'de':'Optionale Spielernamen, Ballwechselprotokolle, Korrektur-Kontrollpunkte und die Gesteneinstellung der laufenden Partie werden lokal auf der Watch gespeichert. Eine ausstehende Auswahl bleibt nur im Arbeitsspeicher, bis ein normaler Ballwechsel gespeichert wird. Watch-Übung und iPhone-Simulationen nutzen nur den Arbeitsspeicher und senden keine Spieldaten.',
'sv':'Valfria spelarnamn, bollistor, kontrollpunkter för rättelser och den aktuella matchens gestinställning sparas lokalt på Watch. Ett väntande val finns bara i minnet tills en vanlig boll sparas. Övning på Watch och simuleringar på iPhone använder bara minnet och skickar inga matchdata.',
'da':'Valgfrie spillernavne, boldjournaler, kontrolpunkter for rettelser og den aktuelle kamps gestusindstilling gemmes lokalt på Watch. Et afventende valg findes kun i hukommelsen, indtil en almindelig bold gemmes. Øvelse på Watch og simuleringer på iPhone bruger kun hukommelsen og sender ingen kampdata.',
'fi':'Valinnaiset pelaajanimet, pallorallipäiväkirjat, korjausten tarkistuspisteet ja nykyisen pelin eleasetus tallennetaan paikallisesti Watchiin. Odottava valinta on vain muistissa, kunnes tavallinen palloralli tallennetaan. Watch-harjoittelu ja iPhone-simulaatiot käyttävät vain muistia eivätkä lähetä pelitietoja.',
'nb':'Valgfrie spillernavn, ballvekslingslogger, kontrollpunkter for rettelser og gestinnstillingen for den aktuelle kampen lagres lokalt på Watch. Et ventende valg finnes bare i minnet til en vanlig ballveksling lagres. Øving på Watch og simuleringer på iPhone bruker bare minnet og sender ingen kampdata.',
'ru':'Необязательные имена игроков, журналы розыгрышей, границы коррекций и настройка жестов текущей игры хранятся локально на Watch. Ожидающий выбор команды остаётся только в памяти до сохранения обычного розыгрыша. Практика на Watch и симуляции на iPhone работают только в памяти и не передают данные игр.'}
for loc,row in manifest['locales'].items():
 if loc=='es-MX':continue
 lang=row['language'];route=row['site_route'];folder=ROOT/'Web/public'/route;path=folder/'index.html';s=path.read_text();f=feature[lang]
 title=re.search(r'<h1[^>]*>(.*?)</h1>',s,re.S).group(1)
 meta=re.search(r'<p class="meta">(.*?)</p>',s,re.S).group(1).replace('12 languages','13 languages')
 availability=re.search(r'<p class="availability">.*?</p>',s,re.S).group(0)
 purchase=re.search(r'<section class="notice purchase".*?</section>',s,re.S).group(0)
 links=re.search(r'<ul class="card-links">.*?</ul>',s,re.S).group(0)
 iphone=re.search(r'<section aria-label="iPhone">.*?</section>',s,re.S).group(0)
 captions=[tr('Gesture scoring',lang),tr('Optional. Off for every new game.',lang),tr('Edit score',lang),tr('After',lang),tr('Match',lang),tr('Americano',lang),tr('Current score',lang),tr('History',lang)]
 def figure(i,lazy=True):
  name=Path(row['watch'][i]['file']).name;url='/images/m25/'+(route+'/' if route else '')+name
  alts=[captions[0]+' · '+tr('US',lang)+' 0 · '+tr('THEM',lang)+' 0',captions[1],captions[2]+' · 30–15',tr('Change winner',lang)+' · '+captions[3]+' · 40–0',captions[4]+' · 6–4, 4–6, 6–3',captions[5]+' · 13–10',captions[6]+' · '+tr('Games',lang)+' 1–0',captions[7]+' · '+tr('Match',lang)+' · '+tr('Americano',lang)]
  alt=alts[i];loading=' loading="lazy"' if lazy else ''
  return f'<figure><img src="{url}" width="368" height="448"{loading} alt="{esc(alt)}"><figcaption>{esc(captions[i])}</figcaption></figure>'
 body=f'''<main id="main" tabindex="-1" class="shell document landing">
<section class="hero" aria-labelledby="hero-title"><div><p class="eyebrow">Padel Score — Wrist · Apple Watch</p><h1 id="hero-title">{title}</h1><p class="lede">{esc(f['heading'])}</p><p>{esc(tr('Optional. Off for every new game.',lang))}</p>{availability}<p class="meta">{meta}</p></div>{figure(0,False)}</section>
<section aria-labelledby="gesture-title"><h2 id="gesture-title">{esc(f['heading'])}</h2><p>{esc(f['gesture'])}</p><div class="screens">{figure(1)}</div></section>
<section aria-labelledby="recovery-title"><h2 id="recovery-title">{esc(tr('phone.recovery.heading',lang,phone))}</h2><p>{esc(f['recovery'])}</p><div class="screens">{figure(2)}{figure(3)}</div></section>
<section aria-labelledby="formats-title"><h2 id="formats-title">{esc(tr('Match',lang))} · {esc(tr('Americano',lang))}</h2><div class="screens">{figure(4)}{figure(5)}{figure(6)}{figure(7)}</div></section>
{purchase}{links}{iphone}</main>'''
 s=re.sub(r'<main\b.*?</main>',lambda _:body,s,count=1,flags=re.S);path.write_text(s)
 for page in ['support','privacy']:
  target=folder/page/'index.html';text=target.read_text()
  if page=='support':addition=f'<section data-m25="recovery"><h2>{esc(f["heading"])}</h2><p>{esc(f["gesture"])}</p><h3>{esc(tr("phone.recovery.heading",lang,phone))}</h3><p>{esc(f["recovery"])}</p></section>'
  else:
   addition=f'<section data-m25="local-data"><h2>{esc(tr("Gesture scoring",lang))}</h2><p>{esc(privacy[lang])}</p></section>'
   # A numeric ISO date is unambiguous in every supported language.
   text=re.sub(r'(<p class="meta">)(.*?)(</p>)',lambda m:m[1]+m[2].split(':')[0]+': 2026-10-30'+m[3],text,count=1,flags=re.S)
  text=re.sub(r'<section data-m25="(?:recovery|local-data)">.*?</section>','',text,flags=re.S)
  text=text.replace('</main>',addition+'</main>',1);target.write_text(text)
print('Prepared13 localized landing/support/privacy drafts; retained purchase/legal terms and native original screenshot bytes')
