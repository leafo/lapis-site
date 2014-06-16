
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


setup_lang_picker = ->
  body = $(document.body)
  pickers = $(".lang_picker .lang_toggle")

  set_lang = (name) ->
    pickers.removeClass("active")
      .filter("[data-lang='#{name}']")
      .addClass("active")

    unless body.find(".override_lang").length
      body
        .toggleClass("show_lua", name == "lua")
        .toggleClass("show_moonscript", name == "moonscript")

    window.localStorage?.setItem("reference_lang", name)

  body.on "click", ".lang_picker .lang_toggle", (e) ->
    button = $(e.currentTarget)
    set_lang button.data "lang"
    null

  if lang = window.localStorage?.getItem("reference_lang")
    set_lang lang

build_index()
add_captions()
setup_lang_picker()


