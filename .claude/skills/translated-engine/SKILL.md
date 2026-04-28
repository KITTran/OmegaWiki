--- 
description: Technical translation engine that preserves context, meaning, tone, and technical keywords across languages (en/vi/zh). Translates skill documentation, shared references, and wiki content while maintaining consistency with existing terminology and project conventions.
argument-hint: <source-path> <target-lang> [--dry-run] [--force]
---

# /translated-engine

> Technical translation engine for ΩmegaWiki. Translates skill documentation, shared references, and wiki content while preserving:
> - Context and domain-specific meaning
> - Technical tone and academic rigor
> - Keywords that must remain untranslated (commands, flags, paths, API names, field names)
> - Markdown structure and code blocks
> - Cross-language consistency with existing translations

## Inputs

- `source-path`: path to the source file to translate (must be within `i18n/en/`, `i18n/vi/`, or `i18n/zh/`)
- `target-lang`: target language code (`en`, `vi`, or `zh`)
- `--dry-run` (optional): preview translation without writing to disk
- `--force` (optional): overwrite existing target file without confirmation

## Outputs

- Translated file written to the corresponding path in the target language directory
- Translation report (printed to terminal) containing:
  - List of preserved technical terms (commands, flags, paths, API names, field names)
  - Markdown structure validation results
  - Consistency warnings (if any terminology conflicts with existing translations)

## Wiki Interaction

### Reads
- Source file specified in `source-path`
- All existing files in the target language directory (`i18n/<target-lang>/`) for consistency checking
- `i18n/en/CLAUDE.md`, `i18n/vi/CLAUDE.md`, and `i18n/zh/CLAUDE.md` for project conventions
- `docs/runtime-page-templates.md` for Markdown structure rules

### Writes
- Translated file to `i18n/<target-lang>/<relative-path>` (only if not in `--dry-run` mode)
- No modifications to wiki content or graph files

## Workflow

### Step 1: Pre-Translation Analysis
1. **Validate inputs**:
   - Confirm `source-path` exists and is within an i18n directory
   - Confirm `target-lang` is one of `en`, `vi`, or `zh`
   - Check if target file already exists (unless `--force` is specified)

2. **Extract technical keywords**:
   - Identify all commands (e.g., `/ingest`, `/exp-run`)
   - Identify all flags (e.g., `--discover`, `--full`)
   - Identify all paths (e.g., `wiki/papers/`, `raw/discovered/`)
   - Identify all API names, field names, and enum values (e.g., `DEEPXIV_TOKEN`, `supports`, `contradicts`)
   - Identify all wikilinks (e.g., `[[slug]]`, `[[flash-attention]]`)
   - Identify all code blocks and inline code

3. **Consistency check**:
   - Compare identified keywords against existing translations in `i18n/<target-lang>/`
   - Flag any inconsistencies with existing terminology
   - Generate a list of terms that must remain untranslated

### Step 2: Translation

1. **Preserve structure**:
   - Maintain all Markdown elements (headings, lists, tables, blockquotes, code fences)
   - Preserve YAML frontmatter exactly as-is
   - Preserve all technical keywords identified in Step 1

2. **Context-aware translation**:
   - For each paragraph/section, analyze surrounding context to determine:
     - Domain (ML research, experiment design, paper writing, etc.)
     - Tone (technical, academic, instructional)
     - Intended audience (researchers, developers)
   - Apply domain-specific translation rules:
     | Domain | Translation Approach |
     |--------|----------------------|
     | Commands/Flags | Keep original (e.g., `/ingest --discover` → `/ingest --discover`) |
     | Technical Terms | Keep original if established in field (e.g., "LoRA", "attention mechanism") |
     | Academic Writing | Adapt to target language academic conventions |
     | Error Messages | Translate while preserving technical precision |

3. **Handle special cases**:
   - **Wikilinks**: Preserve slug format, only translate display text if appropriate
     ```markdown
     [[flash-attention]] → [[flash-attention]] (unchanged)
     [[lora-low-rank-adaptation|LoRA]] → [[lora-low-rank-adaptation|LoRA]] (unchanged)
     ```
   - **Code blocks**: Preserve exactly as-is, including comments
   - **JSON/YAML**: Preserve all keys and enum values, only translate string values when appropriate
   - **Tables**: Translate content while maintaining alignment and formatting
   - **Placeholders**: Preserve all placeholders (e.g., `{slug}`, `{date}`)

### Step 3: Post-Translation Validation

1. **Markdown validation**:
   - Verify all headings have matching levels
   - Verify all lists are properly indented
   - Verify all code fences are properly closed
   - Verify all tables are properly formatted

2. **Consistency validation**:
   - Re-check all preserved keywords against existing translations
   - Verify no accidental translations of technical terms
   - Verify all wikilinks use correct slug format

3. **Context validation**:
   - Sample key sections to ensure meaning and tone are preserved
   - Verify that technical instructions remain actionable
   - Verify that academic arguments maintain their logical flow

### Step 4: Output

1. If `--dry-run` is specified:
   - Print the translated content to terminal
   - Print the translation report
   - Do not write to disk

2. If `--dry-run` is not specified:
   - Write translated content to target path
   - Print the translation report to terminal
   - If target file existed, create backup with `.bak` extension

## Translation Rules

### Must Keep Untranslated
- Commands: `/ingest`, `/exp-run`, `/paper-draft`, etc.
- Flags: `--discover`, `--full`, `--env`, `--difficulty`, etc.
- Paths: `wiki/papers/`, `raw/discovered/`, `experiments/code/`, etc.
- API names: `DEEPXIV_TOKEN`, `SEMANTIC_SCHOLAR_API_KEY`, etc.
- Field names: `target_claim`, `evidence`, `confidence`, `slug`, etc.
- Edge types: `supports`, `contradicts`, `tested_by`, `invalidates`, etc.
- Enum values: `ready`, `needs-work`, `major-revision`, `rethink`, etc.
- File extensions: `.md`, `.tex`, `.pdf`, `.jsonl`, etc.
- Code identifiers: variable names, function names, class names
- Wikilinks: `[[slug]]` format must be preserved
- Placeholders: `{slug}`, `{date}`, `{score}`, etc.

### Must Translate
- Descriptive text explaining concepts, instructions, or arguments
- Academic phrases and transitions
- Error messages and user prompts
- Section headings and list items
- Table content (while preserving formatting)
- Blockquote content

### Conditional Translation
- **Technical terms**: Only translate if there is an established, widely-accepted translation in the target language. Otherwise, keep original.
  - Example (English → Vietnamese):
    - "attention mechanism" → "cơ chế attention" (keep English)
    - "gradient descent" → "hạ gradient" (translate)
- **Acronyms**: Keep original if commonly used in the field (e.g., "LoRA", "SOTA"), otherwise expand and translate.
- **Citations**: Keep citation keys untranslated, but translate surrounding text if appropriate.

## Consistency Enforcement

1. **Terminology database**: Maintain an internal database of translated terms that updates with each translation:
   ```json
   {
     "commands": {
       "/ingest": {"en": "/ingest", "vi": "/ingest", "zh": "/ingest"},
       "/exp-run": {"en": "/exp-run", "vi": "/exp-run", "zh": "/exp-run"}
     },
     "flags": {
       "--discover": {"en": "--discover", "vi": "--discover", "zh": "--discover"},
       "--full": {"en": "--full", "vi": "--full", "zh": "--full"}
     },
     "terms": {
       "confidence": {"en": "confidence", "vi": "độ tin cậy", "zh": "置信度"},
       "evidence": {"en": "evidence", "vi": "bằng chứng", "zh": "证据"}
     }
   }
   ```

2. **Consistency checking**: Before translating any term, check against the terminology database:
   - If term exists in database, use the established translation
   - If term doesn't exist, determine whether it should be translated or preserved, then add to database
   - Flag any conflicts with existing translations

3. **Project-wide consistency**:
   - When translating a term for the first time, search all existing files in the target language for potential conflicts
   - Maintain consistency with terms already established in:
     - `i18n/<lang>/CLAUDE.md`
     - `docs/runtime-page-templates.md`
     - Existing skill documentation

## Error Handling

- **Source file not found**: List similar files in the source directory
- **Invalid target language**: List valid language codes (`en`, `vi`, `zh`)
- **Target file exists**: Prompt for confirmation unless `--force` is specified
- **Markdown parsing error**: Attempt to recover structure, flag problematic sections
- **Terminology conflict**: Flag conflict and suggest resolution options
- **Translation service unavailable**: Fall back to local translation with warning

## Dependencies

### Tools (via Bash)
- `grep` - for searching existing translations
- `diff` - for comparing with existing files

### Claude Code Native
- `Read` - read source files and existing translations
- `Write` - write translated files
- `Glob` - search for existing translations

### Shared References
- None

## Constraints

- **Preservation requirements**:
  - Never translate commands, flags, paths, API names, field names, or enum values
  - Never modify Markdown structure or code blocks
  - Never change the meaning or technical accuracy of the content
  - Never break existing functionality or references

- **Consistency requirements**:
  - Maintain consistency with existing translations in the target language
  - Update terminology database with new translations
  - Flag any conflicts with existing terminology

- **Safety requirements**:
  - Always create backup before overwriting existing files
  - Never modify files outside the i18n directory structure
  - Never translate files that aren't skill documentation or shared references

- **Performance requirements**:
  - For large files (>50KB), translate in chunks to avoid context window limits
  - Cache terminology database between translations
  - Provide progress updates for large translations

## Example Usage

```bash
# Translate the ingest skill to Vietnamese
/translated-engine i18n/en/skills/ingest/SKILL.md vi

# Preview translation of experiment design skill to Chinese without writing
/translated-engine i18n/en/skills/exp-design/SKILL.md zh --dry-run

# Force overwrite existing Vietnamese translation of review skill
/translated-engine i18n/en/skills/review/SKILL.md vi --force
```

## Example Translation Report

```
Translation Report: i18n/en/skills/ingest/SKILL.md → i18n/vi/skills/ingest/SKILL.md

Preserved Terms (24):
- Commands: /ingest, /discover
- Flags: --discover, --full, --env
- Paths: wiki/papers/, raw/discovered/, experiments/code/
- APIs: DEEPXIV_TOKEN, SEMANTIC_SCHOLAR_API_KEY
- Fields: target_claim, evidence, confidence, slug
- Edge types: supports, contradicts, tested_by
- Wikilinks: [[slug]], [[flash-attention]]

Markdown Validation:
- Headings: OK (5/5)
- Lists: OK (12/12)
- Tables: OK (2/2)
- Code blocks: OK (4/4)

Consistency Warnings (1):
- Term "confidence" previously translated as "độ tin cậy" in i18n/vi/skills/exp-eval/SKILL.md
  → Using established translation

Translation Summary:
- Words translated: 1,248
- Technical terms preserved: 24
- Markdown elements preserved: 38
- Translation time: 42s
```