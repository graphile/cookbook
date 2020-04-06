# PostGraphile schema-only usage

Demonstrates how you might use PostGraphile on the server, e.g. from inside your own business logic or a [Graphile Worker](https://github.com/graphile/worker) task.

## Usage

Clone the repo, and change directory into it:

```bash
git clone https://github.com/graphile/cookbook.git
cd cookbook
```

Install dependencies:

```bash
yarn
```

Install the cookbook schema into locally running PostgreSQL (if you don't have locally running PostgreSQL, you'll need to edit this script; also it assumes that there's a `postgres` database that you have permission to, and that you're using trust authentication):

```bash
./createdb.sh
```

Now run the example:

```bash
cd examples/schema_only
node main.js
```

You should see this result:

```json
{
  "data": {
    "userByUsername": {
      "postsByAuthorId": {
        "nodes": [
          {
            "id": 5,
            "body": "Yeah cats are really fluffy I enjoy squising their fur they are so goregous and fluffy and squishy and fluffy and gorgeous and squishy and goregous and fluffy and squishy and fluffy and gorgeous and squishy",
            "topicByTopicId": {
              "id": 4,
              "title": "I love cats!"
            }
          }
        ]
      }
    }
  }
}
```
