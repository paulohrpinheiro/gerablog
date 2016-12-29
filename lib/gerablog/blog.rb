require 'date'
require_relative 'render'

module GeraBlog
  # Blog
  class Blog
    attr_reader :config
    attr_reader :posts, :categories

    @posts = []

    def initialize
      @config = ParseConfig.new

      @config.add 'blog', {
        'root' => '.',
        'url' => 'http://localhost:8080',
        'title' => 'GeraBlog',
        'name' => 'GeraBlog Static Blog Generator',
        'description' => 'Blog Generator - my own static site generator',
        'language' => 'pt-br'
      }

      root = './'
      @config.add 'dir', {
        'root' => root,
        'texts' => File.join(root, 'texts'),
        'assets' => File.join(root, 'assets'),
        'output' => File.join(root, 'output'),
        'template' => File.join(root, 'templates')
      }

      @config.add 'template', {
        'category' => File.join(@config['dir']['template'], 'category.html.erb'),
        'categories' => File.join(
          @config['dir']['template'],
          'categories.html.erb'
        ),
        'feed' => File.join(@config['dir']['template'], 'feed.xml.erb'),
        'post' => File.join(@config['dir']['template'], 'post.html.erb')
      }
    end

    def load_config(config_file)
      @config = ParseConfig.new(config_file)
    end

    def render!
      @posts = render

      testdir = @config['dir']['output']
      Dir.mkdir(testdir) unless Dir.exist?(testdir)

      assets_src = File.join __dir__, '..', '..', 'assets'
      FileUtils.cp_r(
        assets_src,
        File.join(@config['dir']['output'], 'assets')
      ) if Dir.exist?(assets_src)

      @posts.map { |p| p[:category] }.uniq.each do |category|
        category_dir = File.join(@config['dir']['output'], category)
        Dir.mkdir(category_dir) unless Dir.exist?(category_dir)

        image_src = File.join @config['dir']['root'], 'texts', category, 'images'
        FileUtils.cp_r(
          image_src,
          File.join(category_dir, 'images')
        ) if Dir.exist?(image_src)
      end

      @posts.map { |post| File.write(post[:filename], post[:content]) }

      parser_rss = Erubis::Eruby.new File.read(@config['template']['feed'])
      parser_html = Erubis::Eruby.new File.read(@config['template']['category'])

      blog = {
        name: @config['blog']['name'],
        language: @config['blog']['language'],
        url: @config['blog']['url'],
        description: @config['blog']['description']
      }

      # General RSS
      File.write(
        File.join(@config['dir']['output'], 'feed.xml'),
        parser_rss.result(blog: blog, posts: @posts)
      )

      # Page & RSS, by category
      @posts.map { |p| p[:category] }.uniq.each do |category|
        blog[:url] = File.join @config['blog']['url'], 'texts', category
        blog[:description] = "#{@config['blog']['description']} (#{category.capitalize})"

        category_posts = @posts.select { |p| p[:category] == category }

        File.write(
          File.join(@config['dir']['output'], category, 'feed.xml'),
          parser_rss.result(
            blog: blog,
            posts: category_posts
          )
        )

        File.write(
          File.join(@config['dir']['output'], category, 'index.html'),
          parser_html.result(
            blog: blog,
            posts: category_posts
          )
        )

      end
    end

    def render
      c_dir = Dir[File.join(@config['dir']['texts'], '*')]
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
          .map { |f| posts.push render_post(filename: f, category: category) }
      end

      posts
    end

    def render_post(filename:, category:)
      md_content = File.read(filename)
      lines = md_content.split("\n")
      newfile = File.basename(filename).sub(%r{md$}, 'html')

      post = {
        title: lines[0][2..-1],
        category: category,
        description: lines[2][3..-1],
        date: Date.parse(newfile.match('\A(....-..-..)')[1]).rfc822,
        content: md_content,
        filename: File.join(@config['dir']['output'], category, newfile),
        url: File.join(@config['blog']['url'], 'texts', category, newfile)
      }

      blog = {
        title: @config['blog']['title'],
        name: @config['blog']['name'],
        url: @config['blog']['url'],
        description: @config['blog']['description'],
        language: @config['blog']['language'],
        categories: @categories,
        feeds: '',
        template: @config['template']
      }

      post[:content] = GeraBlog::Markdown
        .new(lang: category, blog: blog)
        .to_html(post: post)

      post
    end
  end
end
