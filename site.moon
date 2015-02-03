require "sitegen"

tools = require "sitegen.tools"

sitegen.create_site =>
  @current_version = "1.0.6"

  scssphp = tools.system_command "sassc < %s > %s", "css"
  coffeescript = tools.system_command "coffee -c -s < %s > %s", "js"

  build scssphp, "reference.scss", "reference.css"
  build scssphp, "home.scss", "home.css"
  build coffeescript, "home.coffee", "home.js"
  build coffeescript, "reference.coffee", "reference.js"

  deploy_to "leaf@leafo.net", "www/lapis/"

  files = {
    "actions"
    "command_line"
    "configuration"
    "database"
    "models"
    "etlua_templates"
    "exception_handling"
    "getting_started"
    "html_generation"
    "input_validation"
    "lapis_console"
    "lua_creating_configurations"
    "lua_getting_started"
    "moon_creating_configurations"
    "moon_getting_started"
    "testing"
    "utilities"
  }

  for file in *files
    target = "reference/#{file}"
    add "lapis/docs/#{file}.md", :target, template: "reference"

  add "reference.html", template: "reference"

  add "index.html", template: "home"
  add "changelog.html", template: "home"

