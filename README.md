# GraphQL Federation Skill for AI Coding Assistants

**Teach your AI coding assistant to write correct GraphQL Federation schemas** — works with Claude Code, Cursor, Windsurf, Cline, and other agentic coding tools.

Stop fighting composition errors. This skill gives AI assistants deep knowledge of federation directives (`@key`, `@shareable`, `@external`, `@requires`, `@provides`, `@override`, `@inaccessible`, `@interfaceObject`), composition rules, and real-world patterns for building distributed GraphQL APIs with WunderGraph Cosmo or Apollo Federation.

## Why Use This Skill?

AI coding assistants often struggle with GraphQL Federation because:
- Federation directives have subtle rules that aren't intuitive
- Composition errors are cryptic without deep knowledge of validation rules
- Best practices for entity design and cross-subgraph references aren't obvious

This skill provides your AI assistant with:
- Complete directive specifications and valid usage patterns
- All composition validation rules and how to fix violations
- Real-world patterns for multi-subgraph architectures
- Authorization patterns with `@authenticated` and `@requiresScopes`
- Progressive migration strategies with `@override`

## Installation

### Claude Code

Claude Code automatically discovers skills from `.claude/skills/` directories. Copy the skill files to your project or personal skills folder:

**Project-level** (for this project only):
```bash
# Clone and copy to your project
git clone https://github.com/wundergraph/graphql-federation-skill.git /tmp/gql-fed-skill
mkdir -p .claude/skills/graphql-federation
cp /tmp/gql-fed-skill/SKILL.md .claude/skills/graphql-federation/
cp -r /tmp/gql-fed-skill/references .claude/skills/graphql-federation/
```

**Personal** (available across all your projects):
```bash
# Clone and copy to your personal skills folder
git clone https://github.com/wundergraph/graphql-federation-skill.git /tmp/gql-fed-skill
mkdir -p ~/.claude/skills/graphql-federation
cp /tmp/gql-fed-skill/SKILL.md ~/.claude/skills/graphql-federation/
cp -r /tmp/gql-fed-skill/references ~/.claude/skills/graphql-federation/
```

Claude Code will automatically detect and use the skill when working with GraphQL Federation. You can also invoke it directly with `/graphql-federation`.

### Cursor

Cursor uses project rules stored in `.cursor/rules/` as markdown files. The legacy `.cursorrules` file is deprecated.

```bash
# Clone and copy to your project
git clone https://github.com/wundergraph/graphql-federation-skill.git /tmp/gql-fed-skill
mkdir -p .cursor/rules
cp /tmp/gql-fed-skill/SKILL.md .cursor/rules/graphql-federation.md
```

Optionally, add frontmatter to control when the rule applies:

```yaml
---
description: "GraphQL Federation patterns and directives for subgraph development"
globs: ["**/*.graphql", "**/*.gql"]
---
```

Cursor also supports `AGENTS.md` in your project root as a simpler alternative.

### Windsurf

Windsurf uses workspace rules stored in `.windsurf/rules/` as markdown files.

```bash
# Clone and copy to your project
git clone https://github.com/wundergraph/graphql-federation-skill.git /tmp/gql-fed-skill
mkdir -p .windsurf/rules
cp /tmp/gql-fed-skill/SKILL.md .windsurf/rules/graphql-federation.md
```

After adding the rule, configure its activation mode via **Windsurf Settings > Cascade > Rules**:
- **Always On**: Applied to every conversation
- **Model Decision**: Applied when Windsurf determines it's relevant
- **Glob**: Applied only when working with files matching patterns (e.g., `*.graphql`)

### Cline

Cline uses workspace rules stored in `.clinerules/` directory at your project root.

```bash
# Clone and copy to your project
git clone https://github.com/wundergraph/graphql-federation-skill.git /tmp/gql-fed-skill
mkdir -p .clinerules
cp /tmp/gql-fed-skill/SKILL.md .clinerules/graphql-federation.md
```

Cline automatically processes all markdown files in `.clinerules/`. You can also use `AGENTS.md` in your project root as an alternative.

### Manual Installation

Copy the contents of `SKILL.md` (and optionally the `references/` directory) into your AI tool's custom instructions or project rules. The skill content works with any AI coding assistant that supports custom prompts or system instructions.

## What's Included

| File | Description |
|------|-------------|
| `SKILL.md` | Core skill with essential directives, patterns, and error prevention |
| `references/directives.md` | Complete specification of all 14 federation directives |
| `references/composition-rules.md` | All validation rules for successful composition |
| `references/patterns.md` | Advanced patterns for real-world federation scenarios |

## Supported Directives

- `@key` — Define entities with primary keys for cross-subgraph resolution
- `@shareable` — Allow fields to be resolved by multiple subgraphs
- `@external` — Reference fields defined in other subgraphs
- `@requires` — Declare dependencies on external data
- `@provides` — Optimize query planning by declaring provided fields
- `@override` — Transfer field ownership between subgraphs
- `@inaccessible` — Hide internal fields from the client schema
- `@interfaceObject` — Extend interface entities across subgraphs
- `@authenticated` — Require authentication for access
- `@requiresScopes` — Require specific OAuth/OIDC scopes
- `@tag` — Add metadata for schema contracts
- `@deprecated` — Mark fields as deprecated
- `@extends` — Legacy extension syntax
- `@composeDirective` — Include custom directives in composition

## Compatible With

- **WunderGraph Cosmo** — Open-source GraphQL Federation platform
- **Apollo Federation** — Apollo's federation implementation
- **Any Federation v2 compatible router**

## Development

### Building the Skill File

The `.skill` file is a zip archive containing the skill documentation. To rebuild it after making changes:

```bash
# Build the skill file
make build

# Clean build artifacts
make clean
```

### Project Structure

```
├── SKILL.md                    # Main skill document (edit this)
├── references/
│   ├── directives.md           # Directive specifications
│   ├── composition-rules.md    # Composition validation rules
│   └── patterns.md             # Advanced federation patterns
├── graphql-federation.skill    # Built skill archive (auto-generated)
└── Makefile                    # Build script
```

### Contributing

1. Edit the source files (`SKILL.md` or files in `references/`)
2. Submit a PR with your changes
3. After merge, CI will automatically rebuild the `.skill` file and open a PR

## Keywords

GraphQL Federation, Apollo Federation, WunderGraph Cosmo, federated GraphQL, subgraph, supergraph, GraphQL composition, distributed GraphQL, GraphQL microservices, AI coding assistant, agentic coding, Claude Code skill, Cursor rules, federation directives, @key directive, @shareable directive, GraphQL schema composition, federation entities

## License

Apache 2.0 License