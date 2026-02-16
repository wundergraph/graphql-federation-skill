# GraphQL Federation Skill for Claude Code

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that teaches Claude how to write correct GraphQL Federation schemas with [WunderGraph Cosmo](https://cosmo-docs.wundergraph.com/) or Apollo Federation.

## What it covers

- Federation directives (`@key`, `@shareable`, `@external`, `@requires`, `@provides`, `@override`, `@inaccessible`, `@interfaceObject`)
- Authorization directives (`@authenticated`, `@requiresScopes`)
- Composition validation rules and how to fix violations
- Entity design and cross-subgraph resolution patterns
- Real-world multi-subgraph architecture patterns

## Install

```
/plugin marketplace add wundergraph/graphql-federation-skill
/plugin install graphql-federation@wundergraph-graphql-federation
```

## Usage

Once installed, Claude Code automatically activates the skill when you work on GraphQL Federation tasks. You can also invoke it explicitly:

```
Use the graphql-federation skill to create an entity type for my user service
```

## What's Included

| File | Description |
|------|-------------|
| `skills/graphql-federation/SKILL.md` | Core skill with essential directives, patterns, and error prevention |
| `skills/graphql-federation/references/directives.md` | Complete specification of all 14 federation directives |
| `skills/graphql-federation/references/composition-rules.md` | All validation rules for successful composition |
| `skills/graphql-federation/references/patterns.md` | Advanced patterns for real-world federation scenarios |

## License

Apache-2.0
