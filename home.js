// Generated by CoffeeScript 1.12.7
(function() {
  this.L || (this.L = {});

  L.Home = (function() {
    function Home() {
      this.setup_dual_code();
      $(document.body).on("click", ".top_link", (function(_this) {
        return function(e) {
          $(window).scrollTop(0);
          return false;
        };
      })(this));
      this.setup_search();
    }

    Home.prototype.setup_search = function() {
      var drop;
      drop = $("#search_drop");
      if (drop.length) {
        return L.setup_search(drop, {
          index: drop.data("index"),
          root: drop.data("root")
        });
      }
    };

    Home.prototype.setup_dual_code = function() {
      var body;
      body = $(document.body);
      return body.on("click", ".dual_code button[data-lang]", (function(_this) {
        return function(e) {
          var button, dual_code, language;
          button = $(e.currentTarget);
          language = button.data("lang");
          dual_code = button.closest(".dual_code");
          dual_code.removeClass("show_moonscript show_lua");
          return dual_code.addClass("show_" + language);
        };
      })(this));
    };

    return Home;

  })();

}).call(this);