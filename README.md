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

Add to your project's `.claude/settings.json`:

```json
{
  "skills": ["github:wundergraph/graphql-federation-skill"]
}
```

Or install globally in `~/.claude/settings.json` to use across all projects.

### Cursor

Add to your project's `.cursor/rules` or `.cursorrules` file:

```
@skill github:wundergraph/graphql-federation-skill
```

### Windsurf

Add to your project's `.windsurfrules` file:

```
@skill github:wundergraph/graphql-federation-skill
```

### Cline

Add to your Cline custom instructions or project rules:

```
Load skill from: github:wundergraph/graphql-federation-skill
```

### Manual Installation

Download the `graphql-federation.skill` file and reference it in your AI tool's configuration, or copy the contents of `SKILL.md` into your project's AI instructions.

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