from pathlib import Path
import json,hashlib
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle
from pypdf import PdfReader
root=Path(__file__).resolve().parents[4];assets=root/'AI/store-assets/m25'
m=json.loads((assets/'manifest.json').read_text())
assert m['source_sha']=='8eeec63f5287639b86e637803b436b005a6901da','new build8 captures required'
for row in m['locales']['en-US']['watch']:
 assert hashlib.sha256((assets/row['file']).read_bytes()).hexdigest()==row['sha256']
golden_meta=json.loads((root/'AI/store-assets/m33-review/golden-point-provenance.json').read_text())
assert golden_meta['source_sha']==m['source_sha']
assert hashlib.sha256((root/'AI/store-assets/m33-review/golden-point.png').read_bytes()).hexdigest()==golden_meta['sha256']
out=root/'AI/store-assets/m33-review/review-guide.pdf'
c=canvas.Canvas(str(out),pagesize=(595.28,841.89));c.setTitle('Padel Score - Wrist | Build 1.0 (8) review guide');c.setAuthor('Dzmitry Dziachenka')
body=ParagraphStyle('body',fontName='Helvetica',fontSize=10.5,leading=14,textColor=HexColor('#18201a'))
small=ParagraphStyle('small',parent=body,fontSize=8.5,leading=11)
def para(text,x,y,w=515,style=body):
 p=Paragraph(text,style);_,h=p.wrap(w,750);assert y-h>42,(text,y,h);p.drawOn(c,x,y-h);return y-h

def header(n,title,subtitle):
 c.setFillColor(HexColor('#101110'));c.rect(0,755,596,87,fill=1,stroke=0)
 c.setFillColor(HexColor('#DCF79B'));c.setFont('Helvetica-Bold',21);c.drawString(40,800,title)
 c.setFillColor(HexColor('#FFFFFF'));c.setFont('Helvetica',10);c.drawString(40,776,subtitle)
 c.setFillColor(HexColor('#555555'));c.setFont('Helvetica',8);c.drawString(40,25,'App 6825393194 | Version 1.0 (8) | Native Simulator screenshots');c.drawRightString(555,25,f'{n} / 4')

def images(names,captions):
 for i,(name,caption) in enumerate(zip(names,captions)):
  x=40+176*i;c.drawImage(str(assets/'en-US/watch'/name),x+14,478,width=136,height=165.56)
  para(caption,x,464,160,small)

header(1,'Know where to serve next','R and L describe the next rally, from the server facing the net.')
para('The side is shown beside the next server on Watch, in demos and in correction previews. L/R letters stay the same in every app language; VoiceOver speaks the full translated side name.',40,730)
for i,(name,caption) in enumerate([('01-gesture.png','R: serve from the right'),('06-americano.png','L: serve from the left')]):
 x=40+176*i;c.drawImage(str(assets/'en-US/watch'/name),x+14,478,width=136,height=165.56);para(caption,x,464,160,small)
c.drawImage(str(root/'AI/store-assets/m33-review/golden-point.png'),406,478,width=136,height=165.56)
para('L/R: receivers choose',392,464,160,small)
y=para('<b>Match:</b> Each ordinary game starts R, then alternates by points played. Deuce is R and advantage is L. Tie-breaks alternate by total points, independently of server changes.',40,425)
y=para('<b>Golden point:</b> Both deciding-point rules show L/R and Receivers’ choice. The app does not select or predict the receivers’ decision.',40,y-14)
y=para('<b>Americano:</b> Every server starts each service block on R, then alternates within it. This is the app’s stated convention, including odd-length blocks; it is not a claim of one universal tournament rule.',40,y-14)
y=para('<b>Try it:</b> Open Watch About > Try the scoreboard or iPhone Demo > Match. The example starts 40-30 with L. Award THEM for golden point and L/R; Undo restores L. On iPhone Demo > Americano, start at 10-10/R and score once for L. A new server’s block starts R again.',40,y-14)
y=para('<b>Recovery:</b> Undo, known-score starts and journal corrections derive the side from the accepted score and service position. Finished games and new sets awaiting serving confirmation show no side.',40,y-14)
para('The screenshots are unmodified native Simulator captures. They do not prove on-wrist readability, actual VoiceOver audio or physical gesture recognition.',40,y-17,style=small);c.showPage()

header(2,'Score either team with gestures','Real gameplay runs independently on Apple Watch. No sign-in required.')
para('Enable Gesture scoring in Match/Americano setup or the active game menu. The option is OFF for every new game. Native Double Tap requires a compatible Apple Watch, watchOS 11 or later and enabled system gestures; keep the playable score visible and screen awake.',40,730)
images(['01-gesture.png','02-opt-in.png','06-americano.png'],['Gesture-enabled live score','Explicit per-game opt-in','Also available in Americano'])
y=para('<b>1. Our point:</b> Touch your thumb and index finger together TWICE (one Double Tap series). Wait for Pending: US.',40,425)
y=para('<b>2. Opponents:</b> After Pending: US appears, repeat the series with TWO finger contacts. This selects THEM. A third recognized series cancels.',40,y-14)
y=para('<b>3. Save or cancel:</b> Exactly one rally saves at the fixed deadline five seconds after the first recognized series. Later series do not restart it. Leaving the score, lowering the wrist or opening an editor cancels pending input. Touch team buttons cancel it and score immediately.',40,y-14)
y=para('<b>Practice safely:</b> Use Try gestures from setup/menu. Practice changes no real score, saved history or free-game usage. The iPhone guide explicitly simulates input; it is not physical gesture recognition.',40,y-14)
para('These illustrations show actual Simulator UI, not a physical gesture video or a measured recognition-rate claim. Normal touch scoring remains available on watchOS 10 and later.',40,y-19,style=small);c.showPage()
header(3,'Recover from a late entry mistake','Correct an earlier rally while preserving subsequent recorded winners.')
para('On Watch, record at least three rallies. Open Game menu > Journal, select an earlier rally, and choose the appropriate correction. The active journal supports corrections after its latest checkpoint.',40,730)
images(['04-rally-correction.png','03-agreed-score.png','07-known-score.png'],['Preview a historical correction','Replace the agreed current score','Start at a known score'])
y=para('<b>Selective correction:</b> Change the winner, remove a duplicate, or insert a missing rally. Inspect Before/After score, serving and finish status. Later recorded winners remain in order; resolve serving explicitly when a changed set boundary requires it.',40,425)
y=para('<b>Apply once:</b> Confirm the preview to apply the change. One Undo restores the entire original record. Cancel or a save failure leaves the original intact.',40,y-14)
y=para('<b>Agree the current score:</b> Game menu > Edit score replaces the current situation and creates a checkpoint. It does not invent earlier rallies or rewrite unknown history.',40,y-14)
y=para('<b>Join a game already underway:</b> In Match/Americano setup choose Starting score > Current score. Enter a valid continuable score and explicit serving, review, then start. Undo stops at that starting checkpoint.',40,y-14)
para('Detailed archived journals are read-only. Older records without rally detail say that the detail is unavailable. On iPhone Start, the correction and known-score examples are disposable demonstrations.',40,y-17,style=small);c.showPage()
header(4,'Play until your court time ends','Unrestricted Match sets, your own Americano round and local history.')
para('Match has no preset one-set or best-of-three finish. Continue playing sets and finish manually when you choose. Results retain the actual set scores and any incomplete set; the app does not invent an overall winner.',40,730)
images(['05-sets.png','06-americano.png','08-history.png'],['Multiple completed sets','Shared rally total and next server','Local finished-game history'])
y=para('<b>Americano:</b> Select the combined rally total and rallies per server. Service blocks advance with recorded rallies, regardless of which team wins. The app covers your own round, not tournament scheduling or standings.',40,425)
y=para('<b>Access:</b> The first five completed real games are free. After that, one lifetime non-consumable unlocks new games; there is no subscription. Current game, latest result, history and practice remain accessible. Watch About > Access and iPhone Access provide purchase/restore using the same Apple Account.',40,y-14)
y=para('<b>Privacy:</b> Real games, names and journals stay locally on Watch. No sign-in, analytics, HealthKit, location collection or cloud sync is required. Purchase/restore and external links need a network.',40,y-14)
y=para('<b>Development provenance:</b> <link href="https://github.com/ddziachenka/padel-score-wrist">github.com/ddziachenka/padel-score-wrist</link><br/>The public repository preserves earlier development history. This build 8 candidate remains local. Neither the source history nor these workflows establish worldwide exclusivity.',40,y-14)
para('Capture source: '+m['source_sha']+'. Illustrations are original XCTest screenshots with recorded hashes and attachments. This local guide describes build 8; it is not a physical-device test record.',40,y-17,style=small)
c.save();r=PdfReader(out);assert len(r.pages)==4
for page in r.pages:assert len(page.extract_text())>800
print(json.dumps({'path':str(out),'pages':4,'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'capture_source':m['source_sha']}))
