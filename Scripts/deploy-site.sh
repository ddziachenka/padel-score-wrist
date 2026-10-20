#!/usr/bin/env bash
# deploy-site.sh — publish Web/ to Cloudflare Pages.
#
# THIS IS A HUMAN STEP AND NO VERIFICATION GATE CALLS IT.
#
# That is the same rule the release gate follows when it stops before
# `xcodebuild archive`, and for a stronger reason. Publishing is outward-facing
# and immediate: a gate that deployed would put a page in front of the public
# before the person responsible had decided the page was right, and a later
# failure could not take it back. AGENTS.md A13 keeps App Store submission a human
# decision; this is the same kind of act.
#
# Nothing here installs anything, and nothing here reads or writes a credential.
# Authenticate once with `wrangler login`, or export CLOUDFLARE_API_TOKEN in your
# shell. Config/project.env is committed and must never hold a token.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

iosai_enter_root

usage() {
    cat <<'EOF'
Usage: ./Scripts/deploy-site.sh [--production] [--dry-run]

Publishes Web/public to the Cloudflare Pages project named by SUPPORT_SITE_URL.

  --production   deploy to the production branch — the live site people reach at
                 <SUPPORT_SITE_URL>. Without it, a preview deployment is created
                 on its own URL and the live site is untouched.
  --dry-run      print the exact wrangler command and exit, contacting nothing.
  -h, --help     this message

Before deploying:
  wrangler login                  # once per machine, interactive
  export CLOUDFLARE_API_TOKEN=... # or this, for a non-interactive shell

Never put a token in Config/project.env. It is committed.
EOF
}

opt_production="no"
opt_dry_run="no"
while [ $# -gt 0 ]; do
    case "$1" in
        --production) opt_production="yes"; shift ;;
        --dry-run)    opt_dry_run="yes"; shift ;;
        -h|--help)    usage; exit 0 ;;
        *)  log_error "unknown argument: $1"
            hint "run ./Scripts/deploy-site.sh --help"
            exit "$EX_USAGE" ;;
    esac
done

load_project_config

# --- the site must be named before it can be published ----------------------
if [ -z "${SUPPORT_SITE_URL:-}" ]; then
    log_error "SUPPORT_SITE_URL is not set; there is nothing to deploy to"
    hint "./Scripts/configure-project.sh --site-url https://yourapp.pages.dev ..."
    hint "see Config/project.env.example"
    exit "$EX_UNAVAILABLE"
fi
validate_support_site_url "$SUPPORT_SITE_URL" || exit "$EX_USAGE"

project="$(site_project_name)"
site_root="${IOSAI_ROOT}/Web/public"

if [ ! -d "$site_root" ]; then
    log_error "Web/public does not exist; there is nothing to publish"
    exit "$EX_NOINPUT"
fi

# --- never publish a site that does not pass its own checks -----------------
#
# The cheapest moment to catch a broken link between /privacy and /support is
# before the pages are public, not after someone follows one.
log_step "Checking the site before publishing"
if ! "${_script_dir}/verify-site.sh"; then
    log_error "refusing to publish a site that fails verification"
    hint "fix the problems above, then run this again"
    exit "$EX_VERIFY"
fi

# --- wrangler ---------------------------------------------------------------
#
# Absent means absent. Installing a tool on someone's machine because a script
# wanted it is not this template's business, and a deploy is not the moment to
# discover a new dependency.
#
# A dry run does not need it. Its whole contract is "show me the command without
# doing anything", and refusing to print a command because the tool that would
# run it is missing makes the one mode that works on any machine the mode that
# does not. It reports the absence instead, below, so the finding is not lost.
wrangler_present="yes"
command -v wrangler >/dev/null 2>&1 || wrangler_present="no"

if [ "$wrangler_present" = "no" ] && [ "$opt_dry_run" = "no" ]; then
    log_error "wrangler is not installed, so the site cannot be published"
    hint "install it, then run this again:"
    hint "  npm install -g wrangler"
    hint "see https://developers.cloudflare.com/workers/wrangler/install-and-update/"
    exit "$EX_UNAVAILABLE"
fi

# `wrangler pages deploy` reads Web/wrangler.jsonc for the project name and the
# output directory, so the command stays short and the configuration stays in one
# place. --project-name is passed anyway: it makes the destination visible in the
# command this script prints, and it fails loudly rather than silently deploying
# elsewhere if the config file were edited to disagree.
#
# --branch is ALWAYS passed, and that is the important part. Left off, wrangler
# infers the branch from the repository it is standing in — and this repository's
# branch is normally `main`, which Pages treats as the production branch. A
# developer asking for a preview would have published the live site, learning about
# it from the URL wrangler printed afterwards. Nothing about that is recoverable by
# a later check, so the branch is stated rather than inferred in both directions.
site_branch="preview"
[ "$opt_production" = "yes" ] && site_branch="main"
set -- pages deploy --project-name "$project" --branch "$site_branch"

printf '\n'
if [ "$opt_production" = "yes" ]; then
    log_step "Production deployment to ${SUPPORT_SITE_URL}"
else
    log_step "Preview deployment for project ${project}"
    log_info "The live site at ${SUPPORT_SITE_URL} is not affected."
    log_info "Use --production when you want this to become the live site."
fi
log_info ""
log_info "  cd $(shell_quote "${IOSAI_ROOT}/Web") && wrangler $*"
log_info ""

if [ "$opt_dry_run" = "yes" ]; then
    if [ "$wrangler_present" = "no" ]; then
        log_warn "wrangler is not installed, so the command above cannot run yet"
        hint "npm install -g wrangler"
    fi
    log_ok "dry run: nothing was published and Cloudflare was not contacted"
    exit 0
fi

# Run from Web/ so wrangler finds wrangler.jsonc and writes its .wrangler/ state
# there — which .gitignore covers, because milestone_checkout_is_clean refuses any
# untracked file and would otherwise block every gate after the first deploy.
cd "${IOSAI_ROOT}/Web"
if ! wrangler "$@"; then
    printf '\n'
    log_error "wrangler could not publish the site"
    hint "authenticate with 'wrangler login', or export CLOUDFLARE_API_TOKEN"
    hint "a token belongs in your shell, never in this repository"
    exit "$EX_FAIL"
fi

printf '\n'
if [ "$opt_production" = "yes" ]; then
    log_ok "published; confirm it before evidencing REL-503 and REL-1004:"
    log_info "  curl -sSI ${SUPPORT_SITE_URL}/privacy"
    log_info "  curl -sSI ${SUPPORT_SITE_URL}/support"
else
    log_ok "preview published; wrangler printed its URL above"
fi
