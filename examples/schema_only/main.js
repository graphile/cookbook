const { makeQueryRunner } = require("./QueryRunner.js");

async function main() {
  const runner = await makeQueryRunner(
    "postgres:///graphile_cookbook",
    "app_public"
  );

  const result = await runner.query(
    "query PostsByAuthor($username: String!) { userByUsername(username: $username) { postsByAuthorId { nodes { id body topicByTopicId { id title } } } } }",
    { username: "ChadF" }
  );

  console.log(JSON.stringify(result, null, 2));

  await runner.release();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
