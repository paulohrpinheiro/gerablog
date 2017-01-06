require 'tenjin'
require 'redcarpet'

module GeraBlog
  # My subclass to perform parse with code bloques options
  class RedcarpetCustom < Redcarpet::Render::HTML
    def initialize(lang:)
      super(prettify: true, escape_html: true)
      @lang = lang
    end

    def block_code(code, language)
      l = language.nil? ? @lang : language
      %(<pre><code class="language-#{l}">\n#{html_escape(code)}\n</code></pre>)
    end

    def html_escape(string)
      string.gsub(
        %r{['&\"<>\/]},
        '&' => '&amp;',
        '<' => '&lt;',
        '>' => '&gt;',
        '"' => '&quot;',
        "'" => '&#x27;',
        '/' => '&#x2F;'
      )
    end
  end

  # My Render class
  class RedcarpetDriver
    def initialize(lang, config)
      @template = config['template']
      @blog = config['blog']
      @config = config
      @render = Redcarpet::Markdown.new(RedcarpetCustom.new(lang: lang))
    end

    def to_html(post, content, categories)
      post[:converted] = @render.render(content)
      context = {
        config: @config,
        post: post,
        categories: categories,
        title: {
          title: post[:title],
          description: post[:description]
        }
      }
      parser = Tenjin::Engine.new context
      parser.render @template['post'], context
    end
  end
end
