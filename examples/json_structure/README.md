# Applying a GraphQL schema to your JSON data

If you need to store JSON/JSONB in your PostgreSQL database but have it
exposed as if it were strongly typed in GraphQL then you can achieve this in
PostGraphile using plugins.

Here we create the plugin `JSONStructurePlugin.js` which is actually two
smaller plugins combined together. The first plugin uses
`makeExtendSchemaPlugin` to construct the input and output types for our
type. The second plugin then looks for smart comments on columns in the
database and allows you to replace the input/output type for that column with
the named type.
