# D5 — nebula-cloud-platform · Detailed Completion Plan

*Source evidence: reports/nebula-cloud-platform.md (statically verified 2026-08-24) · nodes D5-1..D5-DEPLOY
from deployment_ready_minimum_diff_plan.md · intent from project_intent_analysis.md §D5.*

---

## 0. Identity

| Field | Value |
|---|---|
| Local path | `C:\Users\thela\Downloads\projects context\Magnificent-Seven\nebula-cloud-platform` |
| Remote | `github.com/nithin12342/nebula-cloud-platform` |
| Branch | `master` (synced 2026-08-25) |
| Intent | Azure infrastructure as versioned composable Terraform modules with sensible defaults, policy hooks, toggle switches — reviewed, testable infra code |
| Input → Output | terraform.tfvars (CIDRs/SKUs/toggles) + env secrets → module composition with count toggles → plan files → applied resources + outputs; CI verdicts per PR |
| Deploy target | validate/checkov green CI (free) + ONE minimal student-tier apply of vnet+storage+keyvault only, destroyed same day |
| Verdict at study time | 🟡 Partial — best of platform batch but cannot plan as committed: required vars lack defaults, AKS module has hard type error, invalid azurerm args, example CIDRs lie outside address space |
| Estimated effort | ~1 day incl. capped apply |

## 1. Verified defect inventory

| # | Defect | Exact location | Reproduced? |
|---|---|---|---|
| B1 | Required vars no defaults, no tfvars.example anywhere → every plan aborts | `variables.tf:33` (`sql_admin_password`), `:53` (`azure_tenant_id`) | ✅ deep-read |
| B2 | Undeclared attribute ref breaks EVERY consumer of aks module | `modules/aks/main.tf:65` (`var.default_node_pool.os_cache_size_gb` not in object type `variables.tf:53-79`) | ✅ type cross-check |
| B3 | `outbound_type` invalid inside default_node_pool block | `modules/aks/main.tf:68` | ✅ schema check |
| B4 | Embedded kubernetes provider reads `kube_admin_config[0]` — empty under azure_rbac_enabled=true (module default) → runtime index failure; antipattern | `modules/aks/main.tf:159-163` | ✅ inspection |
| B5 | maintenance_window day numeric vs azurerm string weekday | `modules/aks/main.tf:118-123` | ✅ inspection |
| B6 | Example subnets outside declared address_space | `examples/basic-vnet/main.tf:30,35` (10.0.1.0/24, 10.0.2.0/24 ⊄ 10.0.0.0/24) | ✅ inspection |
| B7 | `delegate_to = ""` treated as real delegation (empty service name) | `examples/basic-vnet/main.tf:36,41` + root default `variables.tf:14` | ✅ inspection |
| B8 | "40+ tests" claim ≈ 20 terratest funcs that apply BILLABLE Azure infra (~$0.25/hr × parallel) ; zero .tftest.hcl suites exist | `CI_RESULTS.md`, `tests/unit/*.go` (aks_test.go has 5) | ✅ func count |
| B9 | modules/apim + cost-management orphaned (own providers/RGs, not wired into root) | `modules/apim`, `modules/cost-management` | ✅ inspection |

## 2. Node plan

### P0 RUN-FIX

**Node D5-1 — root plans possible**
```
GOAL      : terraform init && terraform validate exit 0 at root.
LOCATION  : variables.tf:33,53 · NEW terraform.tfvars.example
MIN-DIFF  : add defaults or TF_VAR_ env marking for sql_admin_password/azure_tenant_id;
            example tfvars with placeholders
VERIFY    : terraform init && terraform validate   (terraform portable install first)
EXPECTED  : exit 0. Artifact: verification/d5-1_validate.txt
NOTE      : toolchain gate — install terraform CLI locally before this batch starts
SIBLINGS  : none yet
```

**Node D5-2..D5-3 — AKS module type-safe & valid**
```
GOAL      : aks module validates and passes checkov with zero HIGH findings.
LOCATION  : modules/aks/main.tf:65 (drop os_cache_size_gb ref), :68 (remove outbound_type
            from default_node_pool), :118-123 (day → string weekday),
            :159-163 (delete embedded kubernetes provider block; kubeconfig output
            responsibility moves to root)
MIN-DIFF  : four targeted edits, one commit each preferred
VERIFY    : terraform validate in modules/aks + examples/aks-cluster && checkov -d modules/
EXPECTED  : both green, zero HIGH. Artifacts: verification/d5-2_validate.txt, d5-3_checkov.txt
SIBLINGS  : re-run D5-1 root validate after each edit (POST-FIX scope: only edited file)
```

**Node D5-4 — example CIDRs valid**
```
GOAL      : basic-vnet example plans subnets inside its address space; empty delegation
            means null.
LOCATION  : examples/basic-vnet/main.tf:30,35,36,41 + root variables.tf:14
MIN-DIFF  : address_space → 10.0.0.0/16; delegation: each.value.delegate_to != "" ? … : null
VERIFY    : terraform validate + plan shows subnets within space. Artifact: verification/d5-4_plan.txt
TAG       : ckpt-runs   (all validates green)
```

### P1 VERIFY

**Node D5-5 — credential-free test suites**
```
GOAL      : terraform test runs green locally WITHOUT ARM creds.
LOCATION  : NEW tests/*.tftest.hcl per core module (validate-level assertions);
            Go terratest moved behind workflow_dispatch with cost warning
MIN-DIFF  : convert 2-3 highest-value terratest assertions to .tftest.hcl cases
VERIFY    : terraform test
EXPECTED  : green, $0 spent. Artifact: verification/d5-5_tftest.txt
```

**Node D5-6 — claims honest**
```
GOAL      : CI_RESULTS.md states actual counts and billing caveat.
LOCATION  : CI_RESULTS.md
MIN-DIFF  : doc-only diff: correct "40+ tests"→actual count; note terratest applies billable infra
VERIFY    : doc review. Artifact: verification/d5-6_notes.md
TAG       : ckpt-tested   (after CI wiring: existing .github/workflows/terraform.yml already
            runs fmt/validate/checkov — confirm green run)
```

### P3 DEPLOY

**Node D5-DEPLOY — capped real apply**
```
GOAL      : prove modules apply against real Azure WITHOUT burning student credit.
LOCATION  : throwaway tfvars: enable_aks=false enable_sql=false enable_redis=false
            enable_functions=false (vnet+storage+keyvault ONLY)
VERIFY    : az group list shows RG; cost alert set at $5; terraform destroy clean
            (no orphaned RGs re-checked via az group list)
PROOF     : screenshots + destroy transcript → verification/d5_deploy_proof/. Tag ckpt-deployed.
ROADMAP    : wire apim/cost-management into root or move to examples · Infracost PR checks ·
            module version tags + CHANGELOG · AKS deploy behind ACA consumption alternative
```

## 3. Out of scope (ROADMAP)

AKS/SQL/Redis applies on student credit ($100 burns in days at Standard defaults) · LocalStack
azurerm emulation (needs Docker) · full terratest suite in CI (billable).

## 4. Execution contract

POST-FIX scope check per node · sibling gates re-run before tags · evidence committed atomically ·
tags pushed same day · toolchain: terraform portable zip (install when batch starts); checkov via pip.

## 5. P4 — PRODUCTION READINESS DELTA (target: `prod-ready` tag, L4 — IaC track)

Current level after P3 ≈ L3. For IaC, "production" means state safety + drift control.
| Cat | Gap | Node | VERIFY artifact |
|---|---|---|---|
| G3 | Local/default state — no remote backend, no locking (two appliers = corruption) | D5-P4a: Azure storage remote backend + locking configured; concurrent-plan lock test | backend config + lock transcript |
| G2 | SP permissions unscoped; tfvars secret handling informal | D5-P4b: least-privilege SP doc + TF_VAR_ env pattern enforced; grep for plaintext secrets clean | role assignment export |
| G4 | checkov advisory; drift undetected | D5-P4c: HIGH findings fail CI; scheduled `terraform plan -detailed-exitcode` drift detection job opens issue on drift | failing-check screenshot + drift issue |
| G6/G8 | Module versioning/tags + CHANGELOG absent | D5-P4d: tag modules v0.1.0 + CHANGELOG.md generated from commits | tags + changelog |
| G7 | Cost guardrail manual | D5-P4e: budget alert as code ($5) applied with the stack | alert resource in state |

TRACK=product-IaC.

### P4 audit addendum (production-readiness pass)
| Cat | Declared semantics | Node | VERIFY artifact |
|---|---|---|---|
| G1/G5 | Adapted for IaC: "reliability" = deterministic plans (already G3 state safety); "observability" = drift-detection job + plan notifications (exists as D5-P4c) — no separate node | declared, not new work | — |
| UB | Universal Baseline UB1-UB6 applies (UB6 = scheduled drift/cost job monitor; UB3 = checkov+tfsec already serve as IaC scanners — add tfsec pin proof) | D5-P4f: LICENSE (Apache-2.0), gitleaks job, scanner version pins, README badge row with module registry | per-UB artifacts |

