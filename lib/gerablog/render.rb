require 'erubis'
require 'redcarpet'

module GeraBlog
  # My subclass to perform parse with code bloques options
  class CustomRender < Redcarpet::Render::HTML
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
        %r{ ['&\"<>\/] },
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
  class Render
    def initialize(lang:, blog:)
      @template = blog.template
      @blog = {
        name: blog.name,
        title: blog.title,
        description: blog.description,
        categories: '<hr></p><strong>TO DO</strong></p><hr>'
      }
      @render = Redcarpet::Markdown.new(CustomRender.new(lang: lang))
    end

    def to_html(post:)
      parser = Erubis::Eruby.new File.read(@template[:post])
      post[:converted] = @render.render(post[:content])
      parser.result(blog: @blog, post: post)
    end
  end
end
