

slugify = (str) ->
  str.replace(/\s+/g, "-").replace(/[^\w_-]/g, "").toLowerCase()


build_index = ->
  nav_links = $(".nav_links")
  headers = $(".text_column").find("h2")

  append_header = (h, classes=null, parent_slug) ->
    slug = h.text()
    slug = parent_slug + " " + slug if parent_slug
    slug = slugify slug

    h.attr "id", slug

    link = $("<a href='##{slug}'></a>")
      .html(h.html())
      .appendTo(nav_links)

    h.html $("<a href='##{slug}'>").html h.html()

    link.addClass classes if classes
    slug

  for h in headers
    do (h) ->
      h = $(h)
      slug = append_header h

      for sub in h.nextUntil("h2", "h3")
        do (sub) ->
          sub = $ sub
          append_header sub, "sub", slug


build_index()
