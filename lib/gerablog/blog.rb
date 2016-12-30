require 'date'
require_relative 'render'

module GeraBlog
  # Blog
  class Blog
    attr_reader :config

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

    def create_dir(dir)
      Dir.mkdir(dir) unless Dir.exist?(dir)
    end

    def create_category_dir(category)
      category_dir = File.join(@config['dir']['output'], category)
      create_dir category_dir

      make_dest_dir(
        File.join(@config['dir']['texts'], category, 'images'),
        File.join(category_dir, 'images')
      )
    end

    def create_dirs(posts)
      create_dir @config['dir']['output']

      make_dest_dir(
        @config['dir']['assets'],
        File.join(@config['dir']['output'], 'assets')
      )

      posts.map { |p| p[:category] }
           .uniq
           .map { |category| create_category_dir category }
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

    def write_posts(posts)
      create_dirs posts
      posts.map { |post| File.write(post[:filename], post[:content]) }
    end

    def write_general_rss(posts, parser_rss)
      File.write(
        File.join(@config['dir']['output'], 'feed.xml'),
        parser_rss.result(blog: @config['blog'], posts: posts)
      )
    end

    def write_by_category_files(posts, parser_rss, parser_html)
      posts.map { |p| p[:category] }.uniq.each do |category|
        title = {
          url: File.join(@config['blog']['url'], 'texts', category),
          description: "#{@config['blog']['description']} (#{category})"
        }

        category_posts = posts.select { |p| p[:category] == category }

        write_parsed('feed.xml', parser_rss, category, title, category_posts)
        write_parsed('index.html', parser_html, category, title, category_posts)
      end
    end

    def render
      GeraBlog::Render.new(@config).render
    end

    def save
      posts = render

      parser_rss = Erubis::Eruby.new File.read(@config['template']['feed'])
      parser_html = Erubis::Eruby.new File.read(@config['template']['category'])

      write_posts posts
      write_general_rss posts, parser_rss
      write_by_category_files posts, parser_rss, parser_html
    end
  end
end
