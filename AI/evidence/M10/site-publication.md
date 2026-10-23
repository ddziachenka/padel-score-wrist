# M10 — authorized site publication and production readback

Owner explicitly selected “Да, опубликовать подготовленный сайт (рекомендуется)” in this task after the public Privacy mismatch was explained. This authorization covers the existing prepared multilingual site; it does not authorize ASC changes, Archive, distribution or App Review.

`PATH=/Users/dima/.npm/_npx/c943b712072b77c4/node_modules/.bin:$PATH make site-deploy PRODUCTION=1`: exit 0. Cached Wrangler 4.128.0; no dependency installed or source changed by the CLI. Project `padel-score-wrist`, branch `main`, production origin https://padel-score-wrist.pages.dev; deployment https://cff74b31.padel-score-wrist.pages.dev. Log `.artifacts/M10-completion/site-deploy.log`. Website source is byte-identical to `c343c4ebb40d5f4e7f60c869ddc9410fa54d5a3f`; its content was prepared and verified by the localization stream.

Finding M10-R1: prior public Privacy said the latest result was replaced and the app was not a long-term archive, contradicting M13 local History. The already prepared policy now lists all finished-game history, retention until local deletion, and preserved free-game count/purchase. No new legal terms or collection were invented. This was fixed by the authorized publication, without product-source changes.

Post-deploy readback used `python3 .artifacts/M10-completion/check-live.py` (exit 0), fetching every tracked public file except Cloudflare's `_headers` configuration. 131/131 files: 52 HTML pages, 78 original PNGs, one stylesheet; HTTP 200 and SHA-256 identical to source. All localized public app/legal/support routes now exist. Terms in every locale retain the unchanged Apple Standard EULA link. Readback `.artifacts/M10-completion/live-readback.json`; original HTML/PNG bytes in `live-current/`.

The initial directory-based readback exited 1 only because it also enumerated ignored Finder `.DS_Store`; all 131 deployed files already matched. Wrangler does not publish that OS file. Original result preserved in `live-readback-including-os-metadata.json`. The authoritative recheck enumerates `git ls-files Web/public`, preserves all required pages/assets, and passes; no product check was loosened.

Initial web-reader access was unavailable; direct HTTPS curl readback succeeded. Before publication the three canonical public legal/support routes already returned HTTP 200, but Privacy had obsolete retention copy. The old content/hashes are preserved in `.artifacts/M10-completion/{privacy,terms,support}-live.html` and `live-site.json`.

Wrangler skill: `/Users/dima/.agents/skills/wrangler/SKILL.md`. Current CLI syntax cross-checked against https://developers.cloudflare.com/workers/wrangler/commands/pages/. No secrets or credentials printed.

## Verified production hashes

| Route | SHA-256 (source and live identical) |
| --- | --- |
| `/` | `e405cb1fcac148c8e084c92ddfe36554979da5e1dd7c5a68023dcdaee9d96ac9` |
| `/da/` | `a11ea72875e188634ca68ab172d34697b1c042cb701452f68d674ddad00f70dd` |
| `/da/privacy/` | `8dd71394974bc72e9bc05f0ec0ef937558a7cd92e8d2d69a8b03e015d47e48e0` |
| `/da/support/` | `9f92cba9207b9f81f01422816140c48cd7b1454070be84e68543472bb8412332` |
| `/da/terms/` | `2c14fdd70c6ef259573081997e487ab74a20cf360198f52f9af75473b7ffdd4d` |
| `/de/` | `07db581666a4203206610663ac85534b8209e5745ad0078bf77bbb248e8eb34e` |
| `/de/privacy/` | `0695e879fcba7d96d80f5cbcc4025edead94b136d17abcb5711da95479a299a1` |
| `/de/support/` | `2d8466640e55ba798e7ae2220dafef3fc47573e9623b9a3c5c0e072b6f0cb098` |
| `/de/terms/` | `c9b2ea3b96d6aec5f68f02b6fcd3b53d7be97dfce37ef21a48b1bda159bb93a2` |
| `/es/` | `a5c7d179b7e94d34a5b7c545bb14cd552339c30ed57103980a1253c90903cb14` |
| `/es/privacy/` | `abe3e75c5714f98c9092db764545e3a4906730b9dbdcca24b60ad5531020c19b` |
| `/es/support/` | `ef36ccac50d4e5a535ceea6987fac49b4bf863d3647e8fe53db3848bd82b89b5` |
| `/es/terms/` | `6f73f907b668f43acd4bb50194a38659ea82b6e23bc489f559453d8f22619ce6` |
| `/fi/` | `de6304bbe530ee77b525be10aaae94c5d0cb7e242d32890ec3dc1b66557114ae` |
| `/fi/privacy/` | `5802260adeac0381939cf841d725c6e45cc1a7cb630e7293080691f681d8d58d` |
| `/fi/support/` | `4b695bbd7f3108c17a366dd563d518b6f39242403d215d08b1276f880a33e0aa` |
| `/fi/terms/` | `6c5c74ae1ebdff0cb7dd0f96a99aa80c52abea113e9e43bc798b989587a6b429` |
| `/fr/` | `d210deddaf7710887c90a1099c47bda4e8b97353b8afd782316adaac1a61fd9b` |
| `/fr/privacy/` | `1370d020f71828d54ff38ed172ff403599730fe472f781fec27e8849231a4bcd` |
| `/fr/support/` | `4343641d7a61b9629fee4ca27f1210bd6d254f2e09694ae058516998f48e87d6` |
| `/fr/terms/` | `cd6358f62ca41e936543e750b44e1c83cec268539965a5f91970948b2c903923` |
| `/images/01-match.png` | `f8eb21f66383e53d0973e3209a5496d3fa1739fde8d54baa92cd3f007c80aa4a` |
| `/images/02-golden-point.png` | `b94697aa0489a5356f83456d59b30caf0f9a3bf418a0058bad76fcccc0050d57` |
| `/images/03-americano.png` | `e22287e25a80a175b6e34ce7afffa2ef4b3d3ea31985089c2f70a4b6f4c5a726` |
| `/images/04-edit-score.png` | `62f49e78b6e0a593f5ced5c5fc90af91eac9319a6210eebef2a523ad966320e6` |
| `/images/05-result.png` | `ababf0d07dd7820f66c10c1ee192e85a881c42d496c556acc872da4484c6fb4a` |
| `/images/06-history.png` | `4293526e11a5cd6b8d66a46fea3f8eaad2b4d5bcc8f399ca87d130e7213a22ec` |
| `/images/da/01-match.png` | `1cca2b35b6630b68c9e7c8a13dde0848651b3c7c8a24658aeb6461298087009e` |
| `/images/da/02-golden-point.png` | `61ecdaa4bff864a4d35322476cc8ff49804f92c18a19fbe7394cdd2abccd18d7` |
| `/images/da/03-americano.png` | `74e77e3b15d78a26f96b25d66d76858b16c7587d86c003264bc9f52c787e6c9d` |
| `/images/da/04-edit-score.png` | `68610da6111be0551d004ec9af0ed87cda967083808c5d2bb135e6953b567f3c` |
| `/images/da/05-result.png` | `d5a4e680b56ff27e17658f03404e7704d597f5da3be6fd06f2354ddd71650bd6` |
| `/images/da/06-history.png` | `c94cf9aa8dc1361ebccf0a2bf55d70f1967a93e273197f853ac8d804968749a1` |
| `/images/de/01-match.png` | `168276c723923f17f1e68a2d4631887b613ff8103de578927422327ef2200b2d` |
| `/images/de/02-golden-point.png` | `c51976eb6fc79a0c21e0d1775055f6927faab5960122cd06d95ab795d301653d` |
| `/images/de/03-americano.png` | `685b4d330c2935c08acacfd278ff99d266c52cc39fa8208c6c01c4139fea54c3` |
| `/images/de/04-edit-score.png` | `793ff1a42a50868bd222bcb28146a65505ae0ed00521dc870eb3399fd725d588` |
| `/images/de/05-result.png` | `e0c5ab4db78c8212ce934d851090b0a1e00600a42de1b748c26af49a6810780f` |
| `/images/de/06-history.png` | `27fa36ae3cf354f4a2454609c836b3da738b1d821b9146fab1de8cfffad7c51d` |
| `/images/es/01-match.png` | `c9cda22e6c51d5c66f1f55e4827b1b129ce0b68e1292cdf56aa67459dc55b52e` |
| `/images/es/02-golden-point.png` | `05a6d1bd019d8f7db2479e53b67e9264a2362ef2936995a252cd13d5279ed89c` |
| `/images/es/03-americano.png` | `f43acbbfdafe6dd184bf79e1242d43d2c48086f26455ed877a23111729c328c1` |
| `/images/es/04-edit-score.png` | `bbbe924d6cd0c8a8ddbc6eebb9428a6a1e171bc83076f98303b484d144bbd4af` |
| `/images/es/05-result.png` | `07b038a00f16e860b6f8e596785ef43822b3ea129c780d075979db5b0943d85b` |
| `/images/es/06-history.png` | `cc4ec9843221ebde96fd91b5b44a75610d75852d035976e213138f22d3ff3a9d` |
| `/images/fi/01-match.png` | `12bd3cdcd1e2bc6c958367ec7d2fca90d83a11ffb089c9c1678341c447df1f2c` |
| `/images/fi/02-golden-point.png` | `14f166f6c29cdcdc0b00250d3cf18f85365371d4a37116408116d2f742139444` |
| `/images/fi/03-americano.png` | `58ae4fb3d1ef4ca733cd77433facfade20d65a61bd70880f416f69cc9554a086` |
| `/images/fi/04-edit-score.png` | `90f4410019ebeb733b77ee07bf123724007c4b70ffb760d46881e0883acfadb1` |
| `/images/fi/05-result.png` | `bd425194396144d9b92c0b1545d84cdc7402078613b085900ebf1b683c04c0ab` |
| `/images/fi/06-history.png` | `6203256b4f664227f7fba06b420530d8b701ba125e4062ae056994153f81d11e` |
| `/images/fr/01-match.png` | `cfb8e6d693ca3feed4981775fec138f38ff709578cbe68d214db87b5938eec6b` |
| `/images/fr/02-golden-point.png` | `7b51967747730bfa4fdbb7df8407a48ca2ad3f31acab27092a5e2270f5f1a79b` |
| `/images/fr/03-americano.png` | `2164580d9e919c604b1c7f10cc2a1c6134023f62054b6e4b9b7b53ea2e40f047` |
| `/images/fr/04-edit-score.png` | `44683a311ba57817e0170695d0e70fefc65872ce154abbe7891af20dcb94507c` |
| `/images/fr/05-result.png` | `f412ac6df833c84eb533d740298a6143c5c56ab83cfd65e562c06d85048fac58` |
| `/images/fr/06-history.png` | `7fe20ea05905318b715f3018a14602ff714502096caf72b3d02d83f4924d742b` |
| `/images/it/01-match.png` | `66b23f40203e9c0949255bda42c5061da48a3574b85fbebb2a880a4f30a0e4ed` |
| `/images/it/02-golden-point.png` | `a01e40d248fe15571a1979b07f4f320f0bfcbe32ff821bb8d02283ce441f2a43` |
| `/images/it/03-americano.png` | `491e23c42c1744d89f31c163a7ce8a461367459c6f0b58f3a8c7ae6591d2f8ee` |
| `/images/it/04-edit-score.png` | `17a0b69c5d9e53523541b9a1fa3e9bbd06b8d527cbea9a01c96edc00d6a55ada` |
| `/images/it/05-result.png` | `154ebb369d778580d2730badefd113cce208cecd907a34c02223a30729e00fc3` |
| `/images/it/06-history.png` | `002d5cc7004ec3781ac2b722213be9730e677352edfb79da30aefb78045d3f01` |
| `/images/nb/01-match.png` | `896e4416fa45fe0251182fcee9a988a5ae1fcbbb08a15577ebfd580af1fe0178` |
| `/images/nb/02-golden-point.png` | `354e222b233e2435efda75b77d1b79188b8db790d5b1423937d52c9dbbef475f` |
| `/images/nb/03-americano.png` | `517e16774c60596096237af3f889834e8ea204431c1411c3aea8403d41321a6e` |
| `/images/nb/04-edit-score.png` | `10262b5bec9866b6a46fea637f24ac7416329e6b8d6424de5add35e831b4e89b` |
| `/images/nb/05-result.png` | `789b7d605d5781a7602394390a2876a5c7fd1be66526b216ce2d4459ba9f1855` |
| `/images/nb/06-history.png` | `cae871265ca5b6d5ff1e0b63cc2eaed3ce4474942fda7d66b9c7539e6285d271` |
| `/images/nl/01-match.png` | `1af5a55e867e1f5b7d15ca422ab9ce2a415b1cc30f73dff302cba68c0bcc501a` |
| `/images/nl/02-golden-point.png` | `67c20a73aa46a75ff68cc628d099bf13c8af3d707ed942dfd4dcbc26316b1732` |
| `/images/nl/03-americano.png` | `81f88ebce18b693746c431be395d3b853873e320bc34cdfed440a8a1ae2634ee` |
| `/images/nl/04-edit-score.png` | `5abbfc006a66a72bb2bd547f8e17f3c17b130ab92b9e1b7acf42b9c777284298` |
| `/images/nl/05-result.png` | `4764bf65ed67fb731f5d8472361093b9561491135468755ebe52ef35d55b50af` |
| `/images/nl/06-history.png` | `f4c38a753abf3eb9141225065057ae5418a82c55a9cbd5caf7268d9c3b348a9e` |
| `/images/pt-br/01-match.png` | `2ff82e722114bdb8ffec875a7d4057183c8e6b051b272066e8ef30213d2a6bb6` |
| `/images/pt-br/02-golden-point.png` | `185e626b436522df71b6e80590183eb4575f17fd6c86cc821ba7ee8ec5a59cff` |
| `/images/pt-br/03-americano.png` | `89bd958011fead321939804023ad47e3ac812539e3cd68d882a6f81e530c6051` |
| `/images/pt-br/04-edit-score.png` | `79ca9278eb6eb10cbb8d246d5692a903edeee812f9158b448b2b64ce7a63976e` |
| `/images/pt-br/05-result.png` | `b86dd8be30c8e9cca0d5666666b8ced765a12e5e37c18b52ff306f7858ca357d` |
| `/images/pt-br/06-history.png` | `246646a93d0b80eb562a479659f8d0df8b75a9c54903dff33e07b141cb64b550` |
| `/images/pt-pt/01-match.png` | `ea5f32d3387e3b8660c51e7f4f1e315db477d525a02864475708e28702fc1e22` |
| `/images/pt-pt/02-golden-point.png` | `e019758ba8f07bde3e97639a76382bf8d8952c00f174aab80f4c679844e9fb15` |
| `/images/pt-pt/03-americano.png` | `2c3c17995201c065fee5b3b6519c717d185686479b06286de02033c16045ffd9` |
| `/images/pt-pt/04-edit-score.png` | `2d50707314a9aef61b5468f8a802d141b160a30881c814d02852528c4ffdccf1` |
| `/images/pt-pt/05-result.png` | `d48fb468ab22a49242e0456c4dc06b48d2b6199edf791ddfac8084e8e729569c` |
| `/images/pt-pt/06-history.png` | `5e761ce297c8adeb10b61d727cdf8b3083127e7b5ed75c52b82a5140c2c65729` |
| `/images/ru/01-match.png` | `c36fc2cbc0c64dc78e95153e1ec9b95586d1584740da4ffe1e35919a9d3e7e22` |
| `/images/ru/02-golden-point.png` | `630f16a11af075baf14b11b6028f2e3b0310754e7ede6caff9831b55f2a8ce64` |
| `/images/ru/03-americano.png` | `ed8d9eb74e5e6e850cd20a82788de7be9f2e9a935adb0bfa31f2c4f122ee90f5` |
| `/images/ru/04-edit-score.png` | `56c511c0e32d00a7c87aac5b0a7825df5caade53cfe46e74205c3499ca879643` |
| `/images/ru/05-result.png` | `a1f29a94137bfd02f29cf54a44820572ef7ba1a0fd2a5ee8ec87631e6e6c2e23` |
| `/images/ru/06-history.png` | `2c7c274d20559269aec8cb5d8c9358c9b5569b0342dd5340bbe652f7c7570aaf` |
| `/images/sv/01-match.png` | `39c7c430ccca0f79a5f9813bb386a04153db22c0939cb80cc9219d5fee5bd004` |
| `/images/sv/02-golden-point.png` | `539d26a6446b4670898088d7e4f83bc038fd86cd47ccb6d6e6c3fd5d0fa9e4bb` |
| `/images/sv/03-americano.png` | `fac00b92edc0beba5a4dcae598af953a2449a42de4f845d5d65bd067534862d2` |
| `/images/sv/04-edit-score.png` | `d32b9a0af11d95f3d8190325926dbcdb4ec9e6f217866017402a6d4cb7977066` |
| `/images/sv/05-result.png` | `20c90530829bdb9ea1e83d509c1d3b25d19fcc72686f05ab2ba50bdf383f8c4e` |
| `/images/sv/06-history.png` | `c4bf114d9e14096e103ec4747a9eee026908e4301f2abbb664b0a7160d0286be` |
| `/it/` | `6ea49aac48f17b822dfd137e3255f496ca50d24460c2af1ddaa20ad64c0e22fb` |
| `/it/privacy/` | `37f7a2e8e5a897da8d65cd4dcc947741a29295afb0d872cd7056314ffa63fe2a` |
| `/it/support/` | `94c42de47c2b386749ae572054daa4ec35d7b5d6eb348844256440b00c53b458` |
| `/it/terms/` | `eb889a2d54923225f4c34351cf974cca1c99ef55a1f6acb8ba2803ca08964659` |
| `/nb/` | `ac97f92c661db57c9a4953ac5d44c95d25edeb404b1b1206896902be240439ca` |
| `/nb/privacy/` | `00a6aa3ac8a61090f49e327fc385758431fdc25366442e67dd9d491f1d41d0c3` |
| `/nb/support/` | `1ca3bdabedf08e887f1ed9908a9a444384508f8f77b989a7513a7e1e08598d15` |
| `/nb/terms/` | `f81a404282ecc9795fcba40d4f41c12a36a4bc5ac7da0c145802d6564400854e` |
| `/nl/` | `ef69b823524bdc808df4e1dc898d5798e487fdfbf0e931ea7561262a80be0447` |
| `/nl/privacy/` | `79929acf685b4de77dfdb50c0f0a87dd3ac10c0e8fdd470e2270df20b15e1d5f` |
| `/nl/support/` | `2bf20618992252e55bec9999236aaedd799d70beb4a16278d7e72d63d75566bb` |
| `/nl/terms/` | `eadbd2ed86568627591581e0877418928561ffb55a854aa6dbbe5d131759032d` |
| `/privacy/` | `780a438b548004c448ee1c53e723b467dbb77aa77018554665829a4ee88b1090` |
| `/pt-br/` | `2a58c4f93a145c202e9d01c9e33f598e5b58241c6c88478b13150c0685fa6e96` |
| `/pt-br/privacy/` | `d05a6214678cbfb313502ff0081e27ae5731495e0aaeab7fdd420ab376f61f58` |
| `/pt-br/support/` | `ce3133c7603ab01ea15e1d196ac4497ba993deac687e75163605f9af8c7004dd` |
| `/pt-br/terms/` | `1d4c994e777e2fcf15699ba754114b0bfab32d02116c1e81a3c4a925492956d2` |
| `/pt-pt/` | `b96c768d720b581d619f7567ed66f462ce8b4068fc27873c06d0d3c5ce314438` |
| `/pt-pt/privacy/` | `8ca28901d32feeccf4eb1d341b52351b31301ee3346268ddd90dc9d47e01cfb6` |
| `/pt-pt/support/` | `39b759b1825d8fbd0d169ead5e61f6ef00c5697010612d2568a3e48241384f45` |
| `/pt-pt/terms/` | `a7c1d46d3824ab9720608e07a4b982e022cb0116277cef7170f07a5bbc509df2` |
| `/ru/` | `21ab56e688fa1baaffb81d1655830fcd228a0b22a412915c224a75286fae629b` |
| `/ru/privacy/` | `916a06c97f86e44b097c56f3715fc49e48856796240b5b83afd54a1491c006fa` |
| `/ru/support/` | `df271266fa84da2f6348815b464207d66b596e15f030144b7531ab0311715770` |
| `/ru/terms/` | `84427c3979b33fe1ea5ea10b80678cd9bdbc93322dd353a469e67e8fe023c72d` |
| `/styles.css` | `de0164f5713972704db4eb43295a234c4db263d7ae944615f38736d26a135451` |
| `/support/` | `bb7e5b2c88ddc073f03c186371dacab4ab9ab627b5cebe1854f55e55cff1d663` |
| `/sv/` | `5462cf15e6438c19ce9a14973d28f80018e31c36b5269cc9494a4b483aca6388` |
| `/sv/privacy/` | `ad139975d2421fbd6213f5c5a66478592127d9971a9425915fb6f5379694b80e` |
| `/sv/support/` | `422c04ee7272556add1200fe68041a261084793f4d6d017b49834e8249bf39b5` |
| `/sv/terms/` | `2f4d51eac53ae779c5894bd2923450b320bc9dc2e359fdb8869352b7447918e4` |
| `/terms/` | `3fccb06c2f74f027b2e065107ec48dd8fab509728abdddab2492d2b99d096626` |

Production response headers also verified (HTTPS HEAD exit 0, HTTP 200): CSP `default-src none`, stylesheet/image self only, connect-src none, object/base/form/frame none, upgrade-insecure-requests; Referrer-Policy no-referrer; X-Content-Type-Options nosniff. Raw headers `.artifacts/M10-completion/production-headers.txt`.
