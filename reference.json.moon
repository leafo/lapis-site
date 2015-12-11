
import to_json from require "lapis.util"

IndexerPlugin = require "sitegen.plugins.indexer"

import scan_html from require "web_sanitize.query.scan_html"

parse_headers = (str) ->
  out = {}
  stack = {}

  empty_stack = (depth) ->
    top = stack[#stack]
    while depth < top.depth
      old_top = top
      table.remove stack
      top = stack[#stack]
      if top and top[#top]
        top[#top].children = old_top
      else
        table.insert out, old_top
        break

  scan_html str, (scan_stack) ->
    element = scan_stack[#scan_stack]
    depth = element.tag\match "^h(%d+)$"
    return unless depth
    depth = tonumber depth

    top = stack[#stack]

    if top
      empty_stack depth
      top = stack[#stack]

    if not top or depth > top.depth
      top = {
        depth: depth
      }

      table.insert stack, top

    table.insert top, {
      name: element\inner_text!
    }

  empty_stack 0
  unpack out


visit_headers = (headers, visit, stack={}) ->
  for h in *headers
    table.insert stack, h
    visit stack

    if h.children
      visit_headers h.children, visit, stack

    table.remove stack

flatten_headers = (headers) ->
  out = {}

  visit_headers headers, (stack) ->
    top = stack[#stack]
    return unless top.name
    trail = for i=#stack - 1, 1, -1
      name = stack[i].name
      continue unless name
      name

    table.insert out, {
      name: top.name
      trail: next(trail) and trail or nil
    }

  out

should_index = (source) ->
  return true if source\match "/docs/"
  return true if source == "reference.html"
  return true if source == "changelog.html"
  false

should_index_nested = (source) ->
  return false if source == "changelog.html"
  return false if source == "reference.html"
  true

out = {
  pages: {}
}

for page in *site\query_pages {}
  continue unless should_index page.source

  url = page\url_for!

  table.insert out.pages, {
    id: #out.pages
    title: page.meta.title
    :url
  }

  if should_index_nested page.source
    page\render!

    headers = parse_headers page._inner_content

    for flat in *flatten_headers headers
      continue unless flat.trail -- top level index covered by page
      import slugify from require "sitegen.common"

      table.insert out.pages, {
        id: #out.pages
        title: flat.name
        subtitle: table.concat flat.trail, " « "
        url: "#{url}##{slugify flat.name}"
      }

write to_json out

