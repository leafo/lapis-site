
class Lapis
  constructor: ->
    @setup_sickybar()
    @setup_lang_picker()

    if m = window.location.hash.match /\blang=(\w+)\b/
      @set_lang m[1]

    $(document.body).on "click", ".top_link", (e) =>
      $(window).scrollTop 0
      false

  set_lang: (lang, change_picker=true) ->
    $(document.body).toggleClass "show_lua", lang == "lua"
    if change_picker
      console.log @lang_picker.find(".picker").removeClass("current")
        .filter("[data-lang='#{lang}']").addClass("current")

  setup_lang_picker: ->
    @lang_picker ||= $ "#lang_picker"
    pickers = @lang_picker.find ".picker"
    @lang_picker.on "click", ".picker", (e) =>
      pickers.removeClass "current"
      p = $(e.currentTarget).addClass "current"
      lang = p.data("lang")
      @set_lang lang, false
      window.location.hash = "lang=#{lang}"

  setup_sickybar: ->
    win = $(window)
    trigger = $(".button_row:first")
    @sticky = $(".sticky_bar")

    visible = false
    win.on "scroll", (e) =>
      if win.scrollTop() > trigger.offset().top
        if !visible
          @sticky.addClass "open"
          visible = true
      else
        if visible
          @sticky.removeClass "open"
          visible = false


new Lapis()

