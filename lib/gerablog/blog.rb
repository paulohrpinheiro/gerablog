require 'date'
require_relative 'render'

module GeraBlog
  # Blog
  class Blog
    attr_reader :config, :posts

    @posts = []

    def ini_blog
      @config.add 'blog',
                  'root' => '.',
                  'url' => 'http://localhost:8080',
                  'title' => 'GeraBlog',
                  'name' => 'GeraBlog Static Blog Generator',
                  'description' => 'GeraBlog - My own static site generator',
                  'language' => 'pt-br'
    end

    def ini_dir
      root = './'
      @config.add 'dir',
                  'root' => root,
                  'texts' => File.join(root, 'texts'),
                  'assets' => File.join(root, 'assets'),
                  'output' => File.join(root, 'output'),
                  'template' => File.join(root, 'templates')
    end

    def full_template_dir(file)
      File.join @config['dir']['template'], file
    end

    def ini_template
      @config.add 'template',
                  'category' => full_template_dir('category.html.erb'),
                  'categories' => full_template_dir('categories.html.erb'),
                  'feed' => full_template_dir('feed.xml.erb'),
                  'post' => full_template_dir('post.html.erb')
    end

    def initialize
      @config = ParseConfig.new
      ini_blog
      ini_dir
      ini_template
    end

    def load_config(config_file)
      @config = ParseConfig.new(config_file)
    end

    def make_dest_dir(src, dest)
      return if Dir.exist?(dest)
      FileUtils.cp_r(src, dest)
    end

    def create_dirs
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
    end

    def write_parsed(file, parser, category, title, posts)
      blog = {
        name: @config['blog']['name'],
        language: @config['blog']['language'],
        url: title[:url],
        description: title[:description]
      }

      File.write(
        File.join(@config['dir']['output'], category, file),
        parser.result(title: title, posts: posts, blog: blog)
      )
    end

    def save
      @posts = render

      create_dirs

      @posts.map { |post| File.write(post[:filename], post[:content]) }

      parser_rss = Erubis::Eruby.new File.read(@config['template']['feed'])
      parser_html = Erubis::Eruby.new File.read(@config['template']['category'])

      # General RSS
      File.write(
        File.join(@config['dir']['output'], 'feed.xml'),
        parser_rss.result(blog: @config['blog'], posts: @posts)
      )

      # Page & RSS, by category
      @posts.map { |p| p[:category] }.uniq.each do |category|
        title = {
          url: File.join(@config['blog']['url'], 'texts', category),
          description: "#{@config['blog']['description']} (#{category})"
        }

        category_posts = @posts.select { |p| p[:category] == category }

        write_parsed('feed.xml', parser_rss, category, title, category_posts)
        write_parsed('index.html', parser_html, category, title, category_posts)
      end
    end

    def render
      c_dir = Dir[File.join(@config['dir']['texts'], '*')]
      categories_dir = Hash[c_dir.map { |d| File.basename d }.zip c_dir]
      parser = Erubis::Eruby.new File.read(@config['template']['categories'])
      categories = parser.result(categories: categories_dir)

      posts = []
      categories_dir.each do |category, dir|
        md_render = GeraBlog::Markdown.new(category, @config)

        Dir["#{dir}/*.md"].sort.reverse.each do |file|
          posts.push render_post(md_render, file, category, categories)
        end
      end

      posts
    end

    def render_post(md_render, filename, category, categories)
      md_content = File.read(filename)
      lines = md_content.split("\n")
      newfile = File.basename(filename).sub(/md$/, 'html')

      post = {
        title: lines[0][2..-1],
        category: category,
        description: lines[2][3..-1],
        date: Date.parse(newfile.match('\A(....-..-..)')[1]).rfc822,
        filename: File.join(@config['dir']['output'], category, newfile),
        url: File.join(@config['blog']['url'], 'texts', category, newfile)
      }
      post[:content] = md_render.to_html(post, md_content, categories)

      post
    end
  end
end
