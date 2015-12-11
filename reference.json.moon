
import to_json from require "lapis.util"


should_index = (source) ->
  return true if source\match "/docs/"
  return true if source\match "^reference"
  return true if source\match "^changelog"
  false


ref_pages = for page in *site\query_pages {}
  continue unless should_index page.source
  page

out = {
  pages: {}
}

pages = for page in *ref_pages
  table.insert out.pages, {
    title: page.meta.title
    url: page\url_for!
  }

write to_json out

