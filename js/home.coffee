@L ||= {}

class L.Home
  constructor: ->
    @setup_dual_code()

    $(document.body).on "click", ".top_link", (e) =>
      $(window).scrollTop 0
      false

    @setup_search()

  setup_search: ->
    drop = $("#search_drop")
    if drop.length
      L.setup_search drop, {
        index: drop.data "index"
        root: drop.data "root"
      }

  setup_dual_code: ->
    body = $(document.body)
    body.on "click", ".dual_code button[data-lang]", (e) =>
      button = $(e.currentTarget)

      language = button.data "lang"
      dual_code = button.closest(".dual_code")
      dual_code.removeClass("show_moonscript show_lua")
      dual_code.addClass("show_#{language}")

