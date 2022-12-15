@L ||= {}

class L.Reference
  constructor: ->
    @setup_captions()
    @setup_lang_picker()
    @setup_dual_code()
    @setup_search()
    @setup_menu()

  setup_menu: =>
    $("#menu_toggle").on "click", =>
      $(document.body).toggleClass "navigation_open"

  setup_search: =>
    drop = $("#search_drop")
    L.setup_search drop, {
      index: drop.data "index"
      root: drop.data "root"
    }

  setup_captions: ->
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

  setup_dual_code: ->
    body = $(document.body)
    body.on "click", ".dual_code button[data-lang]", (e) =>
      button = $(e.currentTarget)

      language = button.data "lang"
      global_language = if body.filter(".show_moonscript").length
        "moonscript"
      else
        "lua"

      dual_code = button.closest(".dual_code")

      dual_code.removeClass("show_moonscript show_lua")

      if language != global_language
        dual_code.addClass("show_#{language}")

  setup_lang_picker: ->
    body = $(document.body)
    pickers = $(".lang_picker .lang_toggle")
    override = body.find(".override_lang")

    set_lang = (name, save=true) ->
      if name
        pickers.removeClass("active")
          .filter("[data-lang='#{name}']")
          .addClass("active")

      real_lang = name
      if override.length
        real_lang = override.data "lang"

      if real_lang
        body
          .toggleClass("show_lua", real_lang == "lua")
          .toggleClass("show_moonscript", real_lang == "moonscript")

      if save
        window.localStorage?.setItem("reference_lang", name)

    body.on "click", ".lang_picker .lang_toggle", (e) ->
      button = $(e.currentTarget)
      set_lang button.data "lang"
      null

    lang = window.localStorage?.getItem("reference_lang")
    set_lang lang, false

