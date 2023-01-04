// Generated by CoffeeScript 1.12.7
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.L || (this.L = {});

  L.Reference = (function() {
    function Reference() {
      this.setup_search = bind(this.setup_search, this);
      this.setup_menu = bind(this.setup_menu, this);
      this.setup_captions();
      this.setup_lang_picker();
      this.setup_dual_code();
      this.setup_search();
      this.setup_menu();
    }

    Reference.prototype.setup_menu = function() {
      return $("#menu_toggle").on("click", (function(_this) {
        return function() {
          return $(document.body).toggleClass("navigation_open");
        };
      })(this));
    };

    Reference.prototype.setup_search = function() {
      var drop;
      drop = $("#search_drop");
      return L.setup_search(drop, {
        index: drop.data("index"),
        root: drop.data("root")
      });
    };

    Reference.prototype.setup_captions = function() {
      var tpl;
      tpl = function(url, caption, alt) {
        if (alt == null) {
          alt = "Hi";
        }
        return "<div class=\"image_container\">\n  <div class=\"image\">\n    <div class=\"caption_outer\">\n      <div class=\"caption\">" + caption + "</div>\n    </div>\n    <img src=\"" + url + "\" alt=\"" + alt + "\" />\n  </div>\n</div>";
      };
      return $(".text_column img[title]").replaceWith(function() {
        var elm;
        elm = $(this);
        return tpl(elm.attr("src"), elm.attr("title"), elm.attr("alt"));
      });
    };

    Reference.prototype.setup_dual_code = function() {
      var body;
      body = $(document.body);
      return body.on("click", ".dual_code button[data-lang]", (function(_this) {
        return function(e) {
          var button, dual_code, global_language, language;
          button = $(e.currentTarget);
          language = button.data("lang");
          global_language = body.filter(".show_moonscript").length ? "moonscript" : "lua";
          dual_code = button.closest(".dual_code");
          dual_code.removeClass("show_moonscript show_lua");
          if (language !== global_language) {
            return dual_code.addClass("show_" + language);
          }
        };
      })(this));
    };

    Reference.prototype.setup_lang_picker = function() {
      var body, lang, override, pickers, ref, set_lang;
      body = $(document.body);
      pickers = $(".lang_picker .lang_toggle");
      override = body.find(".override_lang");
      set_lang = function(name, save) {
        var real_lang, ref;
        if (save == null) {
          save = true;
        }
        if (name) {
          pickers.removeClass("active").filter("[data-lang='" + name + "']").addClass("active");
        }
        real_lang = name;
        if (override.length) {
          real_lang = override.data("lang");
        }
        if (real_lang) {
          body.toggleClass("show_lua", real_lang === "lua").toggleClass("show_moonscript", real_lang === "moonscript");
        }
        if (save) {
          return (ref = window.localStorage) != null ? ref.setItem("reference_lang", name) : void 0;
        }
      };
      body.on("click", ".lang_picker .lang_toggle", function(e) {
        var button;
        button = $(e.currentTarget);
        set_lang(button.data("lang"));
        return null;
      });
      lang = (ref = window.localStorage) != null ? ref.getItem("reference_lang") : void 0;
      return set_lang(lang, false);
    };

    return Reference;

  })();

}).call(this);