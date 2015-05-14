
db = require "lapis.db.postgres"
db.set_backend "raw", (q) ->
  print q
  {}

ids = db.list {3,2,1,5}
res = db.select "* from another table where id in ?", ids

db.update "the_table", {
  height: 55
}, { :ids }

