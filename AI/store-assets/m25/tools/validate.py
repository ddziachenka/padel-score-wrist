#!/usr/bin/env python3
"""Strict portable provenance checks for all active M25 galleries."""
from pathlib import Path
from html.parser import HTMLParser
import hashlib,json,re,struct,subprocess
ROOT=Path(__file__).resolve().parents[4];ASSETS=ROOT/'AI/store-assets/m25'
LOCALES=['en-US','es-ES','es-MX','it','fr-FR','pt-PT','pt-BR','nl-NL','de-DE','sv','da','fi','no','ru']
WATCH=['01-gesture','02-opt-in','03-agreed-score','04-rally-correction','05-sets','06-americano','07-known-score','08-history']
PHONE=['01-gesture-simulation','02-rally-correction','03-known-score','04-start','05-match-demo','06-americano-demo','07-access']
def sha(data):return hashlib.sha256(data).hexdigest()
def safe(relative):
 path=ASSETS/relative
 assert not path.is_symlink() and '..' not in Path(relative).parts and not Path(relative).is_absolute(),relative
 assert path.resolve().is_relative_to(ASSETS.resolve()),relative
 return path

def png(row,size):
 path=safe(row['file']);data=path.read_bytes()
 assert data[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',data[16:24])==size,row['file']
 assert row['dimensions']==list(size) and sha(data)==row['sha256'],row['file']
 assert data[25]==2,'opaque RGB PNG required'
 offset=8
 while offset<len(data):
  length=struct.unpack('>I',data[offset:offset+4])[0];kind=data[offset+4:offset+8]
  assert kind!=b'tRNS','no transparency chunk permitted';offset+=length+12
 assert offset==len(data)
 return data

class Images(HTMLParser):
 def __init__(self,s):super().__init__();self.images=[];self.feed(s)
 def handle_starttag(self,tag,attrs):
  if tag=='img':self.images.append(dict(attrs))
m=json.loads((ASSETS/'manifest.json').read_text())
assert m['schema']=='m25-store-materials/1' and m['capture_kind']=='native-xcuiscreen-unmodified'
assert m['status']=='LOCAL_DRAFT_PENDING_M29' and 'PENDING_M29' in m['hardware_claims']
assert list(m['locales'])==LOCALES and m['watch_order']==WATCH and m['phone_order']==PHONE
assert m['creative_order']==['header','search'] and re.fullmatch('[0-9a-f]{40}',m['source_sha'])
subprocess.run(['git','cat-file','-e',m['source_sha']+'^{commit}'],cwd=ROOT,check=True)
assert m['source_app_inputs'],'shipping source fingerprint required'
for file,digest in m['source_app_inputs'].items():
 assert file.startswith('App/') and '..' not in Path(file).parts
 assert sha((ROOT/file).read_bytes())==digest,('rendered shipping source changed',file)
exports={}
for kind,count in [('watch',14),('phone',2)]:
 run=m['runs'][kind];assert run['source_sha']==m['source_sha']
 summary=json.loads(safe(run['summary']).read_text());assert summary['result']=='Passed' and summary['totalTestCount']==count
 assert summary['passedTests']==count and all(summary[k]==0 for k in ['failedTests','skippedTests','expectedFailures']) and not summary.get('runtimeWarnings')
 assert run['context']['owner']==str(ROOT) and run['context']['udid']
 exports[kind]=json.loads(safe(run['attachments']).read_text())
 paths=set();native_count=creative_count=0
for loc,row in m['locales'].items():
 assert all(row.get(k) for k in ['language','region'])
 meta=json.loads((ASSETS/'metadata'/f'{loc}.json').read_text())
 assert len(meta['name'])<=30 and len(meta['subtitle'])<=30 and len(meta['keywords'].encode())<=100
 assert len(meta['description'])<=4000 and 0<len(meta['promotionalText'])<=170
 assert meta['promotionalText']==meta['evergreenPromotionalText']
 assert not any(x in meta['promotionalText'].lower() for x in ['launch offer','claim lifetime','free today'])
 for kind,order,size in [('watch',WATCH,(368,448)),('phone',PHONE,(1320,2868))]:
  assert [Path(v['file']).stem for v in row[kind]]==order
  for capture in row[kind]:
   assert Path(capture['file']).parent==Path(loc)/kind
   assert capture['source_sha']==m['source_sha'] and capture['capture_kind']=='native-xcuiscreen-unmodified'
   assert capture['result_bundle']==m['runs'][kind]['result_bundle']
   assert capture['device_udid']==m['runs'][kind]['context']['udid']
   assert all(capture.get(k) for k in ['fixture','actions','timestamp','attachment','attachment_name','test'])
   matching=[(t,a) for t in exports[kind] for a in t['attachments'] if a['exportedFileName']==capture['attachment']]
   assert len(matching)==1
   t,a=matching[0]
   assert t['testIdentifier']==capture['test'] and not a['isAssociatedWithFailure']
   assert a['suggestedHumanReadableName']==capture['attachment_name'] and a['timestamp']==capture['timestamp'] and a['deviceId']==capture['device_udid']
   data=png(capture,size);paths.add(safe(capture['file']));native_count+=1
   if kind=='watch' and loc!='es-MX':
    web=ROOT/'Web/public/images/m25'/row['site_route']/Path(capture['file']).name
    assert web.read_bytes()==data,('native site copy differs',web)
 for i,creative in enumerate(row['creative']):
  assert Path(creative['file']).stem==['header','search'][i] and Path(creative['file']).parent==Path(loc)/'creative'
  png(creative,[(3840,1646),(1920,1280)][i]);paths.add(safe(creative['file']));creative_count+=1
  assert sha(safe(creative['artwork']).read_bytes())==creative['artwork_sha256']
  assert creative['native_capture']==row['watch'][0]['file'] and creative['native_capture_sha256']==row['watch'][0]['sha256']
  assert creative['native_transform']['reconstruction'] is False and creative['hardware_claims']=='PENDING_M29'
  assert creative['text'] and all(t['text'] and t['lines'] and t['font_size']>=24 for t in creative['text'])
 assert len(row['creative'])==2
 if loc!='es-MX':
  images=Images((ROOT/'Web/public'/row['site_route']/'index.html').read_text()).images
  expected=['/images/m25/'+(row['site_route']+'/' if row['site_route'] else '')+Path(v['file']).name for v in row['watch']]
  assert [i['src'] for i in images]==expected and all(i.get('alt','').strip() for i in images)
assert set(ASSETS.glob('*/watch/*.png'))|set(ASSETS.glob('*/phone/*.png'))|set(ASSETS.glob('*/creative/*.png'))==paths
assert (native_count,creative_count)==(210,28)
print('M25 active materials:112 Watch +98 phone native captures,28 creatives,14 locales, exact shipping inputs/attachments/hashes/dimensions/opaque RGB/site copies verified')
