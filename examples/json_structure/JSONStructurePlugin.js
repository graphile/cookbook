const {
  makePluginByCombiningPlugins,
  makeExtendSchemaPlugin,
  gql
} = require("graphile-utils");

const AddMyTypePlugin = makeExtendSchemaPlugin({
  // Describe both the output and input type
  typeDefs: gql`
    type MyCustomType {
      name: String
      avatarUrl: String
      tags: [String!]!
    }
    input MyCustomTypeInput {
      name: String
      avatarUrl: String
      tags: [String!]
    }
  `,

  // for the output type, how to produce the output - make sure you do any coercion necessary since PostgreSQL does not enforce a JSON schema!
  resolvers: {
    MyCustomType: {
      name: json => (json && typeof json.name === "string" ? json.name : null),
      avatarUrl: json =>
        json && typeof json.avatar_url === "string" ? json.avatar_url : null,
      tags: json =>
        json && Array.isArray(json.tags)
          ? json.tags.filter(tag => typeof tag === "string")
          : []
    }
  }
});

const ReplaceFieldType = builder => {
  // Process the output fields
  builder.hook("GraphQLObjectType:fields:field", (field, build, context) => {
    const { getTypeByName } = build;
    const {
      scope: { pgFieldIntrospection: attr }
    } = context;
    if (!attr || attr.kind !== "attribute") {
      return field;
    }
    const overrideType = attr.tags.overrideType;
    if (!overrideType) {
      return field;
    }
    const gqlType = getTypeByName(overrideType);
    if (!gqlType) {
      return field;
    }
    return {
      ...field,
      type: gqlType
    };
  });

  // Process the input fields
  builder.hook(
    "GraphQLInputObjectType:fields:field",
    (field, build, context) => {
      const { getTypeByName } = build;
      const {
        scope: { pgFieldIntrospection: attr }
      } = context;
      if (!attr || attr.kind !== "attribute") {
        return field;
      }
      const overrideType = attr.tags.overrideType;
      if (!overrideType) {
        return field;
      }
      const gqlType = getTypeByName(overrideType + "Input");
      if (!gqlType) {
        return field;
      }
      return {
        ...field,
        type: gqlType
      };
    }
  );
};

module.exports = makePluginByCombiningPlugins(
  AddMyTypePlugin,
  ReplaceFieldType
);
