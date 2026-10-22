#!/usr/bin/env bash
# verify-static.sh — every repository-level check that needs no simulator.
#
# This is the direct static gate, the optional pre-commit convenience, and the
# first stage of every strict boundary check. It never needs a simulator.
#
# Files are found by walking the filesystem, not by asking git: the template
# repository has no commits, and a localization worktree may hold new untracked
# sources that still have to pass.
set -euo pipefail

_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
. "${_script_dir}/lib/common.sh"

# Filesystem and git must agree on which repository this is (see common.sh).
iosai_enter_root

# Internal immutable-candidate context. The option is accepted only when the
# current source is the detached read-only candidate. This keeps a configured
# cache keyed to the invoking checkout without trusting ambient environment
# variables or its mutable source bytes.
opt_immutable_cache_owner=""
opt_immutable_candidate=""
while [ $# -gt 0 ]; do
    case "$1" in
        --immutable-cache-owner)
            [ $# -gt 1 ] || die "$EX_USAGE" "internal immutable cache owner requires a value"
            opt_immutable_cache_owner="$2"
            shift 2 ;;
        --candidate)
            [ $# -gt 1 ] || die "$EX_USAGE" "internal immutable candidate requires a value"
            opt_immutable_candidate="$2"
            shift 2 ;;
        *) die "$EX_USAGE" "unknown verify-static argument: $1" ;;
    esac
done
if [ -n "$opt_immutable_cache_owner" ]; then
    [ -n "$opt_immutable_candidate" ] \
        || die "$EX_USAGE" "immutable cache owner requires an explicit candidate"
    case "$opt_immutable_cache_owner" in /*) : ;; *) die "$EX_USAGE" "immutable cache owner must be absolute" ;; esac
    candidate_head="$(git -C "$IOSAI_ROOT" rev-parse HEAD 2>/dev/null)" \
        || die "$EX_VERIFY" "immutable static source has no candidate commit"
    [ "$candidate_head" = "$opt_immutable_candidate" ] \
        || die "$EX_VERIFY" "immutable static source does not match the requested candidate"
    git -C "$opt_immutable_cache_owner" cat-file -e "${opt_immutable_candidate}^{commit}" 2>/dev/null \
        || die "$EX_VERIFY" "immutable cache owner does not contain the candidate commit"
    assert_immutable_candidate_root "$opt_immutable_candidate"
    IOSAI_CACHE_OWNER_PATH="$(physical_path "$opt_immutable_cache_owner")" \
        || die "$EX_VERIFY" "cannot resolve immutable cache owner root"
fi

FAILURES=0
fail() { log_error "$@"; FAILURES=$((FAILURES + 1)); }

# ---------------------------------------------------------------------------
# 1. Template validation (which also covers shell syntax and the optional hook definition).
# ---------------------------------------------------------------------------
log_step "Static verification"
if ! "${_script_dir}/verify-template.sh"; then
    fail "template validation failed (see above)"
fi
printf '\n'

# ---------------------------------------------------------------------------
# 2. Configuration and repository mode.
# ---------------------------------------------------------------------------
load_project_config
IOSAI_REPO_MODE="$(resolve_repo_mode)"
export IOSAI_REPO_MODE
log_step "Repository mode: ${IOSAI_REPO_MODE}"
if [ "$IOSAI_REPO_MODE" = "template" ]; then
    log_info "  the universal template repository: no application target."
    log_info "  build and simulator checks are not applicable and are not run."
else
    log_info "  a product repository: build and test gates apply."
    if [ "${IOSAI_CONFIG_PRESENT:-0}" -eq 1 ]; then
        # Configuration this gate can check without a simulator, checked HERE.
        #
        # These validators used to run only inside the gates that consume the
        # value, so `make static` — the daily command and the optional pre-commit
        # hook — passed a configuration every build gate rejects: an absolute or
        # `..`-escaping project path, a project outside App/, an unknown
        # distribution channel, a RELEASE_TEST_ARGUMENTS value that narrows the
        # suite. Nothing unsafe happened, because the gates that act on the value
        # do validate it; the developer simply found out late. The cheap gate
        # should fail on a configuration the expensive one cannot accept.
        #
        # These are called directly, not wrapped into an accumulated `fail`, so each
        # keeps its own exit code — 64, the invalid-or-unsafe-configuration code the
        # rest of this toolchain uses and AI/WORKFLOW.md documents. That matters more
        # here than listing several problems at once: the remaining checks would be
        # running against a configuration every gate refuses, so there is nothing to
        # learn by continuing.
        #
        # The container count comes before the container path: with both keys set,
        # the path resolved below is only one of the two, so validating it proves
        # nothing about the configuration as a whole.
        assert_single_project_container

        configured_container="${PROJECT_PATH:-${WORKSPACE_PATH:-}}"
        if [ -n "$configured_container" ]; then
            validate_project_container_path "$configured_container"
        fi

        # Prints the channel on success; only the validation is wanted here.
        resolve_distribution_channel >/dev/null

        split_args "${RELEASE_TEST_ARGUMENTS:-}"
        assert_test_args_allowed "RELEASE_TEST_ARGUMENTS" \
            ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"}

        # MILESTONE_TEST_ARGUMENTS may narrow WHICH tests run, so the complete-suite
        # allowlist does not apply to it — but an argument that retries or repeats a
        # failing test makes the milestone report's counts describe a rerun. Refused
        # here so the daily command finds it, rather than at the milestone boundary
        # after a build. `split_args` overwrites SPLIT_ARGS, so this comes second and
        # nothing below reads the array.
        split_args "${MILESTONE_TEST_ARGUMENTS:-}"
        assert_test_args_report_failures "MILESTONE_TEST_ARGUMENTS" \
            ${SPLIT_ARGS[@]+"${SPLIT_ARGS[@]}"}

        log_ok "the product configuration is valid"
    fi
fi
printf '\n'

# ---------------------------------------------------------------------------
# 3. Application sources, secrets, and credentials.
#
# App/ is never another repository's working tree. The scans below read every file
# under it even when a `.git` sits among them, and a nested repository or submodule
# there is refused outright: no commit would carry its files and no candidate
# snapshot could verify them (assert_no_nested_app_repositories in common.sh).
# ---------------------------------------------------------------------------
log_step "Application sources"
if assert_no_nested_app_repositories; then
    log_ok "App/ holds this repository's own files: no nested repository or submodule"
else
    fail "App/ holds another repository's files (see above)"
fi
printf '\n'

log_step "Secrets and credentials"

# The filename patterns live in Scripts/lib/common.sh (IOSAI_SECRET_NAME_PATTERNS),
# because Config/credential-scan-allowlist.txt is validated against the same list.
#
# They are matched by secret_name_matches, as `case` patterns against each basename
# — NOT through `for p in $LIST`. The list is full of globs and the working
# directory is the repository root, so an unquoted `for` loop pathname-expanded it:
# a directory named `Secrets.playground/` replaced the `Secrets.*` pattern for that
# iteration, and `App/Secrets.plist` was then never looked for. The scan reported
# "no credential or signing files" while the file sat committed. A `case` pattern is
# matched, never expanded, so which patterns are checked cannot depend on what
# happens to sit in the repository.
#
# Exact (path, rule) pairs excused by Config/credential-scan-allowlist.txt. The
# list's validity was checked by verify-template.sh above, and an invalid entry is
# never honoured here: credential_allowlist_scan prints only the entries it accepts.
credential_exemptions="$(credential_allowlist_scan 2>/dev/null || true)"
credential_exempted=""

# Walk once, then match each basename against the pattern list in-shell. Walking
# once also means one honest failure when the walk breaks, instead of the same
# message repeated for every pattern.
found_secret_files=""
secret_name_incomplete="no"
secret_name_candidates=""
if ! secret_name_candidates="$(repo_files 2>&1)"; then
    fail "could not enumerate repository files for the credential filename scan"
    printf '%s\n' "$secret_name_candidates" | sed 's/^/           /' >&2
    hint "the scan is inconclusive, so this is a failure rather than a pass"
    secret_name_candidates=""
    secret_name_incomplete="yes"
fi
while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    # Parameter expansion, not `basename`: this runs once per repository file, and
    # a subshell per file is a process per file for an answer the shell already has.
    base="${hit##*/}"
    secret_name_matches "$base" "$IOSAI_SECRET_NAME_PATTERNS" || continue
    rel="$(relpath "$hit")"
    # Belt and braces: validation already refuses to list a private key or signing
    # material, and this scan would not excuse one even if it were listed.
    if credential_exempt "$rel" filename "$credential_exemptions" \
       && ! secret_name_matches "$base" "$IOSAI_SECRET_NAME_NOT_EXEMPTABLE"; then
        credential_exempted="${credential_exempted}${rel}: filename
"
        continue
    fi
    found_secret_files="${found_secret_files}${rel}: filename: credential-or-signing-material
"
done <<EOF
$secret_name_candidates
EOF
# Deduplicate defensively: one line per file is the contract, and reporting one file
# twice reads as two leaked credentials.
found_secret_files="$(printf '%s' "$found_secret_files" | grep -v '^$' | sort -u || true)"

if [ -n "$found_secret_files" ]; then
    fail "credential or signing material present in the repository:"
    printf '%s\n' "$found_secret_files" | sed 's/^/           /' >&2
    hint "each file above may contain credential or signing material."
    hint "inspect it, then remove it or relocate it outside the repository before committing."
    hint "some key and certificate formats are already ignored, but do not assume this"
    hint "filename family is covered by .gitignore — check before you trust it."
    hint "a file that only looks like one — a pinned public certificate, a model named"
    hint "Credentials.swift — is excused by listing its exact path for the filename rule in"
    hint "${IOSAI_CREDENTIAL_ALLOWLIST}; a private key or signing material cannot be listed."
elif [ "$secret_name_incomplete" = "yes" ]; then
    # Already counted as a failure above. The point here is to not follow it with
    # a reassuring line about a scan that never finished.
    log_error "credential filename scan incomplete — no clean result is claimed"
else
    log_ok "no credential or signing files"
fi

# A content scan over every text file, not an extension list: a private key in
# `secret.key` or a provider token in a file with no extension is still a leaked
# credential. Binary files are skipped by grep -I.
#
# Each class is named so a failure can be reported without printing the match.
# The matched bytes are never echoed — a check that leaks the secret while
# reporting it has not helped. The class names live in Scripts/lib/common.sh
# (IOSAI_SECRET_CLASSES) beside the subset an allowlist entry may excuse; the
# patterns stay here, with the only scan that uses them.
secret_pattern_for() {
    case "$1" in
        private-key)         printf '%s' '-----BEGIN [A-Z ]*PRIVATE KEY-----' ;;
        openssh-private-key) printf '%s%s' '-----BEGIN OPENSSH ' 'PRIVATE KEY-----' ;;
        aws-access-key)      printf '%s' '(AKIA|ASIA)[0-9A-Z]{16}' ;;
        anthropic-key)       printf '%s' 'sk-ant-api[0-9]{2}-[A-Za-z0-9_-]{16}' ;;
        github-token)        printf '%s' '(gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22})' ;;
        slack-token)         printf '%s' 'xox[abprs]-[0-9A-Za-z-]{10}' ;;
        google-api-key)      printf '%s' 'AIza[0-9A-Za-z_-]{35}' ;;
        stripe-secret-key)   printf '%s' 'sk_live_[0-9a-zA-Z]{16}' ;;
        npm-token)           printf '%s' '_authToken=[A-Za-z0-9._-]{20}' ;;
        url-credentials)     printf '%s' '[a-z][a-z0-9+.-]*://[A-Za-z0-9._%+-]+:[^@/[:space:]]{4,}@' ;;
        *)                   return 1 ;;
    esac
}

secret_content=""
# Enumerate first, and check that the enumeration actually worked. `$(repo_files
# || true)` turned a failed walk — one unreadable directory is enough — into an
# empty file list, and the scan then reported "no embedded credentials" and
# passed. A scan that could not run is not a scan that found nothing.
secret_content_incomplete="no"
scan_files=""
if ! scan_files="$(repo_files 2>&1)"; then
    fail "could not enumerate repository files for the embedded-credential scan"
    printf '%s\n' "$scan_files" | sed 's/^/           /' >&2
    hint "the scan is inconclusive; fix the unreadable path and re-run"
    scan_files=""
    secret_content_incomplete="yes"
fi
# Readability is settled first, with shell builtins only — no process per file.
# An unreadable file is a scan that could not answer, exactly as before.
readable_scan_files=""
while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ ! -r "$f" ]; then
        fail "could not scan $(relpath "$f") for embedded credentials: not readable"
        secret_content_incomplete="yes"
        continue
    fi
    readable_scan_files="${readable_scan_files}${f}
"
done <<EOF
$scan_files
EOF
readable_scan_files="$(printf '%s' "$readable_scan_files" | grep -v '^$' || true)"

# One batched pass per class over the whole readable list, then line numbers only
# for the files that actually matched. Same files, same patterns, same fail-closed
# rule — the matched bytes still never enter a variable, because only grep's
# numeric prefix survives scan_matching_lines.
for class in $IOSAI_SECRET_CLASSES; do
    if ! class_pattern="$(secret_pattern_for "$class")"; then
        fail "the credential scan has no pattern for the class ${class}"
        secret_content_incomplete="yes"
        continue
    fi
    class_rc=0
    class_hits="$(printf '%s\n' "$readable_scan_files" \
        | scan_matching_files "$class_pattern")" || class_rc=$?
    if [ "$class_rc" -ne 0 ]; then
        fail "could not scan the repository for ${class} (scanner failed)"
        hint "an inconclusive credential scan is a failure, not a pass"
        secret_content_incomplete="yes"
        continue
    fi
    while IFS= read -r hit_file; do
        [ -n "$hit_file" ] || continue
        rel="$(relpath "$hit_file")"
        # Only the classes a shipped client key or a documentation URL can trip are
        # ever excused, and only for the exact path listed for that class.
        if token_in_list "$class" "$IOSAI_SECRET_CLASSES_EXEMPTABLE" \
           && credential_exempt "$rel" "$class" "$credential_exemptions"; then
            credential_exempted="${credential_exempted}${rel}: ${class}
"
            continue
        fi
        line_rc=0
        hit_lines="$(scan_matching_lines "$class_pattern" "$hit_file")" || line_rc=$?
        if [ "$line_rc" -ne 0 ]; then
            fail "could not locate ${class} inside ${rel} (scanner failed)"
            secret_content_incomplete="yes"
            continue
        fi
        while IFS= read -r lineno; do
            [ -n "$lineno" ] || continue
            secret_content="${secret_content}${rel}:${lineno}: ${class}
"
        done <<INNER
$hit_lines
INNER
    done <<HITS
$class_hits
HITS
done
secret_content="$(printf '%s' "$secret_content" | grep -v '^$' | sort -u || true)"

if [ -n "$secret_content" ]; then
    fail "possible embedded secret (path and pattern class only; the match is not printed):"
    printf '%s\n' "$secret_content" | sed 's/^/           /' >&2
    hint "move the credential out of the repository and rotate it — a secret that"
    hint "reached a working tree should be treated as exposed."
    hint "a client key designed to ship inside the app (google-api-key) or credentials"
    hint "in a documentation or fake test URL (url-credentials) is excused by listing that"
    hint "exact path and class in ${IOSAI_CREDENTIAL_ALLOWLIST}; no other class can be."
elif [ "$secret_content_incomplete" = "yes" ]; then
    log_error "embedded-credential scan incomplete — no clean result is claimed"
else
    log_ok "no embedded private keys, provider tokens, or credentials in URLs"
fi

credential_exempted="$(printf '%s' "$credential_exempted" | grep -v '^$' | sort -u || true)"
if [ -n "$credential_exempted" ]; then
    log_info "  excused by ${IOSAI_CREDENTIAL_ALLOWLIST}, one rule each; every other rule still applied:"
    printf '%s\n' "$credential_exempted" | sed 's/^/           /'
fi

# ---------------------------------------------------------------------------
# 4. Placeholders.
#
# Placeholders are expected in AI/ while the contracts are being filled in, so
# those are counted and reported. They are NOT acceptable in shipped source or
# in a product configuration, so those fail.
# ---------------------------------------------------------------------------
log_step "Placeholders"
PLACEHOLDER_RE='TBD|FIXME|REPLACE_ME|<FILL[ _-]?IN>|XXX_PLACEHOLDER|LOREM IPSUM|Lorem ipsum'

# Exact-path matching only. The allowlist's own structure — exact paths,
# non-shipping locations, a reason, an unexpired date — is validated by
# verify-template.sh, which runs first. It is read once, below, rather than
# re-parsed for every candidate file.

source_placeholders=""
source_placeholder_incomplete="no"
if [ -d "${IOSAI_ROOT}/App" ]; then
    # Enumerated with its status checked, for the same reason as the credential
    # scan above: a failed walk must not read as an empty result set.
    app_files=""
    if ! app_files="$(find "${IOSAI_ROOT}/App" -type f \( \
        -name '*.swift' -o -name '*.m' -o -name '*.mm' -o -name '*.h' \
        -o -name '*.plist' -o -name '*.strings' -o -name '*.stringsdict' \
        -o -name '*.xcstrings' -o -name '*.storyboard' -o -name '*.xib' \
        -o -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.xml' \
        -o -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.ts' \
        -o -name '*.metal' -o -name '*.intentdefinition' -o -name '*.entitlements' \
        -o -name '*.xcconfig' -o -name '*.pbxproj' -o -name '*.xcscheme' \
        -o -name '*.xctestplan' -o -name '*.storekit' \
    \) 2>&1)"; then
        fail "could not scan App/ for placeholder copy"
        printf '%s\n' "$app_files" | sed 's/^/           /' >&2
        hint "the scan is inconclusive; fix the unreadable path and re-run"
        app_files=""
        source_placeholder_incomplete="yes"
    fi
    # Exemptions and readability are settled with builtins only — the allowlist is
    # read once instead of once per file, and no process is spawned per file. The
    # remaining candidates go to one batched scan.
    allowlisted_paths="$(placeholder_allowlist_paths)"
    app_scan_files=""
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        rel="$(relpath "$f")"
        # Preview assets are allowed to contain instructional copy, but only
        # when the literal path component is exactly "Preview Content". A
        # whitespace-split component list once exempted every directory named
        # Content, including shipping App/Content sources.
        case "/${rel}/" in *"/Preview Content/"*) continue ;; esac
        # Exact-line containment with a shell pattern, not a pipeline: this decides
        # one file, and a `printf | grep -Fxq` here is a process per repository file
        # for a lookup the shell can do. The newlines around both operands keep it an
        # exact whole-path match, so `App/A.swift` is not matched by `App/AA.swift`.
        case "
${allowlisted_paths}
" in
            *"
${rel}
"*) continue ;;
        esac
        if [ ! -r "$f" ]; then
            fail "could not scan ${rel} for placeholder copy: not readable"
            source_placeholder_incomplete="yes"
            continue
        fi
        app_scan_files="${app_scan_files}${f}
"
    done <<EOF
$app_files
EOF
    app_scan_files="$(printf '%s' "$app_scan_files" | grep -v '^$' || true)"
    if [ -n "$app_scan_files" ]; then
        app_scan_rc=0
        app_hits="$(printf '%s\n' "$app_scan_files" \
            | scan_matching_files "$PLACEHOLDER_RE")" || app_scan_rc=$?
        if [ "$app_scan_rc" -ne 0 ]; then
            fail "could not scan App/ for placeholder copy (scanner failed)"
            source_placeholder_incomplete="yes"
        else
            while IFS= read -r f; do
                [ -n "$f" ] || continue
                source_placeholders="${source_placeholders}$(relpath "$f")
"
            done <<EOF
$app_hits
EOF
        fi
    fi
fi
source_placeholders="$(printf '%s' "$source_placeholders" | grep -v '^$' || true)"

if [ -n "$source_placeholders" ]; then
    fail "placeholder text in shipping application source, resources, or project metadata:"
    printf '%s\n' "$source_placeholders" | sed 's/^/           /' >&2
    hint "placeholder copy must never reach a build. finish it, or move it to AI/."
    hint "documented exceptions go in Config/placeholder-allowlist.txt"
elif [ "$source_placeholder_incomplete" = "yes" ]; then
    log_error "App/ placeholder scan incomplete — no clean result is claimed"
else
    log_ok "no placeholders in App/ sources"
fi

if [ "${IOSAI_CONFIG_PRESENT:-0}" -eq 1 ] && [ "$IOSAI_REPO_MODE" = "product" ]; then
    if grep -Eq -- "$PLACEHOLDER_RE" "$IOSAI_CONFIG_FILE" 2>/dev/null; then
        fail "placeholder text in Config/project.env"
        hint "the live build configuration must be real, not a sketch"
    else
        log_ok "no placeholders in Config/project.env"
    fi
fi

doc_placeholders=0
doc_incomplete="no"
ai_files=""
if ! ai_files="$(find "${IOSAI_ROOT}/AI" -type f -name '*.md' 2>&1)"; then
    fail "could not scan AI/ for placeholder copy"
    printf '%s\n' "$ai_files" | sed 's/^/           /' >&2
    hint "the count below would be understated, so this is a failure rather than a pass"
    ai_files=""
    doc_incomplete="yes"
fi
ai_scan_files=""
while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ ! -r "$f" ]; then
        fail "could not scan $(relpath "$f") for placeholder copy: not readable"
        doc_incomplete="yes"
        continue
    fi
    ai_scan_files="${ai_scan_files}${f}
"
done <<EOF
$ai_files
EOF
ai_scan_files="$(printf '%s' "$ai_scan_files" | grep -v '^$' || true)"
if [ -n "$ai_scan_files" ]; then
    ai_scan_rc=0
    ai_hits="$(printf '%s\n' "$ai_scan_files" \
        | scan_matching_files "$PLACEHOLDER_RE")" || ai_scan_rc=$?
    if [ "$ai_scan_rc" -ne 0 ]; then
        fail "could not scan AI/ for placeholder copy (scanner failed)"
        doc_incomplete="yes"
    else
        doc_placeholders="$(printf '%s' "$ai_hits" | grep -c '^..*$' || true)"
        [ -n "$doc_placeholders" ] || doc_placeholders=0
    fi
fi
if [ "$doc_incomplete" = "yes" ]; then
    log_error "AI/ placeholder scan incomplete — the count below is understated"
elif [ "$doc_placeholders" -gt 0 ]; then
    log_info "  ${doc_placeholders} document(s) under AI/ still contain placeholders."
    log_info "  Expected while contracts are being filled in; not a failure here."
    log_info "  Release verification checks the ones that matter for shipping."
else
    log_ok "no placeholders left under AI/"
fi

# ---------------------------------------------------------------------------
# 5. The development-only premium override.
#
# AI/ARCHITECTURE.md fixes two names — `DebugPremiumOverride` and the
# `forcePremium` defaults key — so that a gate can look for them at all. Wherever
# they appear under App/ they must sit in the true branch of `#if DEBUG`, which is
# what keeps the override out of a Release binary and REL-1101 true of every
# shipped build.
#
# This proves CONTAINMENT, never existence. A product that sells nothing has no
# override, and one that has not yet reached its entitlement milestone does not
# have it yet; both scan clean. Requiring the override to be PRESENT would fail
# every free app for work it does not owe — the same mistake recorded above about
# requiring `## Updating this template` in a product README, and the one that took
# three checks out of the legal and support change.
#
# A line-oriented grep cannot decide this: it cannot see which branch of a nested
# conditional a line sits in, and `#else` of `#if DEBUG` is precisely the branch
# that ships. So the region tracking is an awk state machine. Test bundles are
# excluded — they are not shipped, they build only in Debug, and a test that drives
# the override has no reason to guard itself.
# ---------------------------------------------------------------------------
log_step "Premium override containment"

OVERRIDE_NAMES='DebugPremiumOverride|forcePremium'

# Prints one `<file>:<line>: <reason>` per problem. Exit 0 clean, 1 problems
# printed, anything else a scanner failure the caller must not read as clean.
#
# `#elseif` is tested before `#else` because the `#else` pattern would otherwise
# match it. An unbalanced file is a problem rather than a pass: containment cannot
# be proved in a file whose directives do not nest.
read -r -d '' OVERRIDE_AWK <<'AWK' || true
# `#if DEBUG` and `#if DEBUG && anything` are guards: both are strictly narrower
# than DEBUG. `#if DEBUG || INTERNAL` is not — that region compiles when INTERNAL
# is set and DEBUG is not. Neither is `#if !RELEASE`, and that one matters most:
# no Xcode configuration defines RELEASE by default, so `!RELEASE` is TRUE in a
# Release build and guards nothing at all.
function isdebug(c) {
    gsub(/[[:space:]]/, "", c)
    if (index(c, "||") > 0) return 0
    if (c == "DEBUG") return 1
    if (substr(c, 1, 7) == "DEBUG&&") return 1
    return 0
}
function isnotdebug(c) {
    gsub(/[[:space:]]/, "", c)
    return (c == "!DEBUG") ? 1 : 0
}
function unguarded(  i) {
    for (i = 1; i <= depth; i++) if (guard[i] == 1) return 0
    return 1
}
function report_unbalanced() {
    if (prevfile != "" && depth != 0) {
        print prevfile ": unbalanced conditional compilation directives"
        bad = 1
    }
}
FNR == 1 { report_unbalanced(); depth = 0; block = 0; prevfile = FILENAME }
{
    prevfile = FILENAME
    # Comments are stripped before anything is matched, so a doc comment
    # explaining the override is documentation rather than a finding. A `//`
    # inside a string literal truncates the line, which can only ever miss a
    # finding — never invent one.
    line = $0; code = ""
    while (length(line) > 0) {
        if (block > 0) {
            c = index(line, "*/"); o = index(line, "/*")
            if (c > 0 && (o == 0 || c < o)) { block--; line = substr(line, c + 2); continue }
            if (o > 0) { block++; line = substr(line, o + 2); continue }
            line = ""; continue
        }
        o = index(line, "/*"); s = index(line, "//")
        if (s > 0 && (o == 0 || s < o)) { code = code substr(line, 1, s - 1); line = ""; continue }
        if (o > 0) { code = code substr(line, 1, o - 1); block++; line = substr(line, o + 2); continue }
        code = code line; line = ""
    }
}
code ~ /^[[:space:]]*#[[:space:]]*if([[:space:]]|$)/ {
    cond = code; sub(/^[[:space:]]*#[[:space:]]*if/, "", cond)
    depth++
    guard[depth]   = isdebug(cond)
    elsedbg[depth] = isnotdebug(cond)
    chained[depth] = 0
    next
}
code ~ /^[[:space:]]*#[[:space:]]*elseif([[:space:]]|$)/ {
    if (depth == 0) {
        print FILENAME ":" FNR ": #elseif without #if"
        bad = 1
        next
    }
    cond = code; sub(/^[[:space:]]*#[[:space:]]*elseif/, "", cond)
    guard[depth]   = isdebug(cond)
    chained[depth] = 1
    next
}
code ~ /^[[:space:]]*#[[:space:]]*else([[:space:]]|$)/ {
    if (depth == 0) {
        print FILENAME ":" FNR ": #else without #if"
        bad = 1
        next
    }
    # The #else of `#if DEBUG` is the branch that ships. The #else of `#if !DEBUG`
    # is the Debug one. After an #elseif chain nothing is claimed either way.
    guard[depth] = (chained[depth] == 1) ? 0 : elsedbg[depth]
    next
}
code ~ /^[[:space:]]*#[[:space:]]*endif([[:space:]]|$)/ {
    if (depth == 0) {
        print FILENAME ":" FNR ": #endif without #if"
        bad = 1
        next
    }
    depth--
    next
}
code ~ NAMES {
    if (unguarded()) {
        print FILENAME ":" FNR ": premium override outside #if DEBUG"
        bad = 1
    }
}
END { report_unbalanced(); exit (bad ? 1 : 0) }
AWK

override_incomplete="no"
override_problems=""
override_files=""
override_scan_files=()

if [ -d "${IOSAI_ROOT}/App" ]; then
    # Enumerated with its status checked, for the same reason as the scans above:
    # a failed walk must not read as an empty result set.
    if ! override_files="$(find "${IOSAI_ROOT}/App" -type f -name '*.swift' 2>&1)"; then
        fail "could not scan App/ for the premium override"
        printf '%s\n' "$override_files" | sed 's/^/           /' >&2
        hint "the scan is inconclusive; fix the unreadable path and re-run"
        override_files=""
        override_incomplete="yes"
    fi
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        rel="$(relpath "$f")"
        case "/${rel}/" in *"/Preview Content/"*) continue ;; esac
        # Not shipped, and Debug-only already: a test target that drives the
        # override would otherwise have to wrap itself to satisfy this.
        case "/${rel}" in */*Tests/*) continue ;; esac
        if [ ! -r "$f" ]; then
            fail "could not scan ${rel} for the premium override: not readable"
            override_incomplete="yes"
            continue
        fi
        override_scan_files[${#override_scan_files[@]}]="$f"
    done <<EOF
$override_files
EOF
fi

if [ "${#override_scan_files[@]}" -gt 0 ]; then
    override_batch_size="${IOSAI_SCAN_BATCH:-200}"
    override_index=0
    while [ "$override_index" -lt "${#override_scan_files[@]}" ]; do
        override_batch=( "${override_scan_files[@]:override_index:override_batch_size}" )
        override_rc=0
        override_out="$(awk -v NAMES="$OVERRIDE_NAMES" "$OVERRIDE_AWK" \
            "${override_batch[@]}")" || override_rc=$?
        case "$override_rc" in
            0) : ;;
            1) override_problems="${override_problems}${override_out}
" ;;
            *)
                fail "premium override scan failed (scanner exited ${override_rc})"
                override_incomplete="yes" ;;
        esac
        override_index=$(( override_index + override_batch_size ))
    done
fi

override_problems="$(printf '%s' "$override_problems" | grep -v '^$' || true)"
if [ -n "$override_problems" ]; then
    fail "the premium override is reachable outside #if DEBUG:"
    printf '%s\n' "$override_problems" | sed "s|^${IOSAI_ROOT}/|           |" >&2
    hint "wrap it in #if DEBUG — a Release build must not contain it at all"
    hint "#if !RELEASE is not a guard: no configuration defines RELEASE by default,"
    hint "so that region is exactly what compiles into the shipped build"
    hint "the contract is the premium override paragraph in AI/ARCHITECTURE.md"
elif [ "$override_incomplete" = "yes" ]; then
    log_error "premium override scan incomplete — no clean result is claimed"
elif [ "${#override_scan_files[@]}" -eq 0 ]; then
    # Saying "clean" about a scan that read nothing is the one outcome this file
    # refuses everywhere else. The template repository has no App/ sources at all.
    log_skip "premium override scan (no shipped Swift sources under App/)"
else
    log_ok "no premium override outside #if DEBUG"
fi

# ---------------------------------------------------------------------------
# 6. Hard-coded prices and currency.
#
# AI/ARCHITECTURE.md fixes the rule: every price a person sees is the loaded
# StoreKit product's own localized formatting, and a comparison is computed from the
# real products rather than authored. What that forbids is a price or a currency
# symbol written into the build — "$9.99" in a view, "4,99 €" in a string catalog,
# or "$\(price)" assembling one by hand out of a symbol and a number.
#
# This is the defect nobody sees. A wrong guard fails a build; a hard-coded price
# renders perfectly for the developer who typed it, in the storefront they use, in
# the currency they think in. It is wrong only for everybody else, and it reaches
# the content audit at the far end of the project or the App Store after that.
#
# It proves CONTAINMENT, never existence: a product that sells nothing, or one whose
# paywall milestone has not run yet, has no price to display and scans clean. String
# catalogs are scanned with the sources because a price typed there is the copy a
# translator is handed. Test bundles and Preview Content are excluded — neither
# ships, and a fixture naming a price is how a test for this rule would be written.
# ---------------------------------------------------------------------------
log_step "Price literals"

# Passed to awk as a list rather than a character class: macOS awk matches these by
# byte sequence, and `$` is a regex metacharacter, so every comparison below is
# index() and substr() over literal strings instead of a built regex.
PRICE_SYMBOLS='$ € £ ¥ ₹ ₩ ₽'

# Prints one `<file>:<line>: <reason>` per problem. Exit 0 clean, 1 problems
# printed, anything else a scanner failure the caller must not read as clean.
read -r -d '' PRICE_AWK <<'AWK' || true
# Three shapes, and only three. Each one requires a real amount or a real
# interpolation next to the symbol, which is what keeps the legitimate idioms out:
# Swift's `$0` closure shorthand, `$binding` property wrappers, "%1$@" and other
# positional specifiers, "$HOME", and "\(product.displayPrice)" all reach here and
# none of them matches.
function has_price(code, s,   at, tail, head, off) {
    off = 0
    while (1) {
        at = index(substr(code, off + 1), s)
        if (at == 0) return 0
        at = off + at
        tail = substr(code, at + length(s))
        head = substr(code, 1, at - 1)
        # A symbol, then an amount: "$9.99", "€ 4,99", "$19".
        #
        # Two digits, not one, for the whole-number form. `$0` and `$1` are Swift's
        # closure shorthand and appear in ordinary code on every second screen, and
        # a gate that failed `map { $0.price }` would be deleted within the week.
        # A whole price below ten is the one this misses, and it misses it on
        # purpose.
        if (tail ~ /^ ?[0-9]+[.,][0-9]/) return 1
        if (tail ~ /^ ?[0-9][0-9]/) return 1
        # A symbol, then an interpolation: a hard-coded currency around a real price.
        if (substr(tail, 1, 2) == "\\(") return 1
        # An amount, then a symbol: "4,99 €". Decimals only in this direction: the
        # whole-number form would collide with "%12$@" and the positional specifier
        # is worth more than the European whole price nobody writes.
        if (head ~ /[0-9][.,][0-9]+ ?$/) return 1
        off = at + length(s) - 1
    }
}
BEGIN { nsym = split(SYMBOLS, sym, " ") }
FNR == 1 { block = 0 }
{
    # Comments are stripped before anything is matched, as in the override scan
    # above, so a doc comment or a translator's note quoting a price is
    # documentation rather than a finding. A `//` inside a string literal truncates
    # the line, which can only ever miss a finding — never invent one.
    line = $0; code = ""
    while (length(line) > 0) {
        if (block > 0) {
            c = index(line, "*/"); o = index(line, "/*")
            if (c > 0 && (o == 0 || c < o)) { block--; line = substr(line, c + 2); continue }
            if (o > 0) { block++; line = substr(line, o + 2); continue }
            line = ""; continue
        }
        o = index(line, "/*"); slash = index(line, "//")
        if (slash > 0 && (o == 0 || slash < o)) { code = code substr(line, 1, slash - 1); line = ""; continue }
        if (o > 0) { code = code substr(line, 1, o - 1); block++; line = substr(line, o + 2); continue }
        code = code line; line = ""
    }
    for (i = 1; i <= nsym; i++) {
        if (has_price(code, sym[i])) {
            print FILENAME ":" FNR ": hard-coded price or currency symbol"
            bad = 1
            break
        }
    }
}
END { exit (bad ? 1 : 0) }
AWK

price_incomplete="no"
price_problems=""
price_files=""
price_scan_files=()

if [ -d "${IOSAI_ROOT}/App" ]; then
    # Enumerated with its status checked, for the same reason as the scans above:
    # a failed walk must not read as an empty result set.
    if ! price_files="$(find "${IOSAI_ROOT}/App" -type f \
        \( -name '*.swift' -o -name '*.strings' -o -name '*.stringsdict' \
           -o -name '*.xcstrings' \) 2>&1)"; then
        fail "could not scan App/ for hard-coded prices"
        printf '%s\n' "$price_files" | sed 's/^/           /' >&2
        hint "the scan is inconclusive; fix the unreadable path and re-run"
        price_files=""
        price_incomplete="yes"
    fi
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        rel="$(relpath "$f")"
        case "/${rel}/" in *"/Preview Content/"*) continue ;; esac
        case "/${rel}" in */*Tests/*) continue ;; esac
        if [ ! -r "$f" ]; then
            fail "could not scan ${rel} for hard-coded prices: not readable"
            price_incomplete="yes"
            continue
        fi
        price_scan_files[${#price_scan_files[@]}]="$f"
    done <<EOF
$price_files
EOF
fi

if [ "${#price_scan_files[@]}" -gt 0 ]; then
    price_batch_size="${IOSAI_SCAN_BATCH:-200}"
    price_index=0
    while [ "$price_index" -lt "${#price_scan_files[@]}" ]; do
        price_batch=( "${price_scan_files[@]:price_index:price_batch_size}" )
        price_rc=0
        price_out="$(awk -v SYMBOLS="$PRICE_SYMBOLS" "$PRICE_AWK" \
            "${price_batch[@]}")" || price_rc=$?
        case "$price_rc" in
            0) : ;;
            1) price_problems="${price_problems}${price_out}
" ;;
            *)
                fail "price literal scan failed (scanner exited ${price_rc})"
                price_incomplete="yes" ;;
        esac
        price_index=$(( price_index + price_batch_size ))
    done
fi

price_problems="$(printf '%s' "$price_problems" | grep -v '^$' || true)"
if [ -n "$price_problems" ]; then
    fail "a price or a currency symbol is written into the build:"
    printf '%s\n' "$price_problems" | sed "s|^${IOSAI_ROOT}/|           |" >&2
    hint "every price is the loaded StoreKit product's own localized formatting,"
    hint "and a comparison is computed from the real products rather than typed"
    hint "the contract is the price presentation paragraph in AI/ARCHITECTURE.md"
elif [ "$price_incomplete" = "yes" ]; then
    log_error "price literal scan incomplete — no clean result is claimed"
elif [ "${#price_scan_files[@]}" -eq 0 ]; then
    # As above: a scan that read nothing has not earned the word clean.
    log_skip "price literal scan (no shipped sources or string catalogs under App/)"
else
    log_ok "no hard-coded price or currency symbol under App/"
fi

# ---------------------------------------------------------------------------
# 7. Test repetition written into the project.
#
# The strict gates refuse -retry-tests-on-failure, -test-iterations and
# -run-tests-until-failure as arguments (assert_test_args_report_failures), because a
# test that failed and then passed on a retry is reported as failed=0 and the counts
# stop describing the run. A committed test plan asks Xcode for exactly the same thing
# with "testRepetitionMode" : "retryOnFailure", and an audit reproduced it against
# real Xcode: a test that failed its first attempt produced total=2 passed=2
# failed=0, exit 0, and a published VERIFIED_COMMIT, with nothing on the command line
# at all. The rule is about the run, not about where the setting is written, so the
# committed configuration is checked here — on every `make static`, the optional
# pre-commit hook, and the first stage of every strict gate.
#
# Every enabled mode is refused, matching the argument rule: retryOnFailure,
# untilFailure and fixedIterations. "none" is Xcode's own spelling of off, and
# maximumTestRepetitions on its own changes nothing, so neither is a finding. Test
# plans are where Xcode keeps this setting; schemes are read too, so a repetition
# attribute written into one cannot become the way around the rule. A file that
# mentions the setting in a form this scan cannot read is refused rather than
# assumed off.
# ---------------------------------------------------------------------------
log_step "Test repetition"

repetition_incomplete="no"
repetition_problems=""
repetition_files=""
repetition_scanned=0
if ! repetition_files="$(repo_files -name '*.xctestplan' -o -name '*.xcscheme' 2>&1)"; then
    fail "could not enumerate test plans and schemes for test repetition"
    printf '%s\n' "$repetition_files" | sed 's/^/           /' >&2
    hint "the scan is inconclusive; fix the unreadable path and re-run"
    repetition_files=""
    repetition_incomplete="yes"
fi
while IFS= read -r f; do
    [ -n "$f" ] || continue
    rel="$(relpath "$f")"
    if [ ! -r "$f" ]; then
        fail "could not scan ${rel} for test repetition: not readable"
        repetition_incomplete="yes"
        continue
    fi
    repetition_scanned=$((repetition_scanned + 1))
    mention_rc=0
    grep -q 'testRepetitionMode' "$f" 2>/dev/null || mention_rc=$?
    case "$mention_rc" in
        0) : ;;
        1) continue ;;
        *)
            fail "could not scan ${rel} for test repetition (scanner exited ${mention_rc})"
            repetition_incomplete="yes"
            continue ;;
    esac
    # Test plans are JSON ("key" : "value"); a scheme would carry an XML attribute
    # (key = "value"). Both shapes are read, one value per occurrence.
    modes_rc=0
    modes="$(grep -oE '"?testRepetitionMode"?[[:space:]]*[:=][[:space:]]*"[^"]*"' "$f" 2>/dev/null)" \
        || modes_rc=$?
    if [ "$modes_rc" -gt 1 ]; then
        fail "could not scan ${rel} for test repetition (scanner exited ${modes_rc})"
        repetition_incomplete="yes"
        continue
    fi
    if [ -z "$modes" ]; then
        repetition_problems="${repetition_problems}${rel}: testRepetitionMode in a form this scan cannot read
"
        continue
    fi
    while IFS= read -r mode; do
        [ -n "$mode" ] || continue
        value="${mode%\"}"
        value="${value##*\"}"
        case "$value" in
            none) : ;;
            *)
                repetition_problems="${repetition_problems}${rel}: testRepetitionMode ${value}
" ;;
        esac
    done <<EOF
$modes
EOF
done <<EOF
$repetition_files
EOF

repetition_problems="$(printf '%s' "$repetition_problems" | grep -v '^$' || true)"
if [ -n "$repetition_problems" ]; then
    fail "committed test configuration repeats failing tests, so the counts would describe a rerun:"
    printf '%s\n' "$repetition_problems" | sed 's/^/           /' >&2
    hint "set Test Repetition Mode to None in the test plan, and fix the unreliable test instead"
    hint "this is the rule that refuses -retry-tests-on-failure, -test-iterations and"
    hint "-run-tests-until-failure, applied to the setting when it is written into the project"
elif [ "$repetition_incomplete" = "yes" ]; then
    log_error "test repetition scan incomplete — no clean result is claimed"
elif [ "$repetition_scanned" -eq 0 ]; then
    log_skip "test repetition scan (no test plans or schemes in the repository)"
else
    log_ok "no committed test plan or scheme repeats a failing test"
fi

# ---------------------------------------------------------------------------
# 8. Optional Swift / shell tooling.
#
# Opt-in only. Enabled but missing is a FAILURE with install instructions: a
# check that cannot run is not a check that passed. Nothing is auto-installed.
# ---------------------------------------------------------------------------
log_step "Optional tooling"

run_optional_tool() {
    local enabled="$1" tool="$2"
    shift 2
    if [ "$enabled" != "true" ]; then
        log_skip "${tool} (not enabled; set ENABLE_$(printf '%s' "$tool" | tr '[:lower:]' '[:upper:]')=\"true\" to use it)"
        return 0
    fi
    if ! command -v "$tool" >/dev/null 2>&1; then
        fail "${tool} is enabled in Config/project.env but not installed"
        case "$tool" in
            swiftlint)   hint "install it: brew install swiftlint" ;;
            swiftformat) hint "install it: brew install swiftformat" ;;
            shellcheck)  hint "install it: brew install shellcheck" ;;
        esac
        hint "or set ENABLE_$(printf '%s' "$tool" | tr '[:lower:]' '[:upper:]')=\"false\" — but then it is not being checked"
        return 0
    fi
    log_step "${tool}"
    if "$@"; then
        log_ok "${tool} clean"
    else
        fail "${tool} reported problems"
    fi
}

run_optional_tool "${ENABLE_SWIFTLINT:-false}" swiftlint \
    swiftlint lint --quiet --strict
run_optional_tool "${ENABLE_SWIFTFORMAT:-false}" swiftformat \
    swiftformat --lint .
# The root reaches `sh` as a POSITIONAL argument, never interpolated into the
# script text. Splicing it in closed and reopened the single quoting three times,
# so a repository path containing an apostrophe — ordinary in a user directory
# name — produced a command that no longer parsed. Spaces were always safe; a
# quote was not.
run_optional_tool "${ENABLE_SHELLCHECK:-false}" shellcheck \
    sh -c 'shellcheck --severity=warning "$1"/Scripts/*.sh "$1"/Scripts/lib/*.sh "$1"/.githooks/pre-commit' \
    sh "$IOSAI_ROOT"

# ---------------------------------------------------------------------------
# 9. The published legal and support site.
#
# Cheap, offline, and structural, so it belongs in the gate a developer runs
# constantly rather than only in the slow one. It deliberately does NOT scan the
# site for placeholder copy: those pages are unfilled from M00 until the Legal and
# Support milestone runs, and failing every milestone gate in between would punish
# a product for work that is not due yet. No gate scans the pages for placeholders
# at all — verify-release.sh records why — so an unfilled page stops a candidate
# through the final audit instead: REL-801 and, for an App Store product, REL-503
# and REL-1008 must be VERIFIED in the consolidated record, and none of them may be
# recorded as INAPPLICABLE.
# ---------------------------------------------------------------------------
printf '\n'
if ! "${_script_dir}/verify-site.sh"; then
    fail "site verification failed (see above)"
fi

# Product-specific extension graph (no simulator required).
if [ -f "${_script_dir}/verify-launcher.py" ]; then
    if ! python3 "${_script_dir}/verify-launcher.py"; then
        fail "Watch launcher configuration failed"
    fi
    if ! python3 -m unittest discover -s "${_script_dir}/tests" -p test_launcher.py; then
        fail "Watch launcher gate regression tests failed"
    fi
fi

# ---------------------------------------------------------------------------
# 10. Milestone bookkeeping.
# ---------------------------------------------------------------------------
printf '\n'
log_step "Milestones"
if ! "${_script_dir}/project-status.sh" validate; then
    fail "milestone validation failed (see above)"
fi

# ---------------------------------------------------------------------------
printf '\n'
if [ "$FAILURES" -gt 0 ]; then
    log_error "static verification FAILED — ${FAILURES} problem(s)"
    exit "$EX_VERIFY"
fi
log_ok "static verification PASSED"
