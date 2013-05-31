
class Lapis
  constructor: ->
    @setup_sickybar()
    @setup_lang_picker()

  set_lang: (lang, change_picker=true) ->
    $(document.body).toggleClass "show_lua", lang == "lua"
    if change_picker
      null

  setup_lang_picker: ->
    @lang_picker ||= $ "#lang_picker"
    pickers = @lang_picker.find ".picker"
    @lang_picker.on "click", ".picker", (e) =>
      pickers.removeClass "current"
      p = $(e.currentTarget).addClass "current"
      @set_lang p.data("size"), false

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

