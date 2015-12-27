@L ||= {}

class L.Home
  constructor: ->
    @setup_lang_picker()
    $(".lang_headers").stick_in_parent offset_top: -2

    $(document.body).on "click", ".top_link", (e) =>
      $(window).scrollTop 0
      false

    @update_lang()
    @setup_search()

  setup_search: ->
    drop = $("#search_drop")
    L.setup_search drop, {
      index: drop.data "index"
      root: drop.data "root"
    }

  update_lang: ->
    if m = window.location.hash.match /\blang=(\w+)\b/
      lang = m[1]
      $(document.body).toggleClass "show_lua", lang == "lua"

  setup_lang_picker: ->
    $(document.body).on "click", ".lang_toggle", (e) =>
      window.location.hash = $(e.currentTarget).data "hash"
      setTimeout =>
        @update_lang()
      , 1

