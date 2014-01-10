require "sitegen"

tools = require "sitegen.tools"

sitegen.create_site =>
  @current_version = "0.0.9"
  @title = "Lapis"

  scssphp = tools.system_command "pscss < %s > %s", "css"
  coffeescript = tools.system_command "coffee -c -s < %s > %s", "js"

  build scssphp, "reference.scss", "reference.css"
  build scssphp, "home.scss", "home.css"
  build coffeescript, "home.coffee", "home.js"
  build coffeescript, "reference.coffee", "reference.js"

  deploy_to "leaf@leafo.net", "www/lapis/"

  add "lapis/docs/reference.md", target: "reference", template: "reference"
  add "index.html", template: "home"
  add "changelog.html", template: "home"

