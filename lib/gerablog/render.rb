require_relative 'redcarpet'

module GeraBlog
  # Get all markdown files and return posts in html
  class Render
    def initialize(config)
      @config = config
    end

    def render
      c_dir = Dir[File.join(@config['dir']['texts'], '*')]
      categories_dir = Hash[c_dir.map { |d| File.basename d }.zip c_dir]
      parser = Erubis::Eruby.new File.read(@config['template']['categories'])
      categories = parser.result(categories: categories_dir)

      rendered_posts(categories_dir, categories)
    end

    def rendered_posts(categories_dir, categories)
      posts = []

      categories_dir.each do |category, dir|
        md_render = GeraBlog::RedcarpetDriver.new(category, @config)

        Dir["#{dir}/*.md"].sort.reverse.each do |file|
          posts.push render_post(md_render, file, category, categories)
        end
      end

      posts
    end

    def make_full_filename(filename, category)
      File.join(@config['dir']['output'], 'texts', category, filename)
    end

    def make_full_url(filename, category)
      File.join(@config['blog']['url'], 'texts', category, filename)
    end

    def post_element(md_content, newfile, category)
      lines = md_content.split("\n")

      {
        title: lines[0][2..-1],
        category: category,
        description: lines[2][3..-1],
        date: Date.parse(newfile.match('\A(....-..-..)')[1]).rfc822,
        filename: make_full_filename(newfile, category),
        url: make_full_url(newfile, category),
        markdown: md_content
      }
    end

    def file_to_post(filename, category)
      md_content = File.read(filename)
      newfile = File.basename(filename).sub(/md$/, 'html')

      post_element(md_content, newfile, category)
    end

    def render_post(md_render, filename, category, categories)
      post = file_to_post(filename, category)
      post[:content] = md_render.to_html(post, post[:markdown], categories)

      post
    end
  end
end
