# Federation Directives Reference

Complete specification of all federation directives.

## Table of Contents
1. [@key](#key)
2. [@shareable](#shareable)
3. [@external](#external)
4. [@requires](#requires)
5. [@provides](#provides)
6. [@override](#override)
7. [@inaccessible](#inaccessible)
8. [@interfaceObject](#interfaceobject)
9. [@extends](#extends)
10. [@authenticated](#authenticated)
11. [@requiresScopes](#requiresscopes)
12. [@tag](#tag)
13. [@deprecated](#deprecated)
14. [@composeDirective](#composedirective)

## @key

**Definition:**
```graphql
directive @key(fields: openfed__FieldSet!, resolvable: Boolean = true) repeatable on INTERFACE | OBJECT
```

**Purpose:** Designates a type as an entity, enabling resolution across subgraphs.

**Arguments:**
- `fields`: Selection set specifying the entity's primary key
- `resolvable`: When `false`, this subgraph cannot resolve the entity (reference only)

**Valid Field Set Patterns:**
```graphql
# Single field
@key(fields: "id")

# Multiple fields
@key(fields: "id sku")

# Nested fields (must have selection on object types)
@key(fields: "author { id }")

# Deeply nested
@key(fields: "order { customer { id } product { sku } }")
```

**Invalid Field Sets:**
```graphql
# Arguments not allowed
@key(fields: "id(format: true)")  # ERROR

# Abstract types not allowed
@key(fields: "node")  # ERROR if node is Interface/Union

# Missing selection on object type
@key(fields: "author")  # ERROR if author is object type
```

**Multiple Keys:**
```graphql
type Product @key(fields: "id") @key(fields: "sku") {
  id: ID!
  sku: String!
  name: String!
}
```

**Non-Resolvable Key:**
```graphql
# Use when referencing an entity defined elsewhere
type User @key(fields: "id", resolvable: false) {
  id: ID!
}
```

## @shareable

**Definition:**
```graphql
directive @shareable repeatable on FIELD_DEFINITION | OBJECT
```

**Purpose:** Indicates that a field can be resolved by multiple subgraphs.

**On Fields:**
```graphql
type User @key(fields: "id") {
  id: ID!
  name: String! @shareable
  email: String! @shareable
}
```

**On Objects (applies to all fields):**
```graphql
type User @key(fields: "id") @shareable {
  id: ID!
  name: String!
  email: String!
}
```

**When Required:**
- When the same field is defined in multiple subgraphs
- When a key field is referenced in another subgraph's composite key
- NOT required for root type fields (Query, Mutation, Subscription)

## @external

**Definition:**
```graphql
directive @external on FIELD_DEFINITION | OBJECT
```

**Purpose:** Marks a field as defined and resolved by another subgraph.

**Use Cases:**

1. **Key fields in extensions:**
```graphql
extend type User @key(fields: "id") {
  id: ID! @external
  posts: [Post!]!
}
```

2. **Fields for @requires:**
```graphql
type Product @key(fields: "id") {
  id: ID!
  price: Float! @external
  weight: Float! @external
  shippingCost: Float! @requires(fields: "price weight")
}
```

3. **Fields for @provides:**
```graphql
type Query {
  products: [Product!]! @provides(fields: "name")
}

type Product @key(fields: "id") {
  id: ID!
  name: String! @external
}
```

**Object-Level External:**
```graphql
extend type User @key(fields: "id") @external {
  id: ID!
  name: String!
}
```

## @requires

**Definition:**
```graphql
directive @requires(fields: openfed__FieldSet!) on FIELD_DEFINITION
```

**Purpose:** Declares that a field needs data from external fields to resolve.

**Basic Usage:**
```graphql
type Product @key(fields: "id") {
  id: ID!
  price: Float! @external
  currency: String! @external
  formattedPrice: String! @requires(fields: "price currency")
}
```

**Nested Requirements:**
```graphql
type Order @key(fields: "id") {
  id: ID!
  items: [OrderItem!]! @external
  totalWeight: Float! @requires(fields: "items { product { weight } quantity }")
}
```

**Rules:**
- All referenced fields must be marked @external
- The router fetches required fields first, then calls your resolver
- Required fields are passed to resolver via `__typename` representation

## @provides

**Definition:**
```graphql
directive @provides(fields: openfed__FieldSet!) on FIELD_DEFINITION
```

**Purpose:** Declares that a resolver provides additional fields for the returned type.

**Basic Usage:**
```graphql
type Query {
  topProducts: [Product!]! @provides(fields: "name price")
}

type Product @key(fields: "id") {
  id: ID!
  name: String! @external
  price: Float! @external
}
```

**With Inline Fragments:**
```graphql
type Query {
  media: [Media!]! @provides(fields: "... on Book { author }")
}
```

**Rules:**
- Provided fields must be marked @external
- Signals to router that this resolver already has the data
- Optimizes query planning by avoiding extra subgraph calls

## @override

**Definition:**
```graphql
directive @override(from: String!, label: String) on FIELD_DEFINITION
```

**Purpose:** Transfers field resolution ownership from one subgraph to another.

**Basic Usage:**
```graphql
# New subgraph taking over from "legacy-users"
type User @key(fields: "id") {
  id: ID!
  name: String! @override(from: "legacy-users")
}
```

**Progressive Migration with Labels:**
```graphql
# Gradual rollout using feature flags
type User @key(fields: "id") {
  id: ID!
  name: String! @override(from: "legacy-users", label: "percent(10)")
}
```

**Rules:**
- Cannot override from the same subgraph
- Source subgraph's field doesn't need @shareable
- Label enables progressive migration (percentage-based, feature flags)

## @inaccessible

**Definition:**
```graphql
directive @inaccessible on ARGUMENT_DEFINITION | ENUM | ENUM_VALUE | FIELD_DEFINITION | INPUT_FIELD_DEFINITION | INPUT_OBJECT | INTERFACE | OBJECT | SCALAR | UNION
```

**Purpose:** Hides elements from the client-facing API schema.

**On Fields:**
```graphql
type User @key(fields: "id") {
  id: ID!
  name: String!
  internalScore: Float! @inaccessible
}
```

**On Types:**
```graphql
type InternalMetrics @inaccessible {
  requestCount: Int!
  latencyMs: Float!
}
```

**On Enum Values:**
```graphql
enum Status {
  ACTIVE
  INACTIVE
  DELETED @inaccessible
}
```

**Rules:**
- Still visible in router schema, just hidden from clients
- All fields cannot be inaccessible (type becomes useless)
- Required arguments cannot be inaccessible without default value
- Still subject to @shareable rules

## @interfaceObject

**Definition:**
```graphql
directive @interfaceObject on OBJECT
```

**Purpose:** Defines an object type that represents an interface entity.

**Example:**
```graphql
# Subgraph A - defines interface
interface Media @key(fields: "id") {
  id: ID!
  title: String!
}

type Book implements Media @key(fields: "id") {
  id: ID!
  title: String!
  author: String!
}

# Subgraph B - extends all Media implementations
type Media @key(fields: "id") @interfaceObject {
  id: ID!
  reviews: [Review!]!  # Added to ALL Media types
}
```

**Rules:**
- Cannot define concrete implementations in same subgraph
- Must have @key matching the interface's key
- Fields automatically added to all implementations

## @extends

**Definition:**
```graphql
directive @extends on INTERFACE | OBJECT
```

**Purpose:** Legacy directive for marking type extensions.

**Usage:**
```graphql
type User @extends @key(fields: "id") {
  id: ID! @external
  posts: [Post!]!
}
```

**Note:** Prefer using `extend type` syntax instead:
```graphql
extend type User @key(fields: "id") {
  id: ID! @external
  posts: [Post!]!
}
```

## @authenticated

**Definition:**
```graphql
directive @authenticated on ENUM | FIELD_DEFINITION | INTERFACE | OBJECT | SCALAR
```

**Purpose:** Requires authentication to access the element.

**On Fields:**
```graphql
type Query {
  publicPosts: [Post!]!
  myDrafts: [Post!]! @authenticated
}
```

**On Types:**
```graphql
type PrivateData @authenticated {
  secrets: [String!]!
}
```

## @requiresScopes

**Definition:**
```graphql
directive @requiresScopes(scopes: [[openfed__Scope!]!]!) on ENUM | FIELD_DEFINITION | INTERFACE | OBJECT | SCALAR
```

**Purpose:** Requires specific scopes for access (OR of ANDs).

**Basic Usage:**
```graphql
type Query {
  # Requires "read:users" scope
  users: [User!]! @requiresScopes(scopes: [["read:users"]])
}
```

**Multiple Scopes (AND):**
```graphql
# Requires both "read:users" AND "admin"
users: [User!]! @requiresScopes(scopes: [["read:users", "admin"]])
```

**Alternative Scopes (OR):**
```graphql
# Requires "admin" OR "superuser"
users: [User!]! @requiresScopes(scopes: [["admin"], ["superuser"]])
```

**Combined:**
```graphql
# (read:users AND admin) OR superuser
users: [User!]! @requiresScopes(scopes: [["read:users", "admin"], ["superuser"]])
```

## @tag

**Definition:**
```graphql
directive @tag(name: String!) repeatable on ARGUMENT_DEFINITION | ENUM | ENUM_VALUE | FIELD_DEFINITION | INPUT_FIELD_DEFINITION | INPUT_OBJECT | INTERFACE | OBJECT | SCALAR | UNION
```

**Purpose:** Adds metadata tags for schema organization and contracts.

**Usage:**
```graphql
type User @tag(name: "internal") {
  id: ID!
  name: String! @tag(name: "pii")
}
```

## @deprecated

**Definition:**
```graphql
directive @deprecated(reason: String = "No longer supported") on ARGUMENT_DEFINITION | ENUM_VALUE | FIELD_DEFINITION | INPUT_FIELD_DEFINITION
```

**Purpose:** Marks elements as deprecated.

**Usage:**
```graphql
type User {
  id: ID!
  name: String!
  fullName: String @deprecated(reason: "Use 'name' instead")
}
```

## @composeDirective

**Definition:**
```graphql
directive @composeDirective(name: String!) repeatable on SCHEMA
```

**Purpose:** Includes custom directives in the composed supergraph schema.

**Usage:**
```graphql
extend schema @composeDirective(name: "@myCustomDirective")

directive @myCustomDirective on FIELD_DEFINITION

type Query {
  users: [User!]! @myCustomDirective
}
```
