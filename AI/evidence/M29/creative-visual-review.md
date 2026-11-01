# M29 — final creative visual review

**Policy status:** current
**Review type:** delegated visual inspection of local material derivatives
**Reviewed source:** `1367217b30ce0c5ffa2c464ea977786e28139439`; build 1.0 (6)
**Reviewed UTC:** 2026-11-01T13:27:22+00:00
**Result:** PASS for all 28 final compositions; no P0/P1 or required correction found.

## Exact reviewed set and method

All 14 final contact sheets `.artifacts/M29/contacts/creative-{ASC-locale}.jpg`
were individually opened with `view_image` at original detail. Each sheet contains
its header and search composition. These inspection JPEGs contain resized images
and gray unused canvas, rather than new Store deliverables. Original PNGs were
also opened for FI/NO/RU search, FR search and DE header to inspect dense localized
text, Cyrillic, two-line title and support-footnote spacing. The large DE header
was displayed by the viewer at 2048×878 from the 3840×1646 source; the file's
original dimensions and hash were verified separately.

The final PNGs are `AI/store-assets/m25/{ASC-locale}/creative/header.png`
(3840×1646) and `search.png` (1920×1280), opaque RGB. A read-only Python hash/
dimension/mode check exits 0 for all 28; each actual SHA256 equals the current
manifest, each referenced native capture/artwork hash matches, and native UI
reconstruction is false. The manifest also enumerates 112 Watch and 98 phone
originals from the two complete capture runs. Manifest SHA256 at this review:
`da131b14259221a234dd1eb2f8fb4c1e69b4c2537d69f0003a32e682bf7750cb`. Rule-plus-cue font range is 37–61 pt.

This is inspection of the local artwork/layout/text and final byte identity, not
physical gesture accuracy, measured hardware reliability, native-speaker
certification, an independent release audit, or publication/submission approval.
The [owner physical acceptance](owner-physical-acceptance.md), native gallery
reviews, strict material validator and full M29 gate have separate scopes.

## Visual result

Every locale preserves the same hierarchy: brand, lime gesture title, two-contact
series definition, one/two/three-series rule with five-second saving and the
localized first-preview cue, optional/OFF disclaimer, then supported-watchOS,
awake-screen and enabled-system-gesture qualifiers. The new rule and cue are fully
rendered with no truncation, overlapping blocks, artwork collision or missing
characters found. The original hand illustrates one pose; the adjacent instruction
explicitly says two contacts per series. It is not offered as filmed recognition
proof. The actual 0–0 Watch capture remains distinct from the artwork and supports
the app's native team colors/serving controls; no fictional Pending overlay or
reconstructed UI is introduced.

The search version has smaller supporting text than the header but stays readable
at native export size. The capability line fits below the optional statement;
FR/FI/RU optional text wraps to two lines with a visible gap before that line.
The NO search title intentionally wraps to two lines, remaining above its series
definition. Quoted preview labels may wrap across lines (for example EN header,
PT-PT and DA); their text is complete and no instruction is lost. ES-ES and ES-MX
use the same approved Spanish copy with separate native capture bytes and clock.
These are observed layout choices, not blocking findings or claims of complete
system accessibility coverage.

| Locale | Header and search visual result |
| --- | --- |
| en-US | PASS — complete five-second cue, two contacts, team/serving snapshot and qualifiers. |
| es-ES | PASS — long NOSOTROS preview/labels wrap cleanly; complete cue and qualifiers. |
| es-MX | PASS — separate native regional capture; same complete Spanish teaching. |
| it | PASS — four-line header rule/cue and search copy fit; NOI/LORO screenshot clear. |
| fr-FR | PASS — five-line search rule and two-line optional statement remain separated from footnote; original checked. |
| pt-PT | PASS — long quoted preview wraps without loss; source team/serving labels clear. |
| pt-BR | PASS — regional salvar/tela copy, complete preview cue and optional/OFF statement fit. |
| nl-NL | PASS — WIJ preview text and long capability line fit; hierarchy retained. |
| de-DE | PASS — long repeated-finger-contact rule and capability line fit; header original checked. |
| sv | PASS — complete five-second/VI preview cue; supporting lines stay separate. |
| da | PASS — wrapped OS preview remains complete; hand and DEM native frame separated. |
| fi | PASS — dense search rule and two-line optional statement fit with footnote gap; original checked. |
| no | PASS — two-line search title remains above definition; long repeat instruction and footnote fit; original checked. |
| ru | PASS — complete Cyrillic rule/cue and two-line optional statement, clean footnote gap; original checked. |

## Final PNG and inspection contact binding

Paths follow the locale patterns above; header/search hashes bind the deliverables,
not the JPEG previews. Contact hashes bind the exact sheets inspected. Any later
change to a PNG or its copy/transform requires corresponding revalidation.

| Locale | Header PNG SHA256 | Search PNG SHA256 | Creative contact JPG SHA256 |
| --- | --- | --- | --- |
| en-US | `202d19281dedbd9720b2384cdd2c815bcecca892969b41100794544a341d70ed` | `95c1d1b227cbc9a42fbb71307e5ecf6e5ad24f3f90d9e5dd1743ed57186fc950` | `eed9b572c51eb347dbf5f75e2f96c838f9ed944472882e2da2f4342926d16078` |
| es-ES | `9f223fcb4994229c2ecacfc4e9ae323e283c21df3d546f783e69a9f013599cd4` | `5ddb9dc1416c707fc82a0c92c9eb307021adbe48a1c6105c6a802383124903bd` | `99de5e13525605acfaea318b70d66aea1c250adbaad6f216fa6328fe387e9925` |
| es-MX | `0bd5c131ccac7b8a31687ed33af6d2922650edaf5ac4cb0e12536fcb34d04718` | `ac36466df4dd312494db22fbababf03ee393fa25764335cf05f473f2e24a7773` | `4e74d2890a3cde4a71c3a728bd367e460ad7d9823963f03c7a2dd464ef3f315b` |
| it | `7ad82a41c8356eec6a982530949becc217e998009a674fd39bc8bc6d7f7a4d25` | `cdb2385c09e6503ade3e42fbab07c9897544f03ae89c001da53b5c80c7a2d55c` | `ffa0ae27295b5b490deab3d4a4fd8620b3efce558eff42bc06e33048b43d100a` |
| fr-FR | `704d732274d0b004dcdc3268867d5d54390fe9c6fe9bed327b18df5828c9f09a` | `714d96d2cf2997771bf6ec96b77347d4a5b79e60ddd52154a5b0ee33931720b4` | `b85eacb0a34f5fbbc62d61b567dd4e324b9bf754671dc145ddbb1d59c94e91c1` |
| pt-PT | `5e85248ea1a2f0536f9fabea0c17486c96747582dcdeb79110e62897353ce40a` | `493c4e25f48b1282555fa3a1eeb913511a1fce32ce4c8d158368016a09a1e686` | `5196c9005ea8a8b8df08a00d533afd4706d1a45d581fdfc4300e7114c8ee3f6d` |
| pt-BR | `759fdea51ed48b1c55378d26846991d34c2fa8ede25ed92293aa5337a9cffeb4` | `85f36ffc66ca396b08d05d8f67bd785f4f5dab9b2d215c87437da3b8f833c557` | `37148306c35ed7c78f94e7c60b2bfca9660b235bfbcf173970947e326a1664a5` |
| nl-NL | `91aee87ecbfbf3844fca0953929924204f8b26cf0583eb37536edcf30877a418` | `1e67289ba83dcdf3a0dea58909cf8a3dc18750a7b05fb0a753295cc98329bf93` | `65a48d59bd4adea0fab256215768ffebaf918a50ca62167bd9336d296f17eecb` |
| de-DE | `541f5718f8384c6dcb4782991a437252b579e28301f6cecd7bbe0693b64dbba9` | `3a82c5f08c99615a0a2334aa2918f47fc74d72d9ccdcc38696b04146468df893` | `7cd996faae99c586cc43729ceda5029a7c0401d3538db1a2e6ae3849497713b3` |
| sv | `4326578f2139d6b644793ff18df0375714bc696e558277e4e2d6e9cb90c8ae25` | `c27ee30ab115168499cb9e6adf984260980f5831e442fe2febab5a69e6b35cd6` | `7898724c13ba9130ac3d7373ac16f312b1c7cd4d69365699097c22e017419846` |
| da | `dd3e726d5e5e7017198efbbd31f6cea280445e504e64086102d139460f5f6d63` | `9b9a10aa0457931df4ecb39d08d0940dc9808259ba8bc9846063465b58dae8da` | `91a76940605cc2a65f184787533b413fe77c8a4680d0ea12384c3d2adfa98a4b` |
| fi | `f29956b6808081fddfa6cf33d54530598ad040557d9eea522791b73313521a0f` | `15fa653e644f5c1a80f373e3ef605ec3a78f8eff0aad3bfe388f22e97f78057f` | `878515320aeca778c91952ff6ab4b2f62a95ae4eacd4d0e6c43e62452ec6cd5e` |
| no | `3d5b58d45eec9e6733a1802ee4a0c6de620d1f84d01f0dbecf74952d227a2f33` | `eb99eab0ba278494bda2e86fa0acd59d647991b9a9e9905235c17ac03197f90e` | `168520057f758363f42cc70710b781fc2ee2b037f86c68b42153a0e0e0598f9c` |
| ru | `a4af3badfd904e66100b29a764b43f382448a83e9a32151b006e95bed2816a16` | `80932673acf91c94ffeeb1b3823109e2da5f37e8d91d467065797f912b344f79` | `ea7ffcfbafef074a5f6dc50382e0593e341bff8de381816cd9bbc21e77c1bd0a` |

No image correction was required or performed by this reviewer. Current local
copy/material checks do not authorize distribution. Root Builder must complete
phone/browser/static/final gate evidence and record the final exact candidate.
