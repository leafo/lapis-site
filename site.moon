

Site = require "sitegen.site"

Site.default_plugins = for plugin in *Site.default_plugins
  if plugin == "sitegen.plugins.pygments"
    "sitegen.plugins.syntaxhighlight"
  else
    plugin


sitegen = require "sitegen"
tools = require "sitegen.tools"

trim_snippet = (code_text) ->
  import trim_leading_white from require "sitegen.common"
  code_text = code_text\gsub "^\n", ""
  trim_leading_white code_text

verify_lua_code = (code_text, page) ->
  _, err = loadstring(code_text)

  if err
    -- try again, make valid if it's just an expression
    _, err2 = loadstring("_ = " .. code_text)
    if err2
      error "[#{page and page.source}] failed to compile: #{err}: #{code_text}"

verify_moon_code = (code_text, page) ->
  parse = require "moonscript.parse"
  _, err =  parse.string code_text

  if err
    error "[#{page and page.source}] failed to compile: #{err}: #{code_text}"

-- TODO: this code checking needs to be upgraded for new syntax highlighter
-- since we aren't going to be using pygments anymore
PygmentsPlugin = require "sitegen.plugins.pygments"
PygmentsPlugin.custom_highlighters.lua = (code_text, page) =>
  verify_lua_code code_text, page
  @pre_tag @highlight("lua", code_text), "lua"

PygmentsPlugin.custom_highlighters.moon = (code_text, page) =>
  verify_moon_code code_text, page
  @pre_tag @highlight("moon", code_text), "moon"

sitegen.create =>
  @current_version = "1.17.0"

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
          import slugify from require "sitegen.common"

          -- custom handling for command line tool ref
          if header.title\match "^lapis "
            return slugify header.title

          -- just use the name of the method/function as the slug
          if method = header.html_content\match "^<code>([%w_:.]+)"
            return method

          slugify header.title
      }
    }

  add "reference.html", template: "reference"
  add "index.html", template: "home"
  add "changelog.html", template: "home"
  add "reference.json.moon", template: false, target_fname: "reference.json"

  @self_ref = (page, opts) ->
    import render_html from require "lapis.html"

    render_html ->
      name = assert opts[1]
      code class: "for_moon", "@#{name}"
      code class: "for_lua", "self.#{name}"

  @dual_code = (page, opts) ->
    md = page.site\get_renderer "sitegen.renderers.markdown"

    render_markdown = (str) ->
      md\render page, assert str, "missing string for markdown render"

    {moon_code, lua_code} = opts
    lua_format = "lua"

    if opts.moon
      moon_code = opts.moon

    if opts.lua
      lua_code = opts.lua

    if opts.etlua -- for writing etlua templates
      lua_code = opts.etlua
      lua_format = "erb"

    assert type(moon_code) == "string", "At least moonscript code must be provided"

    moon_code = trim_snippet moon_code

    moonscript = require "moonscript.base"

    if type(lua_code) == "string"
      lua_code = trim_snippet lua_code
      if lua_format == "lua"
        verify_lua_code lua_code, page
    else
      -- this will also verify moon code
      lua_code = assert moonscript.to_lua moon_code, implicitly_return_root: false

    assert render_markdown table.concat {
      [[<div class="dual_code">]]
      [[<div class="dual_code_tabs">
        <button type="button" data-lang="lua" class="set_language">Lua</button>
        <button type="button" data-lang="moonscript" class="set_language">MoonScript</button>
      </div>]]
      "```#{lua_format}", lua_code, "```"
      "```moon", moon_code, "```"
      [[</div>]]
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
            unless items.show_default == false
              td "Default"

        tbody ->
          for row in *items
            description = (row.description or "")\gsub "^[\r\n]+", ""
            description = trim_leading_white description

            tr ->
              td ->
                if row.name == "..."
                  em "…"
                elseif row.name\match "^<"
                  raw row.name -- it's already html
                else
                  code row.name

              td ->
                raw render_markdown description

                if row.example
                  details class: "option_example", ->
                    summary "Show Example"
                    raw render_markdown row.example


              unless items.show_default == false
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
