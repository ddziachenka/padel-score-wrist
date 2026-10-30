#!/usr/bin/env python3
"""Import M25's original XCTest PNG bytes, never reconstructed or rescaled UI."""
import argparse,hashlib,json,re,struct,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
ASSETS=ROOT/'AI/store-assets/m25'
LOCALES=[('en-US','en','en_US',''),('es-ES','es','es_ES','es'),('es-MX','es','es_MX','es'),('it','it','it_IT','it'),('fr-FR','fr','fr_FR','fr'),('pt-PT','pt-PT','pt_PT','pt-pt'),('pt-BR','pt-BR','pt_BR','pt-br'),('nl-NL','nl','nl_NL','nl'),('de-DE','de','de_DE','de'),('sv','sv','sv_SE','sv'),('da','da','da_DK','da'),('fi','fi','fi_FI','fi'),('no','nb','nb_NO','nb'),('ru','ru','ru_RU','ru')]
WATCH=['01-gesture','02-opt-in','03-agreed-score','04-rally-correction','05-sets','06-americano','07-known-score','08-history']
PHONE=['01-gesture-simulation','02-rally-correction','03-known-score','04-start','05-match-demo','06-americano-demo','07-access']
parser=argparse.ArgumentParser();parser.add_argument('--watch-run',required=True);parser.add_argument('--phone-run',required=True);args=parser.parse_args()
def digest(data):return hashlib.sha256(data).hexdigest()
def read_run(name,count):
 p=ROOT/'.artifacts/M25'/name
 summary=json.loads(Path(str(p)+'-summary.json').read_text())
 assert summary['result']=='Passed' and summary['totalTestCount']==count
 assert all(summary[k]==0 for k in ['failedTests','skippedTests','expectedFailures'])
 assert not summary.get('runtimeWarnings')
 source=Path(str(p)+'-source.txt').read_text().strip();assert re.fullmatch('[0-9a-f]{40}',source)
 context=json.loads(Path(str(p)+'-context.json').read_text())
 attachments=json.loads(Path(str(p)+'-attachments/manifest.json').read_text())
 (ASSETS/'provenance'/f'{name}-attachments.json').write_text(json.dumps(attachments,ensure_ascii=False,indent=2)+'\n')
 (ASSETS/'provenance'/f'{name}-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
 return {'prefix':p,'source_sha':source,'context':context,'attachments':attachments,'result_bundle':str(p.relative_to(ROOT))+'.xcresult'}
w=read_run(args.watch_run,14);p=read_run(args.phone_run,2)
assert w['source_sha']==p['source_sha'],'freeze source for both gallery runs'
manifest={'schema':'m25-store-materials/1','status':'LOCAL_DRAFT_PENDING_M29','source_sha':w['source_sha'],'hardware_claims':'PENDING_M29; no publication/submission authorization','watch_order':WATCH,'phone_order':PHONE,'creative_order':['header','search'],'capture_kind':'native-xcuiscreen-unmodified','source_app_inputs':{},'runs':{},'locales':{}}
for kind,r in [('watch',w),('phone',p)]:
 name=args.watch_run if kind=='watch' else args.phone_run
 manifest['runs'][kind]={'source_sha':r['source_sha'],'result_bundle':r['result_bundle'],'context':r['context'],'attachments':f'provenance/{name}-attachments.json','summary':f'provenance/{name}-summary.json'}
# Only shipping App inputs determine rendered UI. Test source SHA remains recorded
# separately. No broad input exclusion applies to milestone or release validation.
files=subprocess.check_output(['git','ls-tree','-r','--name-only',w['source_sha'],'App'],cwd=ROOT,text=True).splitlines()
for name in files:
 if '/PadelScoreWatchTests/' in name or '/PadelScoreWatchUITests/' in name or '/PadelScorePhoneTests/' in name or '/PadelScorePhoneUITests/' in name or '/PadelScoreStoreKitTests/' in name:continue
 data=subprocess.check_output(['git','show',w['source_sha']+':'+name],cwd=ROOT)
 manifest['source_app_inputs'][name]=digest(data)
def capture(r,prefix,dest,dimensions,kind,fixture,actions):
 matches=[(t,a) for t in r['attachments'] for a in t['attachments'] if a['suggestedHumanReadableName'].startswith(prefix+'_') and a['exportedFileName'].endswith('.png')]
 assert len(matches)==1,(prefix,len(matches))
 t,a=matches[0];assert not a['isAssociatedWithFailure']
 assert a['deviceId']==r['context']['udid']
 data=(Path(str(r['prefix'])+'-attachments')/a['exportedFileName']).read_bytes()
 assert data[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',data[16:24])==dimensions
 path=ASSETS/dest;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data)
 return {'file':dest,'sha256':digest(data),'dimensions':list(dimensions),'capture_kind':kind,'attachment':a['exportedFileName'],'attachment_name':a['suggestedHumanReadableName'],'timestamp':a['timestamp'],'device_udid':a['deviceId'],'test':t['testIdentifier'],'fixture':fixture,'actions':actions,'source_sha':r['source_sha'],'result_bundle':r['result_bundle']}
fixtures=['gestureMatch','empty','storeMatch','matchStart + U,T,U','storeResult','storeAmericano','lastSettings + known-score UI','storeHistory']
actions=['launch enabled score; simulate a native activation, settle and Undo after capture','setup Match; assert OFF, toggle ON then OFF; capture','menu Edit score → Points; no saved replacement','three ordinary rallies; journal rally2 → change winner; scroll After; apply and whole Undo after capture','launch saved three-set Match; no overall-winner assertion','launch 13–10 of32; actual serving follows engine','normal setup Current score; enter1–0 games and Partner serving; review; start after capture, Undo unavailable','open local History with three fixed records']
for loc,lang,region,route in LOCALES:
 row={'language':lang,'region':region,'site_route':route,'watch':[],'phone':[],'creative':[]}
 for i,story in enumerate(WATCH):
  shot=capture(w,f'm25-watch-{region}-{story}',f'{loc}/watch/{story}.png',(368,448),'native-xcuiscreen-unmodified',fixtures[i],actions[i]);row['watch'].append(shot)
  # Both Spanish store locales have dedicated original captures. The ES route uses ES.
  if loc!='es-MX':
   web=ROOT/'Web/public/images/m25'/route/(story+'.png');web.parent.mkdir(parents=True,exist_ok=True);web.write_bytes((ASSETS/shot['file']).read_bytes())
 for i,story in enumerate(PHONE):
  if i<3:prefix=f'm25-phone-{region}-{story}';fixture='isolated in-memory guide';action='Start → '+story+'; actual input/preview, no real scoring'
  else:
   old=['01-start','02-match','03-americano','04-access'][i-3];prefix=f'{region}-{old}';fixture='StoreKit-verified lifetime + isolated demos';action='actual '+old+'; permanent owned Access, no temporary price'
  row['phone'].append(capture(p,prefix,f'{loc}/phone/{story}.png',(1320,2868),'native-xcuiscreen-unmodified',fixture,action))
 manifest['locales'][loc]=row
(ASSETS/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print('Imported112 Watch and98 phone native captures with complete provenance; creative composition follows')
