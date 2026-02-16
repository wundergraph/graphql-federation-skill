# Advanced Federation Patterns

Real-world patterns for complex federation scenarios.

## Table of Contents
1. [Multi-Subgraph Entity Ownership](#multi-subgraph-entity-ownership)
2. [Progressive Migration](#progressive-migration)
3. [Computed Fields](#computed-fields)
4. [Authorization Patterns](#authorization-patterns)
5. [Interface Entity Pattern](#interface-entity-pattern)
6. [Event-Driven Extensions](#event-driven-extensions)
7. [Subscription Filtering](#subscription-filtering)
8. [Contracts and Variants](#contracts-and-variants)

## Multi-Subgraph Entity Ownership

### Distributed User Entity

```graphql
# users-subgraph - Core user data
type User @key(fields: "id") {
  id: ID!
  email: String! @shareable
  name: String! @shareable
  createdAt: DateTime!
}

type Query {
  user(id: ID!): User
  me: User @authenticated
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
}
```

```graphql
# posts-subgraph - User's posts
extend type User @key(fields: "id") {
  id: ID! @external
  posts(first: Int, after: String): PostConnection!
  totalPosts: Int!
}

type Post @key(fields: "id") {
  id: ID!
  title: String!
  content: String!
  author: User!
  publishedAt: DateTime
}

type Query {
  post(id: ID!): Post
  feed(first: Int, after: String): PostConnection!
}
```

```graphql
# billing-subgraph - User's billing
extend type User @key(fields: "id") {
  id: ID! @external
  subscription: Subscription
  invoices(first: Int): [Invoice!]!
  paymentMethods: [PaymentMethod!]! @authenticated
}

type Subscription @key(fields: "id") {
  id: ID!
  plan: Plan!
  status: SubscriptionStatus!
  currentPeriodEnd: DateTime!
}
```

### Product Catalog Pattern

```graphql
# catalog-subgraph - Product definitions
type Product @key(fields: "id") @key(fields: "sku") {
  id: ID!
  sku: String!
  name: String! @shareable
  description: String @shareable
  category: Category!
}

type Category @key(fields: "id") {
  id: ID!
  name: String!
  products: [Product!]!
}
```

```graphql
# inventory-subgraph - Stock management
extend type Product @key(fields: "id") {
  id: ID! @external
  stock: Int!
  warehouses: [WarehouseStock!]!
  availability: ProductAvailability!
}

type WarehouseStock {
  warehouse: Warehouse!
  quantity: Int!
}
```

```graphql
# pricing-subgraph - Dynamic pricing
extend type Product @key(fields: "id") {
  id: ID! @external
  price: Money!
  compareAtPrice: Money
  discounts: [Discount!]!
}

type Money {
  amount: Float!
  currency: Currency!
}
```

## Progressive Migration

### Percentage-Based Rollout

```graphql
# new-users-subgraph - Gradual takeover
type User @key(fields: "id") {
  id: ID!
  # 10% of traffic goes to new implementation
  profile: UserProfile! @override(from: "legacy-users", label: "percent(10)")
}
```

### Feature Flag Migration

```graphql
# new-subgraph
type User @key(fields: "id") {
  id: ID!
  # Only routes here when feature flag is enabled
  recommendations: [Product!]! @override(from: "legacy-recs", label: "feature(new-recs)")
}
```

### Complete Migration Steps

1. **Initial State:**
```graphql
# legacy-subgraph
type User @key(fields: "id") {
  id: ID!
  name: String!
  email: String!
}
```

2. **Add New Subgraph with Override:**
```graphql
# new-subgraph
type User @key(fields: "id") {
  id: ID!
  name: String! @override(from: "legacy-subgraph")
  email: String! @override(from: "legacy-subgraph")
}
```

3. **Remove from Legacy (after verification):**
```graphql
# legacy-subgraph - Remove fields
type User @key(fields: "id") {
  id: ID!
  # name and email removed
}
```

## Computed Fields

### Price Calculation

```graphql
# pricing-subgraph
type Product @key(fields: "id") {
  id: ID!
  basePrice: Float! @external
  taxRate: Float! @external
  quantity: Int! @external

  # Computed from external fields
  subtotal: Float! @requires(fields: "basePrice quantity")
  tax: Float! @requires(fields: "basePrice quantity taxRate")
  total: Float! @requires(fields: "basePrice quantity taxRate")
}
```

### User Display Name

```graphql
# profile-subgraph
type User @key(fields: "id") {
  id: ID!
  firstName: String! @external
  lastName: String! @external
  nickname: String! @external

  # Computed display name with fallback logic
  displayName: String! @requires(fields: "firstName lastName nickname")
}
```

### Nested Requirements

```graphql
# shipping-subgraph
type Order @key(fields: "id") {
  id: ID!
  items: [OrderItem!]! @external
  destination: Address! @external

  shippingCost: Money! @requires(fields: """
    items { product { weight dimensions { length width height } } quantity }
    destination { country state zipCode }
  """)

  estimatedDelivery: DateTime! @requires(fields: """
    destination { country state }
  """)
}
```

## Authorization Patterns

### Role-Based Access

```graphql
# admin-subgraph
type Query {
  # Public
  products: [Product!]!

  # Requires login
  orders: [Order!]! @authenticated

  # Requires specific role
  allUsers: [User!]! @requiresScopes(scopes: [["admin"]])

  # Requires one of multiple roles
  reports: [Report!]! @requiresScopes(scopes: [["admin"], ["analyst"]])

  # Requires multiple scopes (AND)
  sensitiveData: SensitiveData! @requiresScopes(scopes: [["admin", "audit"]])
}
```

### Field-Level Authorization

```graphql
type User @key(fields: "id") {
  id: ID!
  name: String!
  email: String! @authenticated  # Only logged-in users

  # Only user themselves or admin
  ssn: String! @requiresScopes(scopes: [["admin"], ["self"]])

  # Internal field
  internalNotes: String! @inaccessible
}
```

### Type-Level Authorization

```graphql
type AdminDashboard @authenticated @requiresScopes(scopes: [["admin"]]) {
  totalRevenue: Money!
  activeUsers: Int!
  errorRate: Float!
}

type Query {
  dashboard: AdminDashboard!
}
```

## Interface Entity Pattern

### Polymorphic Content

```graphql
# content-subgraph - Define interface entity
interface Content @key(fields: "id") {
  id: ID!
  title: String!
  createdAt: DateTime!
  author: User!
}

type Article implements Content @key(fields: "id") {
  id: ID!
  title: String!
  createdAt: DateTime!
  author: User!
  body: String!
  readTime: Int!
}

type Video implements Content @key(fields: "id") {
  id: ID!
  title: String!
  createdAt: DateTime!
  author: User!
  url: String!
  duration: Int!
}

type Query {
  content(id: ID!): Content
  feed: [Content!]!
}
```

```graphql
# engagement-subgraph - Add to ALL content types
type Content @key(fields: "id") @interfaceObject {
  id: ID!
  likes: Int!
  comments: [Comment!]!
  shares: Int!
}
```

### Node Interface Pattern

```graphql
# base-subgraph
interface Node @key(fields: "id") {
  id: ID!
}

type User implements Node @key(fields: "id") {
  id: ID!
  name: String!
}

type Post implements Node @key(fields: "id") {
  id: ID!
  title: String!
}

type Query {
  node(id: ID!): Node
  nodes(ids: [ID!]!): [Node]!
}
```

## Event-Driven Extensions

### Audit Trail Pattern

```graphql
# audit-subgraph
extend type User @key(fields: "id") {
  id: ID! @external
  auditLog(first: Int, after: String): AuditEventConnection!
  lastActivity: DateTime!
}

extend type Post @key(fields: "id") {
  id: ID! @external
  history: [PostRevision!]!
  changeLog: [AuditEvent!]!
}

type AuditEvent {
  id: ID!
  action: AuditAction!
  actor: User!
  timestamp: DateTime!
  details: JSON
}
```

### Notification System

```graphql
# notifications-subgraph
extend type User @key(fields: "id") {
  id: ID! @external
  notifications(unreadOnly: Boolean): [Notification!]!
  unreadNotificationCount: Int!
  notificationPreferences: NotificationPreferences!
}

type Notification @key(fields: "id") {
  id: ID!
  type: NotificationType!
  message: String!
  read: Boolean!
  createdAt: DateTime!
  actionUrl: String
}
```

## Subscription Filtering

### Per-User Filtering

```graphql
# realtime-subgraph
type Subscription {
  # Only events for the authenticated user
  orderUpdated: Order! @authenticated

  # Filter by specific order
  orderStatus(orderId: ID!): OrderStatus!

  # Filter by topic
  notifications(topics: [String!]): Notification!
}
```

### Entity-Scoped Subscriptions

```graphql
extend type User @key(fields: "id") {
  id: ID! @external
}

type Subscription {
  # Subscribe to updates for a specific user
  userActivity(userId: ID!): UserActivity!

  # Subscribe to updates for users the current user follows
  followedUsersActivity: UserActivity! @authenticated
}
```

## Contracts and Variants

### Internal vs Public API

```graphql
# Full internal schema
type User @key(fields: "id") {
  id: ID!
  name: String!
  email: String!
  internalId: String! @tag(name: "internal")
  debugInfo: JSON @tag(name: "internal")
  createdAt: DateTime!
}

type Query {
  user(id: ID!): User
  debugUser(id: ID!): User @tag(name: "internal")
}
```

Contract definition excludes `@tag(name: "internal")`:
- `User.internalId` - excluded
- `User.debugInfo` - excluded
- `Query.debugUser` - excluded

### Partner vs Customer API

```graphql
type Product @key(fields: "id") {
  id: ID!
  name: String!
  price: Money!

  # Only for partners
  wholesalePrice: Money! @tag(name: "partner")
  supplierInfo: Supplier! @tag(name: "partner")

  # Only for internal
  costPrice: Money! @tag(name: "internal")
  margin: Float! @tag(name: "internal")
}
```

Variants:
- **Public**: Basic product info
- **Partner**: Includes wholesale data
- **Internal**: Includes all cost/margin data
