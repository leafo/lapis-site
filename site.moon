require "sitegen"

tools = require "sitegen.tools"

PygmentsPlugin = require "sitegen.plugins.pygments"

PygmentsPlugin.custom_highlighters.lua = (code_text, page) =>
  _, err = loadstring(code_text)

  if err
    -- try again, make valid if it's just an expression
    _, err2 = loadstring("_ = " .. code_text)
    if err2
      error "[#{page.source}] failed to compile: #{err}: #{code_text}"

  @pre_tag @highlight("lua", code_text), "lua"

PygmentsPlugin.custom_highlighters.moon = (code_text, page) =>
  parse = require "moonscript.parse"
  _, err =  parse.string code_text

  if err
    error "[#{page.source}] failed to compile: #{err}: #{code_text}"

  @pre_tag @highlight("moon", code_text), "moon"

sitegen.create =>
  @current_version = "1.3.1"

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

