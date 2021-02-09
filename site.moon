sitegen = require "sitegen"

tools = require "sitegen.tools"

-- TODO: this code checking needs to be upgraded for new syntax highlighter
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
  @current_version = "1.8.3"

  scss = tools.system_command "sassc -I scss < %s > %s", "css"
  coffeescript = tools.system_command "coffee -c -s < %s > %s", "js"

  build scss, "reference.scss", "reference.css"
  build scss, "home.scss", "home.css"

  build coffeescript, "js/home.coffee", "home.js"
  build coffeescript, "js/reference.coffee", "reference.js"
  build coffeescript, "js/search.coffee", "search.js"

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
    "quick_reference"
  }

  for file in *files
    target = "reference/#{file}"
    add "lapis/docs/#{file}.md", {
      :target
      template: "reference"
      index: {
        link_headers: true
        min_depth: 2
        slugify: (header) ->
          -- just use the name of the method/function as the slug
          if header.html_content\match "^<code>"
            if method = header.title\match "([%w_]+)%("
              return method

          import slugify from require "sitegen.common"
          slugify header.title
      }
    }

  add "reference.html", template: "reference"
  add "index.html", template: "home"
  add "changelog.html", template: "home"
  add "reference.json.moon", template: false, target_fname: "reference.json"

  @dual_code = (page, opts) ->
    md = page.site\get_renderer "sitegen.renderers.markdown"

    render_markdown = (str) ->
      md\render page, assert str, "missing string for markdown render"

    {moon_code} = opts

    import trim_leading_white from require "sitegen.common"
    moon_code = moon_code\gsub "^\n", ""
    moon_code = trim_leading_white moon_code
    moonscript = require "moonscript.base"

    lua_code = assert moonscript.to_lua moon_code, implicitly_return_root: false

    assert render_markdown table.concat {
      "```lua", lua_code, "```"
      "```moon", moon_code, "```"
    }, "\n"

  @options_table = (page, items) ->
    md = page.site\get_renderer "sitegen.renderers.markdown"
    render_markdown = (str) ->
      md\render page, assert str, "missing string for markdown render"

    import render_html from require "lapis.html"
    import trim_leading_white from require "sitegen.common"

    render_html ->
      element "table", class: "configuration_table", cellspacing: "0", cellpadding: "0", ->
        thead ->
          tr ->
            td "Name"
            td "Description"
            td "Default"

        tbody ->
          for row in *items
            description = (row.description or "")\gsub "^[\r\n]+", ""
            description = trim_leading_white description

            tr ->
              td ->
                if row.name == "..."
                  em "…"
                else
                  code row.name

              td ->
                raw render_markdown description

                if row.example
                  details class: "option_example", ->
                    summary "Show Example"
                    raw render_markdown row.example

              td ->
                if row.default
                  raw render_markdown row.default
                else if row.name != "..."
                  em class: "default_value", ->
                    code "nil"


  @config_table = (page, items) ->
    md = page.site\get_renderer "sitegen.renderers.markdown"
    render_markdown = (str) ->
      md\render page, assert str, "missing string for markdown render"

    import render_html from require "lapis.html"
    import trim_leading_white from require "sitegen.common"

    render_html ->
      element "table", class: "configuration_table", cellspacing: "0", cellpadding: "0", ->
        thead ->
          tr ->
            td "Name"
            td "Description"
            td "Default value"
            td "Servers"

        tbody ->
          for row in *items
            description = (row.description or "")\gsub "^[\r\n]+", ""
            description = trim_leading_white description

            tr ->
              td ->
                code row.name

              td ->
                raw render_markdown description

              td ->
                raw render_markdown row.default or "`nil`"

              td ->
                if row.servers
                  for i, server in ipairs row.servers
                    if i < 1
                      text ", "

                    strong server
                else
                  em "Any"
