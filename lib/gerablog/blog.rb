require 'date'
require 'parseconfig'

require_relative 'render'

# GeraBlog - a Static Blog Generator
module GeraBlog
  def self.make_dest_dir(src, dest, remove: false)
    FileUtils.cp_r(src, dest, remove_destination: remove)
  end

  def self.create_dir(dir)
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
  end

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
                  'language' => 'pt-br',
                  'itens_in_rss' => '50'
    end

    def ini_dir(root)
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
                  'category' => full_template_dir('category.rbhtml'),
                  'categories' => full_template_dir('categories.rbhtml'),
                  'feed' => full_template_dir('feed.rbxml'),
                  'post' => full_template_dir('post.rbhtml'),
                  'footer' => full_template_dir('footer.rbhtml'),
                  'header' => full_template_dir('header.rbhtml'),
                  'index' => full_template_dir('index.rbhtml')
    end

    def initialize(root = './')
      puts root
      @config = ParseConfig.new
      ini_blog
      ini_dir root
      ini_template
    end

    def load_config(config_file)
      @config = ParseConfig.new(config_file)
    end

    def create_category_dir(category)
      puts category
      category_dir = File.join config['dir']['output'], 'texts', category

      GeraBlog.create_dir category_dir

      GeraBlog.make_dest_dir(
        File.join(@config['dir']['texts'], category, 'images'),
        category_dir,
        remove: true
      )
    end

    def create_dirs
      GeraBlog.create_dir File.join(@config['dir']['output'], 'texts')

      GeraBlog.make_dest_dir(
        @config['dir']['assets'],
        @config['dir']['output'],
        remove: true
      )

      @posts.map { |p| p[:category] }
            .uniq
            .map { |category| create_category_dir category }
    end

    def write_parsed(file, template, category, title, posts)
      context = {
        title: title,
        posts: posts,
        config: @config,
        categories: @categories
      }

      File.write(
        File.join(@config['dir']['output'], 'texts', category, file),
        @parser.render(template, context)
      )
    end

    def write_posts
      create_dirs

      @posts.map { |post| File.write(post[:filename], post[:content]) }
    end

    def write_general_rss
      File.write(
        File.join(@config['dir']['output'], 'feed.xml'),
        @parser.render(
          @config['template']['feed'],
          config:
            @config,
            posts: @posts.take(Integer @config['blog']['itens_in_rss'])
        )
      )
    end

    def write_general_html
      context = {
        config: @config,
        categories: @categories,
        title: {
          title: @config['blog']['title'],
          description: @config['blog']['description']
        }
      }

      File.write(
        File.join(@config['dir']['output'], 'index.html'),
        @parser.render(@config['template']['index'], context)
      )
    end

    def write_by_category_files
      @posts.map { |p| p[:category] }.uniq.each do |category|
        title = {
          url: File.join(@config['blog']['url'], 'texts', category),
          description: "#{@config['blog']['description']} (#{category})"
        }

        category_posts = @posts.select { |p| p[:category] == category }

        write_parsed(
          'feed.xml',
          @config['template']['feed'],
          category, title, category_posts
        )
        write_parsed(
          'index.html',
          @config['template']['category'],
          category,
          title,
          category_posts
        )
      end
    end

    def save
      @posts, @categories = GeraBlog::Render.new(@config).render
      @parser = Tenjin::Engine.new path: @config['dir']['templates']

      write_posts
      write_general_rss
      write_general_html
      write_by_category_files
    end
  end
end
