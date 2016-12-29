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

      @config.add 'blog',
                  'root' => '.',
                  'url' => 'http://localhost:8080',
                  'title' => 'GeraBlog',
                  'name' => 'GeraBlog Static Blog Generator',
                  'description' => 'GeraBlog - My own static site generator',
                  'language' => 'pt-br'

      root = './'
      @config.add 'dir',
                  'root' => root,
                  'texts' => File.join(root, 'texts'),
                  'assets' => File.join(root, 'assets'),
                  'output' => File.join(root, 'output'),
                  'template' => File.join(root, 'templates')

      @config.add 'template',
                  'category' => File.join(
                    @config['dir']['template'],
                    'category.html.erb'
                  ),
                  'categories' => File.join(
                    @config['dir']['template'],
                    'categories.html.erb'
                  ),
                  'feed' => File.join(
                    @config['dir']['template'],
                    'feed.xml.erb'
                  ),
                  'post' => File.join(
                    @config['dir']['template'],
                    'post.html.erb'
                  )
    end

    def make_dest_dir(src, dest)
      return if Dir.exist?(dest)
      FileUtils.cp_r(src, dest)
    end

    def load_config(config_file)
      @config = ParseConfig.new(config_file)
    end

    def save
      @posts = render

      testdir = @config['dir']['output']
      Dir.mkdir(testdir) unless Dir.exist?(testdir)

      make_dest_dir(
        @config['dir']['assets'],
        File.join(@config['dir']['output'], 'assets')
      )

      @posts.map { |p| p[:category] }.uniq.each do |category|
        category_dir = File.join(@config['dir']['output'], category)
        Dir.mkdir(category_dir) unless Dir.exist?(category_dir)

        make_dest_dir(
          File.join(@config['dir']['texts'], category, 'images'),
          File.join(category_dir, 'images')
        )
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
        blog[:description] = "#{@config['blog']['description']} (#{category})"

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
      parser = Erubis::Eruby.new File.read(@config['template']['categories'])
      categories = parser.result(categories: categories_dir)

      posts = []
      categories_dir.each do |category, dir|
        Dir["#{dir}/*.md"].sort.reverse.each do |file|
          posts.push(
            render_post(
              filename: file,
              category: category,
              categories: categories
            )
          )
        end
      end

      posts
    end

    def render_post(filename:, category:, categories:)
      md_content = File.read(filename)
      lines = md_content.split("\n")
      newfile = File.basename(filename).sub(/md$/, 'html')

      post = {
        title: lines[0][2..-1],
        category: category,
        description: lines[2][3..-1],
        date: Date.parse(newfile.match('\A(....-..-..)')[1]).rfc822,
        content: md_content,
        filename: File.join(@config['dir']['output'], category, newfile),
        url: File.join(@config['blog']['url'], 'texts', category, newfile)
      }
      post[:content] = GeraBlog::Markdown.new(
        lang: category,
        blog: @config
      ).to_html(post: post, categories: categories)

      post
    end
  end
end
