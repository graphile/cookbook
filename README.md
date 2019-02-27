# Small Examples

This repository is a monorepo collection of small examples to answer user
questions and be reference for the documentation.

Each example should be self-contained in its own folder in `examples/` with
its own README.

All examples share the same database `graphile_small_examples` and must only
use their own PostgreSQL schemas to stop them from stepping on each-other's
toes.

Global concerns, such a extensions, should go into the `./scripts/init` script...

`./scripts/init` creates the `graphile_small_examples` database if necessary,
then initialises each of the apps, and if they define `before` / `after`
scripts it runs them. If they produce `data/before.graphql` and
`data/after.graphql` then it will also create the `data/graphql.diff` file.

Thanks for reading, please go read through the relevant folder in
`examples/*` now!
