@R = {}
@L ||= {}

L.setup_search = (el, opts={}) ->
  render = (props={}) ->
    c = R.DocumentationSearch props
    ReactDOM.render c, el[0]

  pages_by_id = {}
  index = null

  render {
    root: opts.root
  }

  $.get(opts.index).done (res) =>
    index = lunr ->
      @field "title"
      @ref "id"

    for page in res.pages
      pages_by_id[page.id] = page
      index.add page

    render {
      root: opts.root
      search: (query) =>
        results = index.search query
        for res in results
          page = pages_by_id[res.ref]
          {
            score: res.score
            page: page
          }
    }

{ div, span, a, p, ol, ul, li, strong, em, img,
  form, label, input, textarea, button,
  h1, h2, h3, h4, h5, h6, code } = React.DOM

R.component = (name, data) ->
  data.displayName = "R.#{name}"
  cl = React.createClass(data)
  R[name] = React.createFactory(cl)
  R[name]._class = cl

R.component "DocumentationSearch", {
  getInitialState: ->
    {
      search_query: ""
      selected_result: 0
      has_focus: false
    }

  componentDidMount: ->
    $(document.body).on "click", (e) =>
      return unless @state.has_focus
      el = ReactDOM.findDOMNode(@)
      unless $(e.target).closest(el).length
        @setState has_focus: false

  componentDidUpdate: (prev) ->
    if !prev.search && @props.search && @state.search_query
      @do_search @state.search_query

  do_search: (query) ->
    return unless @props.search
    @setState {
      selected_result: 0
      results: @props.search query
    }

  render: ->
    div className: "searcher", children: [
      input {
        className: "search_input"
        type: "text"
        value: @state.search_query
        placeholder: "Search documentation..."
        onFocus: =>
          @setState has_focus: true

        onKeyDown: (e) =>
          switch e.keyCode
            # up
            when 38
              e.preventDefault()
              return unless @state.results
              len = @state.results.length
              @setState {
                selected_result: (@state.selected_result + len - 1) % len
              }
              return
            # down
            when 40
              return unless @state.results
              e.preventDefault()
              len = @state.results.length
              @setState {
                selected_result: (@state.selected_result + 1) % len
              }

              return
            # enter
            when 13
              e.preventDefault()
              result = @state.results[@state.selected_result]
              if result
                window.location = "#{@props.root}/#{result.page.url}"
              return
            # esc
            when 27
              @setState {
                search_query: ""
                results: null
              }

              e.preventDefault()
              return

        onChange: (e) =>
          @setState search_query: e.target.value
          @do_search e.target.value
      }

      if @state.search_query && @state.has_focus
        @render_results()
    ]

  render_results: ->
    results = @state.results.map (result, i) =>
      title = result.page.title
      is_code = title.match(/^[^A-Z]*$/) || title.match /_/

      if is_code
        # remove the return values
        title = title.replace /[^=]+=\s+/, ""

      classes = "result_row"
      if @state.selected_result == i
        classes += " selected"

      link = a href: "#{@props.root}/#{result.page.url}", title

      div className: classes, children: [
        if is_code
          code {}, link
        else
          link

        if result.page.subtitle
          [
            " "
            span className: "result_sub", result.page.subtitle
          ]
      ]

    unless results.length
      results = [
        div className: "result_row empty", "Nothing found"
      ]

    div className: "results_popup", children: results

}
