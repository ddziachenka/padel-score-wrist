# Web — the published legal and support site

Four static pages, served by Cloudflare Pages, that satisfy what Apple requires of
every App Store app: a working privacy policy URL, a working support URL, and Terms
of Use the app can link to.

```text
https://<yourapp>.pages.dev/          landing
https://<yourapp>.pages.dev/privacy   Privacy Policy
https://<yourapp>.pages.dev/terms     Terms of Use -> Apple's Standard EULA
https://<yourapp>.pages.dev/support   support and contact
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

## Filling it in

Every product-specific sentence is marked `TBD`. Replace all of them, including
`yourapp.pages.dev` in each page's `canonical` and `hreflang` links and the project
name in `wrangler.jsonc`. No script scans these pages for placeholders — a product
may host its policy elsewhere and never publish `Web/` — so the final audit is what
stops an unfinished page: `REL-801` (no placeholder copy anywhere a user can reach)
and, for an App Store product, `REL-503` and `REL-1008` must each be `VERIFIED` in the
consolidated record before release verification can pass, and a privacy policy that
says `TBD` is exactly what they exist to stop.

Delete a section that genuinely does not apply — the subscription sections in
`/terms` and `/support` when the app sells nothing — rather than leaving it empty.
`Scripts/verify-site.sh` names the headings each page must keep.

Do not invent data collection the app does not perform, and do not promise an
absence it cannot honour. The privacy policy has to match
[../AI/ARCHITECTURE.md](../AI/ARCHITECTURE.md) and the App Store nutrition labels.

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
`curl -sSI https://<yourapp>.pages.dev/`.

## Check it

```bash
make site-check
```

Hermetic and offline: it never contacts the network. It confirms the four pages
exist, that every internal link resolves to a file in this tree, that each page keeps
its required headings, that `/terms` still links to Apple's Standard EULA, and that
the configured email, developer name, and site URL are the ones the pages actually
carry.

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
pointing at the English page. English ships alone here, so its alternates point at
themselves — which is correct, not a placeholder.
