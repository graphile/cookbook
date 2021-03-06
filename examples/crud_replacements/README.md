# Replacing built in CRUD mutations

We don't currently support a 1-to-1 replacement for the built in CRUD
replacements via PostgreSQL functions, but we have a fairly close
approximation. This repo shows you how - have a look at `data/before.graphql`
for the GraphQL with autogenerated CRUD mutations, and `data/after.graphql`
for the GraphQL with our replacements applied. To see the replacements
themselves, look in `db/after.sql`.

General principle:

1. Disable the CRUD mutation on the table with a smart comment; e.g. `comment on table my_table is E'@omit create,update,delete';`
2. Create a function to replace the mutation; e.g.

```sql
create function create_my_table(my_table my_table) returns my_table as $$
  insert into my_table (name, description)
    values ($1.name, $1.description)
    returning *;
$$ language sql volatile set search_path from current strict;
```

Main differences:

- You currently cannot generate mutations/queries that accept a `nodeId` parameter from PostgreSQL functions (so `updateMyTable` no longer exists, you have to use `updateMyTableById`)
- Comments differ (this can be addressed fairly easily should it be a concern)
- The delete mutation payload doesn't gain the `deletedMyTableId: ID` entry
- The update/delete payload types have slightly different names

## How to perfectly replace built-in CRUD mutations

Use the smart comment to disable the built in CRUD mutation as above: `comment on table my_table is E'@omit create,update,delete';`

There's a number of options depending on what you're attempting to achieve:

1. You could keep the current mutation and simply wrap/replace the resolver with `makeWrapResolversPlugin` (introduced in PostGraphile v4.1) [Quick and easy]
2. You could reimplement the mutation yourself in perfect fidelity [using `makeExtendSchemaPlugin`](https://www.graphile.org/postgraphile/make-extend-schema-plugin/) [Easy-ish, better customisability, but can be a lot of work if you want to do this for many tables]
3. You can apply any modifications you like using our powerful plugin system [Involves learning the plugin system, which doesn't have exceptionally good documentation right now, but allows you to make global modifications to your entire schema]
