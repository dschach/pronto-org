# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Salesforce DX project (`pronto-org`) backing the Pronto merchant/ordering platform. The repo's center of gravity is **Agentforce**: most Apex is invocable actions consumed by two agents, and the LWCs are merchant-facing UI. There are no triggers — server-side logic lives in `@InvocableMethod`s called from agent topics.

- `sfdx-project.json`: single package dir `force-app`, sourceApiVersion `66.0`, no namespace, login URL `login.salesforce.com`.
- Scratch org definition: `config/project-scratch-def.json`.

## Commands

Install deps with `npm install` (Husky is wired via `prepare`). Common scripts:

| Task                                                  | Command                                                                                                                          |
| ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Run LWC Jest tests                                    | `npm run test:unit`                                                                                                              |
| Single LWC test (watch / debug / coverage)            | `npm run test:unit:watch` · `test:unit:debug` · `test:unit:coverage`                                                             |
| Run one LWC test file                                 | `npx sfdx-lwc-jest --skipApiVersionCheck -- path/to/file.test.js`                                                                |
| Run Apex tests in default org (writes `testresults/`) | `npm run apex:test`                                                                                                              |
| Run a single Apex test class                          | `sf apex run test --class-names ClassNameTest --result-format human --code-coverage`                                             |
| Lint LWC/Aura JS                                      | `npm run lint`                                                                                                                   |
| Format / check format                                 | `npm run prettier` · `npm run prettier:verify`                                                                                   |
| Show default org                                      | `npm run myinfo`                                                                                                                 |
| Regenerate code-analyzer config                       | `npm run codeanalyzer:config`                                                                                                    |
| Run Code Analyzer (all rules)                         | `sf code-analyzer run --config-file code-analyzer.yml --rule-selector all --output-file code-analyzer.json`                      |
| Run Code Analyzer (ESLint rules only, table view)     | `sf code-analyzer run --rule-selector eslint --output-file code-analyzer.json --view table`                                      |
| Run SLDS linter                                       | `npx @salesforce-ux/slds-linter@latest lint force-app/main/default/lwc` (single dir arg only — no brace-expansion or multi-path) |

Deploy/retrieve use the Salesforce CLI directly (e.g. `sf project deploy start`, `sf project retrieve start`) — there are no npm wrappers for these.

`precommit` runs via Husky (`.husky/pre-commit` → `npm run precommit` → `lint-staged`): Prettier on all supported filetypes, ESLint on Aura/LWC JS, and `sfdx-lwc-jest --findRelatedTests` for touched LWCs. Don't bypass it.

## Architecture

### Agentforce is the product

Two agents live in `force-app/main/default/`:

- **`bots/Merchant_Management_Agent/`** + **`aiAuthoringBundles/Merchant_Management_Agent/`** — employee agent (`AgentforceEmployeeAgent`) for managing storefronts, menus, promotions, gift certificates. The `.agent` file under `aiAuthoringBundles` is the Agent Script source of truth; the `bots/` folder is the compiled/deployed form. Treat `.agent` as the authoring surface.
- **`bots/Merchant_Support_Agent/`** + **`messagingChannels/Merchant_Support_Agent.messagingChannel-meta.xml`** — customer-facing support agent on a Messaging channel.
- `aiAuthoringBundles/Merchant_Management_Agent_2/` is a second variant of the management agent — check which one is current before editing.

The Agentforce Development Life Cycle (ADLC) plugin is installed. Use its skills (`developing-agentforce`, `testing-agentforce`, `observing-agentforce`) and agents (`adlc-author`, `adlc-engineer`, `adlc-qa`, `adlc-orchestrator`) for agent work rather than hand-editing `.agent` files blind.

### Apex = invocable actions for the agent

Every non-boilerplate Apex class is named `Agent*Actions.cls` and follows a strict shape — mirror it for new actions:

- Inner `Request` class with `@InvocableVariable` fields.
- Inner `Response` class (often with `success` / `errorMessage` plus domain fields) and a nested DTO (e.g. `CaseSummary`) to avoid flaky SObject-collection serialization in the invocation surface.
- Single `@InvocableMethod` entry point. Many are **singleton actions** that only process `requests[0]` and return one `Response` — this is intentional; don't "fix" it to bulk unless the agent topic actually passes batches.
- Test partners are either per-class (`AgentUpdateContactRecordActionsTest.cls`) or the shared `AgentActionsTest.cls`.

Non-agent Apex is mostly the stock Communities/Site auth controllers (`CommunitiesLoginController`, `LightningSelfRegisterController`, etc.), plus `MenuBrowserController`, `MenuDescriptionPromptGrounding` (prompt grounding for AI-generated menu copy), `MenuUploadTypes`, and `GetDataFromRTDatagraph`. `force-app/main/default/triggers/` is empty by design.

### LWCs

Under `force-app/main/default/lwc/`: `prontoHome`, `prontoProfileCard`, `menuBrowser`, `menuUpload`, `apiCalloutTool`, `realTimeEngagements`, `relatedIndividualsModal`, `testFeedbackEditor`, `genericPageHeader`. These are the merchant UI surfaced in the app. LWC Jest is configured via `jest.config.js` extending `@salesforce/sfdx-lwc-jest/config`.

### Permission sets and access

Agent access is gated by dedicated permission sets: `Merchant_Management_Agent_Access`, `Merchant_Support_Agent_Permissions`, `Agentforce_Action_Access`, `Agentforce_Actions`, `Agentforce_Reference_App`. When adding a new invocable action, add it to the appropriate perm set or the agent will fail to call it at runtime.

### Custom objects

`force-app/main/default/objects/` is currently empty in source — the schema (Storefront, Menu, Menu Item, Promotion, Gift Certificate, etc.) lives in the org and isn't tracked here. Retrieve object metadata explicitly when you need to reason about fields.

## Conventions

- Prettier config is `@x2od/prettier-config` with `prettier-plugin-apex` and `@prettier/plugin-xml`. `.prettierrc` is the source of truth — run `npm run prettier` rather than relying on editor defaults, especially for `.cls` and `.xml`.
- ESLint uses flat config (`eslint.config.js`) with separate blocks for Aura, LWC, LWC tests, and jest-mocks. Lint failures block commits via lint-staged.
- **Stock Communities auth Aura components** (`aura/loginForm/`, `aura/selfRegister/`, `aura/forgotPassword/`) are ignored by both `eslint.config.js` and `code-analyzer.yml` — they're vendor boilerplate, don't try to clean up their lint noise. The `lint` npm script uses `--no-error-on-unmatched-pattern` since all Aura JS is now in those ignored dirs.
- **Unused `@wire` destructure params** — convention is to prefix with `_` (e.g. `wiredX({ error: _error, data })`). The LWC ESLint block sets `no-unused-vars` with `argsIgnorePattern: '^_'` so `_`-prefixed names are intentional.
- PMD config lives in `config/pmd.xml` + `config/ruleset.xml`. Salesforce Code Analyzer config is `code-analyzer.yml` (regenerate with `npm run codeanalyzer:config`, don't hand-edit except for narrowly-targeted overrides). Code Analyzer is configured with `auto_discover_eslint_config: true` so it honors the project's `eslint.config.js` — keep them in sync rather than duplicating rule settings.
- **SLDS 2 CSS linting** is an **ESLint plugin** (`@salesforce-ux/eslint-plugin-slds`), not stylelint. Inline suppressions in `.css` files must use `/* eslint-disable-next-line @salesforce-ux/slds/<rule-id> */` — `stylelint-disable-next-line` is a no-op here. For the common `no-hardcoded-values-slds2` rule, prefer suppression over removing layout values (`100%`, `180px`, etc.) per the `uplifting-components-to-slds2` skill's "leave as-is" guidance.
- `.forceignore` deliberately ignores `package.xml`, LWC `jsconfig.json`/`.eslintrc.json`, and `__tests__/`. Don't commit these or deploy them.
