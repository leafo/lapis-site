
import to_json from require "lapis.util"

visit_headers = (headers, visit, stack={}) ->
  stack_idx = #stack + 1
  for h in *headers
    if h.depth
      visit_headers h, visit, stack
    else
      stack[stack_idx] = h
      visit stack

  stack[stack_idx] = nil

flatten_headers = (headers) ->
  out = {}

  visit_headers headers, (stack) ->
    header = stack[#stack]
    trail = [stack[i] for i=#stack-1,1,-1]

    table.insert out, {
      :header
      :trail
    }

  out

should_index = (page) ->
  source = page.source
  return true if source\match "/docs/"
  return true if source == "reference.html"
  return true if source == "changelog.html"
  false

out = {
  pages: {}
}

for page in *site\query_pages {}
  continue unless should_index page

  url = page\url_for!

  table.insert out.pages, {
    id: #out.pages
    title: page.meta.title
    :url
  }

  indexer = site\get_plugin "sitegen.plugins.indexer"
  page_index = indexer\index_for_page page
  if page_index
    for flat in *flatten_headers page_index
      subtitle = [item.title for item in *flat.trail]
      table.insert subtitle, page.meta.title -- add the current page

      table.insert out.pages, {
        id: #out.pages
        title: flat.header.title
        subtitle: table.concat subtitle, " « "
        url: "#{url}##{flat.header.slug}"
      }

write to_json out

