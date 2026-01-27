# Federation Composition Rules

Validation rules that must pass for successful composition.

## Table of Contents
1. [Entity Validation](#entity-validation)
2. [Shareability Validation](#shareability-validation)
3. [External Field Validation](#external-field-validation)
4. [Field Set Validation](#field-set-validation)
5. [Type Merging Rules](#type-merging-rules)
6. [Resolvability Rules](#resolvability-rules)
7. [Interface Rules](#interface-rules)
8. [Override Rules](#override-rules)

## Entity Validation

### Entities Must Have Valid Keys

**Rule:** Every @key must reference valid, resolvable fields.

```graphql
# VALID
type User @key(fields: "id") {
  id: ID!
  name: String!
}

# INVALID - key field doesn't exist
type User @key(fields: "userId") {  # ERROR
  id: ID!
}

# INVALID - key field has arguments
type User @key(fields: "id") {
  id(format: Boolean): ID!  # ERROR: key fields cannot have arguments
}
```

### Key Fields Must Be Leaf Types or Have Selections

```graphql
# VALID - scalar key
type User @key(fields: "id") {
  id: ID!
}

# VALID - nested key with selection
type Review @key(fields: "author { id }") {
  author: User!
}

# INVALID - object type without selection
type Review @key(fields: "author") {  # ERROR
  author: User!
}
```

### Key Fields Cannot Be Abstract Types

```graphql
# INVALID - interface in key
type Entity @key(fields: "node") {  # ERROR
  node: Node!  # Node is an interface
}

# INVALID - union in key
type Entity @key(fields: "result") {  # ERROR
  result: SearchResult!  # SearchResult is a union
}
```

## Shareability Validation

### Non-Root Fields in Multiple Subgraphs Must Be Shareable

```graphql
# Subgraph A
type User @key(fields: "id") {
  id: ID!
  name: String! @shareable  # Required
}

# Subgraph B
type User @key(fields: "id") {
  id: ID!
  name: String! @shareable  # Required
}
```

### Root Fields Are Implicitly Shareable

```graphql
# Subgraph A
type Query {
  users: [User!]!  # No @shareable needed
}

# Subgraph B
type Query {
  users: [User!]!  # No @shareable needed
}
```

### Entity Key Fields Used Across Subgraphs

When a key field is part of another subgraph's composite key, it must be shareable:

```graphql
# Subgraph A
type User @key(fields: "id") {
  id: ID!  # Must be @shareable if used in B's key
  name: String!
}

# Subgraph B - uses User.id in composite key
type Review @key(fields: "author { id } product { id }") {
  author: User!
  product: Product!
}
```

## External Field Validation

### External Fields Must Have Source

Fields marked @external must be defined (non-external) in at least one subgraph:

```graphql
# Subgraph A - owns the field
type User @key(fields: "id") {
  id: ID!
  email: String!  # Defined here
}

# Subgraph B - references it
extend type User @key(fields: "id") {
  id: ID! @external
  email: String! @external  # VALID - defined in A
  posts: [Post!]!
}
```

### @requires Fields Must Be External

```graphql
# VALID
type Product @key(fields: "id") {
  id: ID!
  price: Float! @external
  formattedPrice: String! @requires(fields: "price")
}

# INVALID
type Product @key(fields: "id") {
  id: ID!
  price: Float!  # Missing @external
  formattedPrice: String! @requires(fields: "price")  # ERROR
}
```

### @provides Fields Must Be External

```graphql
# VALID
type Query {
  product: Product! @provides(fields: "name")
}

type Product @key(fields: "id") {
  id: ID!
  name: String! @external
}

# INVALID
type Query {
  product: Product! @provides(fields: "name")
}

type Product @key(fields: "id") {
  id: ID!
  name: String!  # Missing @external - ERROR
}
```

## Field Set Validation

### Syntax Requirements

```graphql
# VALID field sets
@key(fields: "id")
@key(fields: "id name")
@key(fields: "author { id }")
@key(fields: "author { id name }")
@requires(fields: "price currency")

# INVALID - empty
@key(fields: "")  # ERROR

# INVALID - empty selection set
@key(fields: "author { }")  # ERROR

# INVALID - consecutive selection sets
@key(fields: "author { { id } }")  # ERROR
```

### No Duplicate Fields

```graphql
# INVALID - duplicate field
@key(fields: "id name age id")  # ERROR: id appears twice
```

### Arguments in Field Sets

```graphql
# @requires and @provides can use arguments
@requires(fields: "price(currency: USD)")  # VALID (if field accepts the arg)

# @key cannot use arguments
@key(fields: "id(format: true)")  # ERROR
```

## Type Merging Rules

### Consistent Field Types

Fields with the same name across subgraphs must have compatible types:

```graphql
# Subgraph A
type User @key(fields: "id") {
  id: ID!
  age: Int!
}

# Subgraph B - INVALID: incompatible type
type User @key(fields: "id") {
  id: ID!
  age: String!  # ERROR: Int! vs String!
}
```

### Consistent Nullability

Nullability must be consistent or safely mergeable:

```graphql
# VALID - same nullability
type User @key(fields: "id") {
  name: String!
}
# +
type User @key(fields: "id") {
  name: String!
}

# VALID - non-null is stricter, takes precedence
type User @key(fields: "id") {
  name: String
}
# +
type User @key(fields: "id") {
  name: String!  # Merged result: String!
}
```

### Argument Compatibility

Fields with arguments must have compatible signatures:

```graphql
# VALID - same arguments
type Query {
  users(limit: Int): [User!]!
}
# +
type Query {
  users(limit: Int): [User!]!
}

# INVALID - different argument types
type Query {
  users(limit: Int): [User!]!
}
# +
type Query {
  users(limit: String): [User!]!  # ERROR
}
```

## Resolvability Rules

### All Fields Must Be Reachable

Every field in the composed schema must be resolvable through some query path:

```graphql
# VALID - email is reachable via User entity
type Query {
  user(id: ID!): User!
}

type User @key(fields: "id") {
  id: ID!
  name: String!
}
# +
type User @key(fields: "id") {
  id: ID!
  email: String!  # Reachable: Query.user -> User (via @key) -> email
}

# INVALID - no way to reach email
type Query {
  user(id: ID!): User!
}

type User {  # No @key!
  id: ID!
  name: String!
}
# +
type User {
  email: String!  # ERROR: unreachable
}
```

### Shared Root Fields

Non-entity types returned from shared root fields must be fully resolvable from any defining subgraph:

```graphql
# Subgraph A
type Query {
  stats: Stats!  # Shared root field
}

type Stats {
  count: Int!
  average: Float!
}

# Subgraph B
type Query {
  stats: Stats!
}

type Stats {
  count: Int!
  max: Float!  # ERROR if average not reachable from B
}
```

## Interface Rules

### Interface Implementation Consistency

If a type implements an interface in one subgraph, it must in all:

```graphql
# Subgraph A
interface Node {
  id: ID!
}

type User implements Node @key(fields: "id") {
  id: ID!
}

# Subgraph B - must also implement Node
type User implements Node @key(fields: "id") {  # Required
  id: ID!
  email: String!
}
```

### @interfaceObject Restrictions

Cannot define implementations alongside @interfaceObject:

```graphql
# INVALID
type Media @key(fields: "id") @interfaceObject {
  id: ID!
  reviews: [Review!]!
}

type Book implements Media {  # ERROR: can't have both
  id: ID!
  title: String!
}
```

## Override Rules

### Cannot Override Self

```graphql
# INVALID
type User @key(fields: "id") {
  id: ID!
  name: String! @override(from: "my-subgraph")  # ERROR if this IS my-subgraph
}
```

### Source Must Exist

The subgraph being overridden must exist and define the field:

```graphql
# INVALID if "legacy-users" subgraph doesn't exist
type User @key(fields: "id") {
  id: ID!
  name: String! @override(from: "nonexistent-subgraph")  # ERROR
}
```

### Overridden Field Handling

When field is overridden:
- Source field becomes effectively external
- Source field doesn't need @shareable
- Only one subgraph resolves the field

```graphql
# Subgraph A (legacy)
type User @key(fields: "id") {
  id: ID!
  name: String!  # Will be overridden, no @shareable needed
}

# Subgraph B (new)
type User @key(fields: "id") {
  id: ID!
  name: String! @override(from: "A")  # Takes over resolution
}
```
