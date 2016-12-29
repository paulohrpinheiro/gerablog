require 'date'
require_relative 'render'

module GeraBlog
  # Blog
  class Blog
    attr_reader :title, :name, :description, :url, :language
    attr_reader :root_dir, :output_dir, :texts_dir, :template_dir, :assets_dir
    attr_reader :template, :posts, :categories

    @posts = []

    def initialize(
      root_dir: './',
      url: 'http://localhost:8080',
      title: 'GeraBlog',
      name: 'GeraBlog Static Blog Generator',
      description: 'Blog Generator - my own static site generator',
      language: 'pt-br'
    )
      @root_dir = root_dir
      @url = url
      @title = title
      @name = name
      @description = description
      @language = language
      @output_dir = File.join(@root_dir, 'output')
      @texts_dir = File.join(@root_dir, 'texts')
      @template_dir = File.join(@root_dir, 'templates')
      @assets_dir = File.join(@root_dir, 'assets')
      @template = {
        category: File.join(@template_dir, 'category.html.erb'),
        categories: File.join(@template_dir, 'categories.html.erb'),
        feed: File.join(@template_dir, 'feed.xml.erb'),
        post: File.join(@template_dir, 'post.html.erb')
      }
    end

    def load_config(config_file)
      config = ParseConfig.new(config_file)

      @url = config['blog']['url']
      @title = config['blog']['title']
      @name = config['blog']['name']
      @description = config['blog']['description']
      @language = config['blog']['language']

      @root_dir = config['dir']['root']
      @output_dir = config['dir']['output']
      @texts_dir = config['dir']['texts']
      @template_dir = config['dir']['template']
      @assets_dir = config['dir']['assets']

      @template = {
        category: config['template']['category'],
        categories: config['template']['categories'],
        feed: config['template']['feed'],
        post: config['template']['post']
      }
    end

    def render!
      @posts = render

      Dir.mkdir(@output_dir) unless Dir.exist?(@output_dir)

      assets_src = File.join __dir__, '..', '..', 'assets'
      FileUtils.cp_r(
        assets_src,
        File.join(output_dir, 'assets')
      ) if Dir.exist?(assets_src)

      @posts.map { |p| p[:category] }.uniq.each do |category|
        category_dir = File.join(@output_dir, category)
        Dir.mkdir(category_dir) unless Dir.exist?(category_dir)

        image_src = File.join @root_dir, 'texts', category, 'images'
        FileUtils.cp_r(
          image_src,
          File.join(category_dir, 'images')
        ) if Dir.exist?(image_src)
      end

      @posts.map { |post| File.write(post[:filename], post[:content]) }

      parser_rss = Erubis::Eruby.new File.read(@template[:feed])
      parser_html = Erubis::Eruby.new File.read(@template[:category])

      blog = {
        name: @name,
        language: @language,
        url: @url,
        description: @description
      }

      # General RSS
      File.write(
        File.join(@output_dir, 'feed.xml'),
        parser_rss.result(blog: blog, posts: @posts)
      )

      # Page & RSS, by category
      @posts.map { |p| p[:category] }.uniq.each do |category|
        blog[:url] = File.join @url, 'texts', category
        blog[:description] = "#{@description} (#{category.capitalize})"

        category_posts = @posts.select { |p| p[:category] == category }

        File.write(
          File.join(@output_dir, category, 'feed.xml'),
          parser_rss.result(
            blog: blog,
            posts: category_posts
          )
        )

        File.write(
          File.join(@output_dir, category, 'index.html'),
          parser_html.result(
            blog: blog,
            posts: category_posts
          )
        )

      end
    end

    def render
      c_dir = Dir[File.join(@texts_dir, '*')]
      categories_dir = Hash[c_dir.map { |d| File.basename d }.zip c_dir]
      @categories =
        %(<nav id="mainnav">\n<ul>\n) +
        categories_dir.keys.map { |c| %(<li><a href="../texts/#{c}">#{c.capitalize}</a></li>) }.join("\n") +
        %(</ul>\n</nav>\n)

      posts = []
      categories_dir.each do |category,dir|
        Dir["#{dir}/*.md"]
          .sort
          .reverse
          .map { |f| posts.push render_page(filename: f, category: category) }
      end

      posts
    end

    def render_page(filename:, category:)
      md_content = File.read(filename)
      lines = md_content.split("\n")
      newfile = File.basename(filename).sub(%r{md$}, 'html')

      post = {
        title: lines[0][2..-1],
        category: category,
        description: lines[2][3..-1],
        date: Date.parse(newfile.match('\A(....-..-..)')[1]).rfc822,
        content: md_content,
        filename: File.join(@output_dir, category, newfile),
        url: File.join(self.url, 'texts', category, newfile)
      }

      blog = {
        title: @title,
        name: @name,
        url: @url,
        description: @description,
        language: @language,
        categories: @categories,
        feeds: '',
        template: @template
      }

      post[:content] = GeraBlog::Render
        .new(lang: category, blog: blog)
        .to_html(post: post)

      post
    end
  end
end
