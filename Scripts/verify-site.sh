#!/usr/bin/env bash
# verify-site.sh — the published legal and support site, checked offline.
#
# Apple requires a working privacy policy URL and support URL for every App Store
# app, and Terms and Privacy links inside any app that sells a subscription.
# Web/ is where those pages live and this is what keeps them honest.
#
# EVERY CHECK HERE IS HERMETIC. Nothing contacts the network, and nothing may be
# added that does. Whether the site is actually reachable is a different question
# with a different answer: it depends on the deployed site, so the content and
# release audits confirm REL-503 and REL-1004 in their coverage records. A gate that reported
# "the privacy policy URL works" from a machine with no network, or that passed
# because a stale deployment of the previous version was still up, would be worse
# than no check at all.
#
# What this proves instead is everything knowable from the repository: that the
# pages exist, that they still say what they must say, that no link among them is
# broken, and that the URL, email, and developer name they carry are the ones
# Config/project.env configures. That last one is the drift this exists to catch —
# a product that changes SUPPORT_SITE_URL and forgets the pages ships an app
# pointing at a site that answers for a different product.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

iosai_enter_root

# Loaded here rather than inherited. verify-static.sh already has a configuration
# in scope when it calls this script, but `make site-check` and a developer
# running it directly do not, and a check that behaves differently depending on
# who invoked it is a check nobody trusts.
#
# Read directly rather than through load_project_config, which ALSO validates
# DERIVED_DATA_PATH against the invoking checkout's owned cache root. That check
# needs the cache-owner context verify-static.sh establishes from its
# --immutable-cache-owner argument, and that context is deliberately not
# inheritable through the environment — common.sh resets any ambient attempt to
# set it, because choosing another cache owner is exactly what an attacker would
# want. So a subprocess cannot reproduce it, and calling load_project_config here
# failed every integration run of a product that configures a DerivedData
# override: the override was measured against the read-only candidate worktree
# instead of the checkout that owns the cache.
#
# Nothing about the build cache matters to a static site. Three values do.
clear_project_config_environment
if [ -f "$IOSAI_CONFIG_FILE" ]; then
    env_file_load "$IOSAI_CONFIG_FILE"
    if [ -n "${SUPPORT_SITE_URL:-}" ]; then
        validate_support_site_url "$SUPPORT_SITE_URL" || exit "$EX_VERIFY"
    fi
    if [ -n "${SUPPORT_EMAIL:-}" ]; then
        validate_support_email "$SUPPORT_EMAIL" || exit "$EX_VERIFY"
    fi
fi

SITE_DIR="${IOSAI_ROOT}/Web"
SITE_ROOT="${SITE_DIR}/public"

FAILURES=0
fail() { log_error "$@"; FAILURES=$((FAILURES + 1)); }

log_step "Published legal and support site"

# ---------------------------------------------------------------------------
# 1. The pages exist.
#
# Directory-index layout: privacy/index.html serves /privacy/, and Cloudflare
# Pages redirects /privacy to it. Naming the file privacy.html would serve
# /privacy.html and put an extension in a URL that goes in an App Store listing.
# ---------------------------------------------------------------------------
if [ ! -d "$SITE_ROOT" ]; then
    log_error "Web/public does not exist; the published site is missing entirely"
    hint "the template ships this directory — restore it from the template, or"
    hint "see Web/README.md for what it must contain"
    exit "$EX_NOINPUT"
fi

REQUIRED_PAGES="index.html privacy/index.html terms/index.html support/index.html"
REQUIRED_ASSETS="styles.css _headers"

missing_page="no"
for page in $REQUIRED_PAGES; do
    if [ ! -f "${SITE_ROOT}/${page}" ]; then
        log_error "Web/public/${page} is missing"
        missing_page="yes"
    fi
done
for asset in $REQUIRED_ASSETS; do
    if [ ! -f "${SITE_ROOT}/${asset}" ]; then
        log_error "Web/public/${asset} is missing"
        missing_page="yes"
    fi
done
if [ ! -f "${SITE_DIR}/wrangler.jsonc" ]; then
    log_error "Web/wrangler.jsonc is missing; nothing knows where to deploy"
    missing_page="yes"
fi
if [ "$missing_page" = "yes" ]; then
    hint "Web/README.md describes the four pages and what each one carries"
    exit "$EX_NOINPUT"
fi
log_ok "the four pages, the stylesheet, the headers, and the Pages config are present"

# ---------------------------------------------------------------------------
# 2. Required sections.
#
# Checked as headings rather than as whole sentences. A product rewrites every
# word on these pages — that is the point of a scaffold — but a privacy policy
# that stopped saying how to delete your data, or a terms page that dropped the
# licence, is not a rewrite. Deleting a section that genuinely does not apply is
# legitimate for the optional ones and they are not listed here.
#
# file<TAB>heading fragment. Matching is a fixed-string search per line.
# ---------------------------------------------------------------------------
REQUIRED_SECTIONS="
privacy/index.html	The short version
privacy/index.html	Information processed
privacy/index.html	Retention and deletion
privacy/index.html	Changes to this policy
privacy/index.html	Contact
terms/index.html	License
terms/index.html	Privacy and support
terms/index.html	Changes
terms/index.html	Contact
support/index.html	What to include in an email
support/index.html	Privacy
"

section_failures=0
while IFS="$(printf '\t')" read -r page fragment; do
    [ -n "${page:-}" ] || continue
    [ -n "${fragment:-}" ] || continue
    if ! grep -Fq -- "$fragment" "${SITE_ROOT}/${page}"; then
        fail "Web/public/${page} no longer has a section for: ${fragment}"
        section_failures=$((section_failures + 1))
    fi
done <<EOF
$REQUIRED_SECTIONS
EOF
[ "$section_failures" -eq 0 ] && log_ok "every page keeps the sections it must answer"

# ---------------------------------------------------------------------------
# 3. Internal links resolve.
#
# A 404 between these pages is the failure mode that matters most: the App Store
# listing points at /privacy, the app's settings screen points at /support, and a
# person who follows one of those and lands on nothing has been told the developer
# does not care. Every root-relative href is resolved against the tree.
# ---------------------------------------------------------------------------
link_failures=0
for page in $REQUIRED_PAGES; do
    # grep's no-match status is an empty link set; any other error is an
    # incomplete scan and must never become a clean result.
    scan_rc=0
    hrefs="$(grep -o 'href="/[^"]*"' "${SITE_ROOT}/${page}" 2>/dev/null)" || scan_rc=$?
    if [ "$scan_rc" -gt 1 ]; then
        fail "could not scan internal links in Web/public/${page} (extractor exited ${scan_rc})"
        link_failures=$((link_failures + 1))
        continue
    fi
    hrefs="$(printf '%s\n' "$hrefs" | sed 's/^href="//; s/"$//')" \
        || { fail "could not parse internal links in Web/public/${page}"; link_failures=$((link_failures + 1)); continue; }
    while IFS= read -r href; do
        [ -n "$href" ] || continue
        target="${SITE_ROOT}${href}"
        case "$href" in
            */) target="${target}index.html" ;;
        esac
        if [ ! -f "$target" ]; then
            fail "Web/public/${page} links to ${href}, which is not in the site"
            link_failures=$((link_failures + 1))
        fi
    done <<EOF
$hrefs
EOF
done
[ "$link_failures" -eq 0 ] && log_ok "every internal link resolves to a page in the site"

# ---------------------------------------------------------------------------
# 4. The licence link.
#
# The template chooses one licence for every product it generates: Apple's
# Standard EULA. The /terms page exists to say so and to link to it, so a terms
# page without that link is a terms page that grants nothing.
# ---------------------------------------------------------------------------
if grep -Fq -- "$IOSAI_APPLE_EULA_URL" "${SITE_ROOT}/terms/index.html"; then
    log_ok "the terms page links to Apple's Standard EULA"
else
    fail "Web/public/terms/index.html does not link to Apple's Standard EULA"
    hint "expected: ${IOSAI_APPLE_EULA_URL}"
fi

# ---------------------------------------------------------------------------
# 5. Agreement with Config/project.env.
#
# Only checked for values that are SET. They are empty in the universal template
# and stay empty until the Legal and Support milestone fills them in; requiring
# them here would fail every gate between M00 and that milestone for work that is
# not due yet. A product may host its policy on a company domain and never publish
# Web/, so final audit coverage owns REL-503, REL-1004, REL-506, REL-1008, and
# REL-801; none permits INAPPLICABLE for an App Store product.
# ---------------------------------------------------------------------------
config_failures=0

if [ -n "${SUPPORT_EMAIL:-}" ]; then
    for page in privacy/index.html support/index.html; do
        if ! grep -Fq -- "$SUPPORT_EMAIL" "${SITE_ROOT}/${page}"; then
            fail "Web/public/${page} does not show SUPPORT_EMAIL (${SUPPORT_EMAIL})"
            config_failures=$((config_failures + 1))
        fi
    done
fi

if [ -n "${DEVELOPER_NAME:-}" ]; then
    for page in $REQUIRED_PAGES; do
        if ! grep -Fq -- "$DEVELOPER_NAME" "${SITE_ROOT}/${page}"; then
            fail "Web/public/${page} does not credit DEVELOPER_NAME (${DEVELOPER_NAME})"
            config_failures=$((config_failures + 1))
        fi
    done
fi

if [ -n "${SUPPORT_SITE_URL:-}" ]; then
    # The canonical link is what tells a search engine, and anyone reading the
    # source, which site this page belongs to. A page still carrying the
    # scaffold's example origin is a page that was never finished.
    for page in $REQUIRED_PAGES; do
        canonical="$(grep -o 'rel="canonical" href="[^"]*"' "${SITE_ROOT}/${page}" \
            | sed 's/.*href="//; s/"$//' || true)"
        if [ -z "$canonical" ]; then
            fail "Web/public/${page} has no canonical link"
            config_failures=$((config_failures + 1))
        else
            case "$canonical" in
                "${SUPPORT_SITE_URL}"/*) : ;;
                *)
                    fail "Web/public/${page} is canonical at ${canonical}, not under ${SUPPORT_SITE_URL}"
                    config_failures=$((config_failures + 1)) ;;
            esac
        fi
    done

    # The Pages project name is derived from SUPPORT_SITE_URL, so wrangler.jsonc
    # must agree with it or the site deploys to a project whose URL nothing in
    # this repository names. deploy-site.sh refuses the same mismatch; catching it
    # here means it is found by `make static` rather than at deploy time.
    expected_project="$(site_project_name)"
    if ! grep -Eq "\"name\"[[:space:]]*:[[:space:]]*\"${expected_project}\"" \
            "${SITE_DIR}/wrangler.jsonc"; then
        fail "Web/wrangler.jsonc does not name the Pages project \"${expected_project}\""
        hint "SUPPORT_SITE_URL=${SUPPORT_SITE_URL} deploys to ${expected_project}.pages.dev"
        config_failures=$((config_failures + 1))
    fi
fi

if [ "$config_failures" -eq 0 ]; then
    if [ -n "${SUPPORT_SITE_URL:-}${SUPPORT_EMAIL:-}${DEVELOPER_NAME:-}" ]; then
        log_ok "the pages carry the configured site URL, support email, and developer"
    else
        log_skip "site identity is unconfigured, so the pages were not checked against it"
    fi
fi

# ---------------------------------------------------------------------------
printf '\n'
if [ "$FAILURES" -gt 0 ]; then
    log_error "site verification FAILED — ${FAILURES} problem(s)"
    exit "$EX_VERIFY"
fi
if [ -f "${_script_dir}/verify-store-materials.py" ]; then
    python3 "${_script_dir}/verify-store-materials.py" || exit "$EX_VERIFY"
fi
log_ok "site verification PASSED"
