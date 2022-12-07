@R = {}
@L ||= {}

SUGGESTION_URL = "https://github.com/leafo/lapis-site/issues/new?body=Please%20tell%20us%20what%20you%20were%20trying%20to%20find.%20What%20you%20typed%20and%20what%20you%20expected%20to%20see.%20This%20can%20either%20be%20for%20existing%20pages%2C%20or%20pages%2Fquestions%20you%20think%20should%20be%20answered%20in%20the%20documentation%0A&title=Search%20suggestion%3A%20<<what%20were%20you%20trying%20to%20find%3F>>"

L.setup_search = (el, opts={}) ->
  render = (props={}) ->
    ReactDOM.render React.createElement(R.DocumentationSearch, props), el[0]

  pages_by_id = {}
  index = null

  render {
    root: opts.root
  }

  $.get(opts.index).done (res) =>
    index = lunr ->
      @field "title"
      @field "keywords"
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

RDF = ReactDOMFactories

{ div, span, a, p, ol, ul, li, strong, em, img,
  form, label, input, textarea, button,
  h1, h2, h3, h4, h5, h6, code } = RDF

{ useState, useEffect, useRef } = React

R.DocumentationSearchResults = React.memo DocumentationSearchResults = (props) ->
  results = props.results.map (result, i) ->
    title = result.page.title
    is_code = title.match(/^[^A-Z.]*$/) || title.match /_/

    if is_code
      # remove the return values
      title = title.replace /[^=]+=\s+/, ""

    classes = "result_row"
    if props.selected_result == i
      classes += " selected"

    link = a href: "#{props.root}/#{result.page.url}", title

    div className: classes, key: "result-#{i}",
      if is_code
        code {}, link
      else
        link

      if result.page.subtitle
        React.createElement React.Fragment, {},
          " "
          span className: "result_sub", result.page.subtitle

  unless results.length
    results = div className: "result_row empty",
      "Nothing found"
      " — "
      span className: "help_search",
        a href: SUGGESTION_URL, target: "_blank", "Help improve search/documentation..."

  div className: "results_popup", results

R.DocumentationSearch = DocumentationSearch = (props) ->
  container_ref = useRef null
  [search_query, set_search_query] = useState ""
  [results, set_results] = useState null
  [selected_result, set_selected_result] = useState 0
  [has_focus, set_has_focus] = useState false

  do_search = (query) =>
    return unless props.search
    set_selected_result 0
    set_results props.search query

  useEffect =>
    click_body = (e) =>
      return unless has_focus
      unless $(e.target).closest(container_ref.current).length
        set_has_focus false

    $(document.body).on "click", click_body

    => $(document.body).off "click", click_body

  # handle if they typed something before the search function was ready
  useEffect(
    =>
      if props.search && search_query
        do_search search_query
    [props.search]
  )

  div className: "searcher", ref: container_ref,
    input {
      type: "text"
      className: "search_input"
      value: search_query
      placeholder: "Search documentation..."
      onFocus: => set_has_focus true

      onChange: (e) =>
        set_search_query e.target.value
        do_search e.target.value

      onKeyDown: (e) =>
        switch e.keyCode
          # up
          when 38
            return unless results
            e.preventDefault()
            len = results.length
            set_selected_result (selected_result + len - 1) % len
            return
          # down
          when 40
            return unless results
            e.preventDefault()
            len = results.length
            set_selected_result (selected_result + 1) % len
            return
          # enter
          when 13
            e.preventDefault()
            result = results && results[selected_result]
            if result
              window.location = "#{props.root}/#{result.page.url}"
            return

          # esc
          when 27
            e.preventDefault()
            set_search_query ""
            set_results null
            return
    }

    if search_query && has_focus && results
      React.createElement R.DocumentationSearchResults, {
        results
        selected_result
        root: props.root
      }

