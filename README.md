<div align="center">

<img src="assets/logo.png" width="180" alt="ΩmegaWiki Logo">

# ΩmegaWiki

### Karpathy's LLM-Wiki Vision, Fully Realized

**Your AI Research Platform — From Papers to Publications, Powered by [Claude Code](https://docs.anthropic.com/en/docs/claude-code)**

*From paper ingestion to publication — your research knowledge compounds, never decays.*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python 3.9+](https://img.shields.io/badge/Python-3.9+-yellow.svg)](https://www.python.org/)
[![Skills](https://img.shields.io/badge/Skills-28-purple.svg)](#skills)
[![Claude Code](https://img.shields.io/badge/Powered_by-Claude_Code-d97706.svg)](https://docs.anthropic.com/en/docs/claude-code)
[![Bilingual](https://img.shields.io/badge/i18n-EN_|_VI-orange.svg)](#bilingual-support)

</div>

## What is ΩmegaWiki?

Andrej Karpathy proposed LLM-Wiki: an LLM that **builds and maintains a persistent, structured wiki** from your sources — not a throwaway RAG answer, but compounding knowledge that grows smarter with every paper you feed it.

**ΩmegaWiki takes that idea and runs the full distance.** It's not just a wiki builder — it's a complete research lifecycle platform: from paper ingestion → knowledge graph → gap detection → idea generation → experiment design → paper writing → peer review response. All driven by 28 Claude Code skills, all centered on one wiki as the single source of truth.

Drop your `.tex` / `.pdf` files in a folder. Run one command. Get a fully cross-referenced knowledge base — and then use it to **generate novel research ideas, design experiments, write papers, and respond to reviewers**.

## Why Wiki-Centric, Not RAG?

| | RAG | ΩmegaWiki |
|---|---|---|
| **Knowledge persistence** | Rediscovered on every query | Compiled once, maintained forever |
| **Structure** | Flat chunk store | 9 typed entities with relationships |
| **Cross-references** | None — chunks are isolated | Bidirectional wikilinks + typed graph |
| **Knowledge gaps** | Invisible | Explicitly tracked, drive research |
| **Failed experiments** | Lost | First-class anti-repetition memory |
| **Output** | Chat answers | Papers, surveys, experiment plans, rebuttals |
| **Compounding** | No — same cost every query | Yes — each paper enriches the whole graph |

## Architecture

<div align="center">
<img src="assets/architecture.png" width="700" alt="ΩmegaWiki Architecture">
</div>

Every skill reads from and writes back to the wiki. Knowledge compounds — each new paper enriches the whole graph. Failed experiments aren't discarded; they become anti-repetition memory that prevents re-exploring dead ends.

## Quick Start

**Prerequisites:** Python 3.9+, Node.js 18+

```bash
# 1. Clone
git clone https://github.com/KITTran/OmegaWiki.git
cd OmegaWiki

# 2. Install Claude Code
npm install -g @anthropic-ai/claude-code
claude login

# 3. One-click setup (choose one)
chmod +x setup.sh && ./setup.sh                   # .venv (default)
#   or
./setup.sh --env conda                            # conda env 'omegawiki'
#   or
./setup.sh --lang vi                              # Vietnamese + .venv

# 4. Put your own papers in raw/papers/ (.tex or .pdf)
#    Optional: add intent notes to raw/notes/ and saved pages to raw/web/
#    /init and direct local /ingest will manage generated inputs under raw/discovered/ and raw/tmp/

# 5. Build your wiki
claude
# Then type: /init [your-research-topic]
```

<details>
<summary><b>Manual setup with .venv (Linux / macOS)</b></summary>

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env                 # Edit to add API keys
cp config/settings.local.json.example .claude/settings.local.json
```

</details>

<details>
<summary><b>Manual setup with conda</b></summary>

```bash
conda create -n omegawiki python=3.11 && conda activate omegawiki
pip install -r requirements.txt
cp .env.example .env                 # Edit to add API keys
cp config/settings.local.json.example .claude/settings.local.json
```

</details>

<details>
<summary><b>Manual setup with .venv (Windows / PowerShell)</b></summary>

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env          # Edit to add API keys
Copy-Item config\settings.local.json.example .claude\settings.local.json
```

Note: native Windows is supported for the local pipeline. Remote-GPU
experiments via `/exp-run --env remote` rely on `ssh`/`rsync`/`screen`
and are best run from WSL2 or Linux/macOS.

</details>

### API Keys

| Key | Required? | How to get | What it enables |
|-----|-----------|-----------|-----------------|
| `ANTHROPIC_API_KEY` | **Yes** | `claude login` (automatic) | Powers all Claude Code skills |
| `SEMANTIC_SCHOLAR_API_KEY` | Optional | [semanticscholar.org/product/api](https://www.semanticscholar.org/product/api) (free) | Citation graph, paper search |
| `DEEPXIV_TOKEN` | Optional | `setup.sh` auto-registers | Semantic search, TLDR, trending |
| `LLM_API_KEY` + `LLM_BASE_URL` + `LLM_MODEL` | Optional | Any OpenAI-compatible API | Cross-model review |

> **Cross-model review**: ΩmegaWiki uses a second LLM as an independent reviewer for ideas, experiments, and paper drafts. Works with **any OpenAI-compatible API** — DeepSeek, OpenAI, Qwen, OpenRouter, SiliconFlow, etc. If not configured, skills still work in Claude-only mode.

## Skills

28 slash commands spanning the full research lifecycle:

### Phase 0: Setup

| Command | What it does |
|---------|-------------|
| `/setup` | First-time configuration (API keys, language, dependencies) |
| `/reset <scope>` | Destructive cleanup: `wiki \| raw \| log \| checkpoints \| all` |
| `/update-skill` | Update or extend an existing skill definition |
| `/translated-engine` | Translate skill content across languages |

### Phase 1: Knowledge Foundation

| Command | What it does |
|---------|-------------|
| `/prefill <domain>` | Optionally seed `foundations/` with background knowledge |
| `/init [topic]` | Bootstrap a full wiki from user raw sources plus optional discovery |
| `/ingest <source>` | Parse a paper → wiki pages + cross-references |
| `/discover` | Recommend ranked next-read papers from anchors, a topic, or the current wiki |
| `/edit <request>` | Add/remove sources or update wiki content |
| `/ask <question>` | Query the wiki, crystallize answers back |
| `/check` | Health scan: broken links, missing cross-refs, consistency |

### Phase 2: Research Pipeline

| Command | What it does |
|---------|-------------|
| `/daily-arxiv` | Auto-fetch & filter new arXiv papers (+ GitHub Actions cron) |
| `/ideate` | Multi-phase idea generation from cross-topic connections |
| `/novelty <idea>` | Multi-source novelty verification (web + S2 + wiki + review LLM) |
| `/review <artifact>` | Cross-model adversarial review for any research artifact |
| `/exp-design <idea>` | Claim-driven experiment + ablation design |
| `/exp-run <experiment>` | Implement + deploy + monitor (local or remote GPU) |
| `/exp-status` | Dashboard for running experiments; auto-collect results |
| `/exp-eval <experiment>` | Verdict gate → auto-update claims/ideas/graph |
| `/refine <artifact>` | Multi-round: produce → review → fix → re-review |

### Phase 3: Writing & Submission

| Command | What it does |
|---------|-------------|
| `/survey` | Generate Related Work from wiki knowledge |
| `/paper-plan <claims>` | Outline from claim graph + evidence matrix |
| `/paper-draft <plan>` | Draft LaTeX + figures, section by section |
| `/paper-compile <dir>` | Compile → PDF, auto-fix, verify page/anonymity |
| `/research <direction>` | End-to-end orchestrator with human gates |
| `/rebuttal <reviews>` | Parse reviewer comments → draft point-by-point responses |
| `/create-slides` | Generate presentation slides from wiki content |
| `/create-ppt` | Generate .pptx slide decks from papers or outlines |

## Wiki Structure

### 9 Entity Types

| Type | Directory | Purpose |
|------|-----------|---------|
| **Paper** | `papers/` | Structured summary with problem/method/results/limitations |
| **Concept** | `concepts/` | Cross-paper technical concept with variants and comparisons |
| **Topic** | `topics/` | Research direction map with SOTA tracker and open problems |
| **Person** | `people/` | Researcher profile with key papers and collaborators |
| **Idea** | `ideas/` | Research idea with lifecycle: proposed → tested → validated/failed |
| **Experiment** | `experiments/` | Full record: hypothesis → setup → results → claim updates |
| **Claim** | `claims/` | Testable claim with evidence list and confidence score |
| **Summary** | `Summary/` | Domain-wide survey across topics |
| **Foundation** | `foundations/` | Background knowledge (terminal: receives inward links, writes none) |

### Knowledge Graph

Semantic relationships are stored in `graph/edges.jsonl`; bibliographic paper citations are stored separately in `graph/citations.jsonl`.

Paper-paper semantic edges include `same_problem_as`, `similar_method_to`, `complementary_to`, `builds_on`, `compares_against`, `improves_on`, `challenges`, and `surveys`. Paper-concept edges use `introduces_concept`, `uses_concept`, `extends_concept`, and `critiques_concept`. Existing claim / experiment / idea / provenance edges remain available where appropriate.

All pages use **Obsidian `[[wikilink]]` format** — open `wiki/` in Obsidian for visual graph exploration.

## Automation

**GitHub Actions** runs `/daily-arxiv` at UTC 00:00 daily:

1. Add `ANTHROPIC_API_KEY` to repo **Settings → Secrets**
2. `.github/workflows/daily-arxiv.yml` fetches arXiv, runs ingestion, auto-commits

## Project Structure

```
OmegaWiki/
├── CLAUDE.md                    # Runtime schema & rules
├── wiki/                        # Knowledge base (LLM-maintained)
│   ├── papers/                  #   Structured paper summaries
│   ├── concepts/                #   Cross-paper technical concepts
│   ├── topics/                  #   Research direction maps
│   ├── people/                  #   Researcher profiles
│   ├── ideas/                   #   Research ideas (with lifecycle)
│   ├── experiments/             #   Experiment records
│   ├── claims/                  #   Testable research claims
│   ├── Summary/                 #   Domain-wide surveys
│   ├── foundations/             #   Background knowledge (terminal pages)
│   ├── outputs/                 #   Generated artifacts
│   ├── graph/                   #   Auto-generated: edges, context, gaps
│   ├── index.md                 #   Content catalog
│   └── log.md                   #   Chronological log
├── raw/                         # Source materials
│   ├── papers/                  #   User-owned .tex / .pdf files
│   ├── discovered/              #   /init and /daily-arxiv-downloaded external papers
│   ├── tmp/                     #   generated prepared local sidecars for /init and direct local /ingest
│   ├── notes/                   #   User-owned .md notes
│   └── web/                     #   User-owned HTML / Markdown
├── tools/                       # Deterministic Python helpers
│   ├── research_wiki.py         #   Wiki engine (20 CLI commands)
│   ├── init_discovery.py        #   /init prepare + plan + fetch helper
│   ├── discover.py              #   /discover candidate gathering, dedup, ranking
│   ├── lint.py                  #   Structural validation (10 checks)
│   ├── reset_wiki.py            #   Scoped destructive cleanup helper
│   ├── fetch_arxiv.py           #   arXiv RSS fetcher
│   ├── fetch_s2.py              #   Semantic Scholar API
│   ├── fetch_deepxiv.py         #   DeepXiv semantic search
│   ├── fetch_wikipedia.py       #   Wikipedia fetcher (used by /prefill)
│   └── remote.py                #   SSH ops for remote experiments
├── .claude/skills/              # 28 Claude Code skill definitions
├── i18n/                        # Bilingual: en/ (canonical) + zh/ + vi/
├── config/                      # Configuration templates
├── mcp-servers/                 # Cross-model review server
└── .github/workflows/           # Daily arXiv cron
```


## Bilingual Support

ΩmegaWiki ships in English, Chinese, and Vietnamese:

```bash
./setup.sh --lang en   # English (default)
./setup.sh --lang zh   # Chinese
./setup.sh --lang vi   # Vietnamese
```

---

## Roadmap

- [x] Wiki knowledge engine (20+ CLI commands, 9 entity types, semantic graph + citation layer)
- [x] 28 Claude Code skills (full research lifecycle)
- [x] Cross-model review (any OpenAI-compatible API)
- [x] Daily arXiv automation (GitHub Actions)
- [x] Remote GPU experiment support
- [x] Bilingual i18n (EN + ZH + VI)
- [ ] Demo dataset (example wiki with pre-ingested papers)
- [ ] LaTeX venue templates (NeurIPS, ICML, ACL, etc.)
- [ ] Multi-user collaboration
- [ ] More language support

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## LLM API Configuration

ΩmegaWiki runs on **Claude Code**, which speaks the **Anthropic API** protocol. You can use Claude directly, or route Claude Code to any third-party provider that exposes an Anthropic-compatible endpoint by overriding a few environment variables.

### Option A — Native Claude

```bash
claude login   # OAuth, no manual config
```

### Option B — Third-party Anthropic-compatible API

Pick a provider below, paste the snippet into `~/.claude/settings.json` (or the project's `.claude/settings.json`), and replace the `<...>` placeholder with your own API key. Model names and extra options are taken from each provider's official Claude Code docs — if anything stops working (e.g. a model is renamed), check the provider's website.

#### MiMo

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.xiaomimimo.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "<your-mimo-key>",
    "ANTHROPIC_MODEL": "mimo-v2.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "mimo-v2.5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "mimo-v2.5-pro",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "mimo-v2.5"
  }
}
```

#### DeepSeek

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "<your-deepseek-key>",
    "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  }
}
```

#### Kimi (Moonshot)

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.moonshot.ai/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "<your-moonshot-key>",
    "ANTHROPIC_MODEL": "kimi-k2.5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "kimi-k2.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "kimi-k2.5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "kimi-k2.5",
    "CLAUDE_CODE_SUBAGENT_MODEL": "kimi-k2.5",
    "ENABLE_TOOL_SEARCH": "false"
  }
}
```

#### GLM (Z.AI)

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "<your-zai-key>",
    "API_TIMEOUT_MS": "3000000"
  }
}
```

> Z.AI applies a default server-side model mapping, so no explicit `ANTHROPIC_MODEL` is needed.

**Skip the Claude Code onboarding**

When using a third-party key (instead of `claude login`), Claude Code's first-run onboarding won't complete automatically. Create or edit `.claude.json` and mark it done:

- macOS / Linux: `~/.claude.json`
- Windows: `<user-home>\.claude.json`

```json
{
  "hasCompletedOnboarding": true
}
```

Then run `claude` as usual.

---


## Acknowledgments

- **Andrej Karpathy** — for the LLM-Wiki concept that inspired this project
- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — the AI agent runtime that powers ΩmegaWiki
- **[Original repository](https://github.com/skyllwt/OmegaWiki)** — the public ancestor of this fork

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=skyllwt/OmegaWiki&type=Date)](https://star-history.com/#skyllwt/OmegaWiki&Date)

## License

[MIT](LICENSE) — use it, fork it, build on it.

