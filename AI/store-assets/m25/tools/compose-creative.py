#!/usr/bin/env python3
"""Deterministic artwork/native-capture layout; no generated or reconstructed UI."""
from pathlib import Path
import hashlib,json
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[4];ASSETS=ROOT/'AI/store-assets/m25'
m=json.loads((ASSETS/'manifest.json').read_text());watch=json.loads(next((ROOT/'App/PadelScoreWatch').rglob('Localizable.xcstrings')).read_text())
FONT='/System/Library/Fonts/SFNS.ttf'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def tr(key,lang):
 if isinstance(key,tuple):return ' '.join(tr(part,lang) for part in key)
 return key if lang=='en' else watch['strings'][key]['localizations'][lang]['stringUnit']['value']
def fit(draw,text,box,size,color):
 x,y,w,h=box
 for point in range(size,23,-1):
  font=ImageFont.truetype(FONT,point);lines=[];line=''
  for word in text.split():
   test=(line+' '+word).strip()
   if draw.textlength(test,font=font)>w and line:lines.append(line);line=word
   else:line=test
  if line:lines.append(line)
  spacing=round(point*.22);a,d=font.getmetrics();height=(a+d+spacing)*len(lines)
  if height<=h and all(draw.textlength(v,font=font)<=w for v in lines):break
 else:raise AssertionError(('text cannot fit',text,box))
 for line in lines:
  draw.text((x,y),line,font=font,fill=color);y+=a+d+spacing
 return {'text':text,'box':list(box),'font_size':point,'lines':lines}
art=ASSETS/'artwork/selected-hand.png'
for loc,row in m['locales'].items():
 lang=row['language'];shot=ASSETS/row['watch'][0]['file'];meta=json.loads((ASSETS/'metadata'/f'{loc}.json').read_text());row['creative']=[]
 for kind,W,H in [('header',3840,1646),('search',1920,1280)]:
  canvas=Image.new('RGB',(W,H),(15,16,17));draw=ImageDraw.Draw(canvas)
  if kind=='header':
   art_box=(1700,80,813,1220);shot_box=(2780,390,680,828)
   brand_box=(240,110,1330,80);title_box=(240,260,1330,300)
   promo_box=(240,580,1280,570);promo_size=64
   blocks=[('Optional. Off for every new game.',(240,1210,1280,140),54),('Requires watchOS 11 and an Apple Watch that supports Double Tap, with the screen awake and system gestures enabled.',(240,1390,3220,170),42)]
  else:
   art_box=(850,180,600,900);shot_box=(1470,530,340,414)
   brand_box=(120,100,1500,70);title_box=(120,235,730,220)
   promo_box=(120,490,700,500);promo_size=46
   blocks=[('Optional. Off for every new game.',(120,1020,700,100),36),('Requires watchOS 11 and an Apple Watch that supports Double Tap, with the screen awake and system gestures enabled.',(120,1140,1680,100),28)]
  ax,ay,aw,ah=art_box;canvas.paste(Image.open(art).convert('RGB').resize((aw,ah),Image.Resampling.LANCZOS),(ax,ay))
  sx,sy,sw,sh=shot_box;canvas.paste(Image.open(shot).convert('RGB').resize((sw,sh),Image.Resampling.LANCZOS),(sx,sy))
  # All localizable words are programmatically typeset, never baked into generated art.
  text=[fit(draw,'PADEL SCORE — WRIST',brand_box,44,'#F5F5F7'),fit(draw,tr('Gesture scoring',lang),title_box,112 if kind=='header' else 82,'#DCF79B')]
  text.append(fit(draw,meta['promotionalText'],promo_box,promo_size,'#F5F5F7'))
  for key,box,size in blocks:text.append(fit(draw,tr(key,lang),box,size,'#F5F5F7'))
  dest=ASSETS/loc/'creative'/f'{kind}.png';dest.parent.mkdir(parents=True,exist_ok=True);canvas.save(dest)
  row['creative'].append({'file':str(dest.relative_to(ASSETS)),'sha256':sha(dest),'dimensions':[W,H],'kind':'generated-artwork-plus-typeset-copy-and-original-ui','artwork':'artwork/selected-hand.png','artwork_sha256':sha(art),'native_capture':str(shot.relative_to(ASSETS)),'native_capture_sha256':sha(shot),'native_transform':{'resampling':'Lanczos','box':list(shot_box),'reconstruction':False},'artwork_box':list(art_box),'text':text,'hardware_claims':'PENDING_M29'})
 print(loc)
(ASSETS/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n')
