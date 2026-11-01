# M29 — scoped parallel material/copy review

**Policy status:** current
**Role:** separate parallel Reviewer, read-only source/material inspection
**Reviewed source:** `445859bde0740737ccd580ca0fb95dba429fb534`
**Baseline comparison:** `d92b9e9e9250e309a074953faa10ed4c06eddffb`
**Completed:** 2026-11-01T12:30:31Z
**Scope result:** no blocking finding in the reviewed copy/data flow

The working-tree change to StoreMaterialsUITests' obsolete wait is outside this
copy review and was preserved. No App, Config, Scripts, material, Git or device
mutation was performed. This record is not full native-material validation,
native-speaker certification, milestone verification or release approval.

## Checked

- Watch and phone have identical five-second rule, second-series cue and pending
  labels in all thirteen UI languages. Every cue quotes its own actual localized
  Pending: US label. One/two/third-series meanings and the definition of two
  thumb/index contacts per series remain coherent.
- All thirteen feature-copy gesture paragraphs contain only the approved timing
  change and explicit cue relative to the baseline. Headings and recovery copy
  are unchanged. The fourteen Store descriptions have precisely the same scoped
  change; all other metadata fields are baseline-identical, including neutral
  Promotional Text. Description maximum is German at3919/4000 characters.
- Name/subtitle/keyword-byte/Promotional Text/description limits pass for all
  fourteen metadata files. Spanish regional descriptions retain their prior
  differences while using the same UI-language rule/cue.
- New translations preserve five seconds, repeating two finger contacts after
  the first preview, and their-team intent. The exact quoted preview text matches
  the screen rather than an invented translated label. Some wording is literal,
  but no reviewed translation reverses teams, timing or gesture count.
- Composition joins the two approved localized rule/cue strings. It retains the
  existing24-point minimum, canvas/text boxes, original artwork and actual native
  capture transform. Marketing composites remain separate from unmodified native
  galleries. No guaranteed recognition/uniqueness or new data/permission claim is
  introduced; hardware claims remain PENDING_M29.

## Non-blocking clarity opportunity

**C1, P2:** `App/PadelScoreWatch/Features/Game/GestureScoringView.swift:97` and
`App/PadelScorePhone/PhoneGestureView.swift:19` say “Wait five seconds to save”
without expressly saying that the deadline starts at the **first** series and
does not restart after the second. Product/source define that fixed boundary
correctly. The following new cue materially improves sequencing, so this is not
a reason to interrupt the current source freeze. If later wording refinement is
needed, “Saved five seconds after the first series” would make the anchor explicit
and should propagate through the same catalog/material pipeline.

## Verification evidence

The following read-only assertion command exited **0**. Counts: thirteen exact
cross-platform localization sets, thirteen feature paragraphs, fourteen metadata
files and their field budgets; **no native test bundle** applies to this source
inspection.

```sh
python3 - <<'PY'
from pathlib import Path
import json,subprocess
base='d92b9e9e9250e309a074953faa10ed4c06eddffb'
assets=Path('AI/store-assets/m25')
old='One series: us. Two: them. Three: cancel. Wait three seconds to save.'
rules=old.replace('three seconds','five seconds')
cue='For THEM, wait for “Pending: US”, then repeat the series: two finger contacts.'
watch=json.loads(Path('App/PadelScoreWatch/Localizable.xcstrings').read_text())['strings']
phone=json.loads(Path('App/PadelScorePhone/Localizable.xcstrings').read_text())['strings']
oldwatch=json.loads(subprocess.check_output(['git','show',base+':App/PadelScoreWatch/Localizable.xcstrings']))['strings']
feature=json.loads((assets/'feature-copy.json').read_text())
oldfeature=json.loads(subprocess.check_output(['git','show',base+':AI/store-assets/m25/feature-copy.json']))
manifest=json.loads((assets/'manifest.json').read_text())
assert len(watch[cue]['localizations'])==13
for lang in watch[cue]['localizations']:
 for key in [rules,cue,'Pending: US','Pending: THEM']:
  assert watch[key]['localizations'][lang]==phone[key]['localizations'][lang],(lang,key)
 hint=watch[cue]['localizations'][lang]['stringUnit']['value']
 pending=watch['Pending: US']['localizations'][lang]['stringUnit']['value']
 assert pending in hint,lang
 after=watch[rules]['localizations'][lang]['stringUnit']['value']
 before=oldwatch[old]['localizations'][lang]['stringUnit']['value']
 assert feature[lang]['gesture']==oldfeature[lang]['gesture'].replace(before,after+' '+hint),(lang,'feature')
 assert feature[lang]['recovery']==oldfeature[lang]['recovery']
 assert feature[lang]['heading']==oldfeature[lang]['heading']
lengths=[]
for loc,row in manifest['locales'].items():
 p=assets/'metadata'/f'{loc}.json';cur=json.loads(p.read_text())
 previous=json.loads(subprocess.check_output(['git','show',base+':'+str(p)]))
 lang=row['language'];before=oldwatch[old]['localizations'][lang]['stringUnit']['value']
 after=watch[rules]['localizations'][lang]['stringUnit']['value'];hint=watch[cue]['localizations'][lang]['stringUnit']['value']
 assert previous['description'].count(before)==1
 assert cur['description']==previous['description'].replace(before,after+'\n'+hint),(loc,'description')
 assert {k:v for k,v in cur.items() if k!='description'}=={k:v for k,v in previous.items() if k!='description'},loc
 assert len(cur['description'])<=4000 and len(cur['name'])<=30 and len(cur['subtitle'])<=30 and len(cur['keywords'].encode())<=100 and len(cur['promotionalText'])<=170
 lengths.append((loc,len(cur['description'])))
print('PASS: 13 exact Watch/phone cue/rule/pending translation sets; each cue quotes its real first-preview label.')
print('PASS: 13 feature descriptions and 14 Store descriptions change only approved timing plus cue; all other metadata, recovery and headings unchanged.')
print('PASS: all 14 metadata field limits; max description',max(lengths,key=lambda x:x[1]))
PY
```

## Boundaries and next step

Fresh gallery originals, final creative/contact sheets and final image provenance
have **not** been visually approved here. The first new Watch capture is failed
evidence and cannot be imported; old images are not credited as build6 captures.
The root Builder owns the corrected complete captures, strict material/static
checks and full milestone gate. Final visual review can follow when those assets
are available. No external content was sent, uploaded or published.
