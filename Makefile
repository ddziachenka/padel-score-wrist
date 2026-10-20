# Makefile — discoverable entry points for the local workflow.
#
# Every target is a thin wrapper around a script in Scripts/. The scripts are
# the real interface: they take options, print actionable failures, and preserve
# their exit codes. Make is here so `make help` can show you the map.
#
# NOTE ON EXIT CODES: GNU make exits 2 on any recipe failure, so a script's
# precise exit code (for example 65 = blocked, 1 = failed) does not survive
# `make`. The verdict is printed on the console and written to the report; run
# the script directly when you need the exact code.

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

.PHONY: help setup initialize install-hooks uninstall-hooks template-check static fast milestone integration \
        release worktree status site-check site-deploy self-test clean-artifacts clean-derived-data

help: ## Show this help
	@printf '\n'
	@printf 'ios-ai-development-template — local workflow\n'
	@printf '\n'
	@printf 'All verification runs on this Mac. GitHub is storage only; there are no\n'
	@printf 'GitHub Actions. A push is backup/synchronization and does not verify code.\n'
	@printf '\n'
	@printf 'Targets:\n'
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@printf '\n'
	@printf 'Typical sequence:\n'
	@printf '  make setup                      validate the template (hooks stay optional)\n'
	@printf "  make initialize OWNER='Name' EMAIL='you@example.com'\n"
	@printf '  ./Scripts/configure-project.sh --project App/YourApp.xcodeproj --scheme YourApp\n'
	@printf '                                  add --platform iOS|watchOS --simulator-device-type ID --simulator-runtime ID\n'
	@printf '  make simulator-setup            prepare this checkout before running gates\n'
	@printf '  make fast                       Debug build and fast tests\n'
	@printf '  make milestone ID=M00          clean-HEAD milestone boundary\n'
	@printf '  git push                        optional backup/synchronization only\n'
	@printf '  make integration CANDIDATE=<full-sha>  # only after combining streams\n'
	@printf '  make release CANDIDATE=<full-sha>\n'
	@printf '  make worktree LOCALE=de         one language, after the release candidate\n'
	@printf '\n'

setup: ## Validate the template; do not install optional hooks
	@./Scripts/verify-template.sh
	@printf '\n'
	@printf 'Setup complete.\n'
	@printf '\n'
	@printf 'Next, initialize the project repository before adding product or Xcode files:\n'
	@printf "  make initialize OWNER='Your Name' EMAIL='you@example.com'\n"

initialize: ## Replace template history in the primary checkout (requires OWNER and EMAIL)
ifndef OWNER
	$(error OWNER is required, for example: make initialize OWNER='Your Name' EMAIL='you@example.com')
endif
ifndef EMAIL
	$(error EMAIL is required, for example: make initialize OWNER='Your Name' EMAIL='you@example.com')
endif
	@./Scripts/initialize-project.sh --confirm-new-project --owner "$(OWNER)" --email "$(EMAIL)"

install-hooks: ## Optionally enable the static-only pre-commit hook
	@./Scripts/install-git-hooks.sh

uninstall-hooks: ## Disable this template's optional pre-commit hook
	@./Scripts/install-git-hooks.sh --uninstall

template-check: ## Validate the template itself (no Xcode project needed)
	@./Scripts/verify-template.sh

static: ## Repository-level checks: no build, no simulator
	@./Scripts/verify-static.sh

fast: ## Development loop: Debug build + fast tests
	@./Scripts/verify-fast.sh

milestone: ## Verify a clean-HEAD milestone — requires ID; CANDIDATE is optional history mode
ifndef ID
	$(error ID is required, for example: make milestone ID=M00)
endif
	@if [ -n "$(CANDIDATE)" ]; then \
		./Scripts/verify-milestone.sh "$(ID)" --candidate "$(CANDIDATE)"; \
	else \
		./Scripts/verify-milestone.sh "$(ID)"; \
	fi

integration: ## Verify an immutable integration candidate — requires CANDIDATE
ifndef CANDIDATE
	$(error CANDIDATE is required, for example: make integration CANDIDATE=$$(git rev-parse HEAD))
endif
	@./Scripts/verify-integration.sh --candidate "$(CANDIDATE)"

release: ## Verify a fully audited immutable candidate; success is READY_FOR_HUMAN
ifndef CANDIDATE
	$(error CANDIDATE is required, for example: make release CANDIDATE=$$(git rev-parse HEAD))
endif
ifneq ($(origin REQUIRE_MANUAL),undefined)
	$(error REQUIRE_MANUAL was removed; release always requires complete workflow readiness)
endif
	@./Scripts/verify-release.sh --candidate "$(CANDIDATE)" || { \
		status=$$?; \
		printf '\n'; \
		printf 'make: ./Scripts/verify-release.sh --candidate ... exited %s.\n' "$$status"; \
		printf 'make reports its own exit code (2); the verdict above and the report\n'; \
		printf 'under .artifacts/release/ carry the precise result.\n'; \
		printf '  65 = NOT_READY (audit coverage or readiness state is incomplete),\n'; \
		printf '       or the candidate could not be resolved or validated\n'; \
		printf '   1 = VERIFICATION_FAILED\n'; \
		printf '  64 = invalid invocation or a removed release interface\n'; \
		printf '  69 = prerequisite unavailable; a run report may not exist\n'; \
		printf 'The FAIL line above states which of these happened; this list only\n'; \
		printf 'expands the code, because make cannot pass it through.\n'; \
		if [ -f .artifacts/release/latest.txt ]; then \
			printf 'latest report directory: '; sed -n '1p' .artifacts/release/latest.txt; \
		else \
			printf 'no .artifacts/release/latest.txt was published for this attempt\n'; \
		fi; \
		exit $$status; \
	}

worktree: ## Create the localization worktree for one language — requires LOCALE
ifndef LOCALE
	$(error LOCALE is required, for example: make worktree LOCALE=de)
endif
	@./Scripts/create-worktree.sh "$(LOCALE)"

status: ## Project state: phase, milestones, next available milestone
	@./Scripts/project-status.sh summary

site-check: ## Check the published legal and support site (offline; no network)
	@./Scripts/verify-site.sh

# `make static` runs site-check on every invocation; publishing remains an explicit
# operation and nothing invokes site-deploy as part of verification.
site-deploy: ## Publish Web/ to Cloudflare Pages (PRODUCTION=1 for the live site)
	@./Scripts/deploy-site.sh $(if $(PRODUCTION),--production,) $(if $(DRY_RUN),--dry-run,)

self-test: ## Run the template's own regression suite (fixtures; no Xcode needed)
	@./Scripts/self-test.sh

clean-artifacts: ## Remove local verification evidence under .artifacts/
	@./Scripts/clean-artifacts.sh

clean-derived-data: ## Remove this worktree's disposable build cache
	@./Scripts/clean-derived-data.sh

.PHONY: simulator-setup simulator-status simulator-boot simulator-shutdown simulator-context
simulator-setup: ## Create or reuse this checkout's managed simulator
	@./Scripts/simulator.sh setup
simulator-status: ## Show the owned simulator and current state
	@./Scripts/simulator.sh status
simulator-boot: ## Boot only this checkout's managed simulator
	@./Scripts/simulator.sh boot
simulator-shutdown: ## Shut down only this checkout's managed simulator
	@./Scripts/simulator.sh shutdown
simulator-context: ## Print simulator context as JSON for tools and agents
	@./Scripts/simulator.sh context
