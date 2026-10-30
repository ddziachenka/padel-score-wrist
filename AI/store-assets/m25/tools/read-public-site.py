#!/usr/bin/env python3
"""Read-only public URL validation; never deploys local drafts."""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
from urllib.request import urlopen,Request
import hashlib,json,datetime
ROOT=Path(__file__).resolve().parents[4]
out=ROOT/'.artifacts/M25/live';out.mkdir(exist_ok=True,parents=True)
routes=['','es','it','fr','pt-pt','pt-br','nl','de','sv','da','fi','nb','ru']
def read(item):
 route,page=item;path='/'.join(x for x in [route,page] if x);url='https://padel-score-wrist.pages.dev/'+path+('/' if path else '')
 with urlopen(Request(url,headers={'User-Agent':'PadelScore-M25-read-only-validation'}),timeout=45) as response:
  data=response.read();status=response.status;final=response.url
 assert status==200 and b'<html' in data and b'Padel Score' in data,(url,status)
 name=(path.replace('/','-') or 'home')+'.html';(out/name).write_bytes(data)
 return {'url':url,'final_url':final,'status':status,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'saved':str((out/name).relative_to(ROOT))}
with ThreadPoolExecutor(max_workers=4) as pool: rows=list(pool.map(read,[(r,p) for r in routes for p in ['','privacy','terms','support']]))
(out/'readback.json').write_text(json.dumps({'observed_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'method':'GET only; local drafts not published','pages':rows},indent=2)+'\n')
print(f'Public site: {len(rows)} URLs returned200; source snapshots and hashes saved')
