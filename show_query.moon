
db = require "lapis.db.postgres"
db.set_backend "raw", (q) ->
  print q
  {}

db.insert "some_table", {
  tags: db.array {"hello", "world"}
}
