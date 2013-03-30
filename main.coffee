

slugify = (str) ->
  str.replace(/\s+/g, "-").replace(/[^\w_-]/g, "").toLowerCase()

build_index = ->
  nav_links = $(".nav_links")
  headers = $(".text_column").find("h2")

  links = for h in headers
    do (h) ->
      h = $(h)
      slug = slugify h.text()
      h.attr "id", slug

      h.html $("<a href='##{slug}'>").text h.text()

      $("<a href='##{slug}'></a>")
        .text(h.text())
        .appendTo(nav_links)

build_index()
