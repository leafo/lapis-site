
slugify = (str) ->
  str.replace(/\s+/g, "-").replace(/[^\w_-]/g, "").toLowerCase()

build_index = ->
  nav_links = $(".nav_links:first")
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


  if headers.length == 0
    nav_links.remove()
    return

  for h in headers
    do (h) ->
      h = $(h)
      slug = append_header h

      for sub in h.nextUntil("h2", "h3")
        do (sub) ->
          sub = $ sub
          append_header sub, "sub", slug


add_captions = ->
  tpl = (url, caption, alt="Hi") -> """
    <div class="image_container">
      <div class="image">
        <div class="caption_outer">
          <div class="caption">#{caption}</div>
        </div>
        <img src="#{url}" alt="#{alt}" />
      </div>
    </div>
  """

  $(".text_column img[title]").replaceWith ->
    elm = $(@)
    tpl elm.attr("src"), elm.attr("title"), elm.attr("alt")

build_index()
add_captions()


