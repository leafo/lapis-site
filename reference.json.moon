
import to_json from require "lapis.util"

ref_pages = for page in *site\query_pages {}
  continue unless page.source\match "/docs/"
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

