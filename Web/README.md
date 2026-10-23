# Web — Padel Score — Wrist

Live: https://padel-score-wrist.pages.dev/ (Cloudflare account
`61273605cefdc42ca422521f82319c72`). Owner authorized publication on 2026-10-21.
Support: `dzmitry.dziachenka@gmail.com`; developer: Dzmitry Dziachenka.
The owner authorized the prepared multilingual update in the M10 completion task on 2026-10-23. It is published: English plus twelve added locales, four pages each. Production readback and deployment evidence: `../AI/evidence/M10/site-publication.md`. `Web/public` contains only public static files;
there is no analytics script or server-side function.


Four static pages, served by Cloudflare Pages, that satisfy what Apple requires of
every App Store app: a working privacy policy URL, a working support URL, and Terms
of Use the app can link to.

```text
https://padel-score-wrist.pages.dev/          landing
https://padel-score-wrist.pages.dev/privacy   Privacy Policy
https://padel-score-wrist.pages.dev/terms     Terms of Use -> Apple's Standard EULA
https://padel-score-wrist.pages.dev/support   support and contact
```

The app links to all three from its settings or about surface, and to Terms and
Privacy from its paywall. Those rules live in [../AI/DESIGN.md](../AI/DESIGN.md);
this directory is only the site.

## What configures it

Three keys in [../Config/project.env](../Config/project.env):

| Key | Used for |
| --- | --- |
| `SUPPORT_SITE_URL` | the origin, and — via its first host label — the Cloudflare Pages project name |
| `SUPPORT_EMAIL` | the address shown on the privacy and support pages |
| `DEVELOPER_NAME` | the footer credit and the privacy policy's opening line |

`Scripts/verify-site.sh` checks the pages against these, so editing a URL in one
place and not the other is a failure rather than a surprise after deployment.

## Keeping the content current

The pages match the approved product: five completed games free automatically,
then a one-time lifetime unlock, with the count retained on in-app data deletion.
The landing page presents During the game, After the game, and Try and buy with
six real app captures from `AI/store-assets/manifest.json`. The isolated demo is
free; all finished-game history remains available after the new-game limit.

Keep the offline Watch documents in AboutView.swift and the public pages aligned.
Terms link to Apple's Standard EULA. Only update public identity and retention
from an explicit owner decision recorded in AI/PRODUCT.md.

## Preview locally

No dependency beyond what macOS already has:

```bash
python3 -m http.server --directory Web/public 8000
```

Then open <http://localhost:8000/>. Directory URLs resolve to `index.html` the same
way Cloudflare Pages resolves them, so `/privacy/` renders what will ship. Check both
appearances, tab through every link, and confirm the skip link appears on first Tab.

`_headers` is applied by Cloudflare, not by the local server, so the Content Security
Policy is not exercised here. Confirm it after deploying with
`curl -sSI https://padel-score-wrist.pages.dev/`.

## Check it

```bash
make site-check
```

Hermetic and offline: it never contacts the network. It confirms the four pages
exist, that every internal link resolves to a file in this tree, that each page keeps
its required headings, that `/terms` still links to Apple's Standard EULA, and that
the configured email, developer name, and site URL are the ones the pages actually
carry. The M15 asset check also verifies all six PNG dimensions, hashes, provenance,
and byte-identical website copies.

## Deploy

```bash
make site-deploy              # preview deployment
make site-deploy PRODUCTION=1 # the live site
```

Publishing is a human step, like the Xcode Archive. No verification gate deploys,
and none ever should: a gate that publishes turns a failed check into something the
public has already seen.

Requires [Wrangler](https://developers.cloudflare.com/workers/wrangler/install-and-update/).
Nothing here installs it for you. Authenticate once with `wrangler login`, or export
`CLOUDFLARE_API_TOKEN` in your shell. Never put a token in this repository —
`Config/project.env` is committed.

Use `./Scripts/deploy-site.sh --dry-run` to see the exact command first.

The branch is always passed explicitly — `preview` without `PRODUCTION=1`, `main`
with it — because Wrangler otherwise infers it from the repository you are standing
in, and this repository's branch is `main`, which Pages treats as production. A
preview would have published the live site.

`PRODUCTION=1` therefore assumes your Pages project's production branch is `main`,
which is the default. If you changed it, that deploy creates a preview instead —
the safe direction, but not what you asked for. Change `site_branch` in
`Scripts/deploy-site.sh` to match your project.

## Adding a language

[../AI/DESIGN.md](../AI/DESIGN.md) requires the site to cover every language the app
ships, or to record why it does not. The convention, once a second language exists:

```text
/ru/            /ru/privacy/            /ru/terms/            /ru/support/
/pt-br/         /pt-br/privacy/         /pt-br/terms/         /pt-br/support/
```

Lowercase, with the region subtag after a hyphen. Every page in every language lists
every other language in `<link rel="alternate" hreflang="…">`, plus one `x-default`
pointing at the English page. All thirteen locales are present. Each translated page links to the matching section in every other language, with English as x-default.
