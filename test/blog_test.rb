require_relative 'test_helper'
require_relative '../lib/gerablog/render'

require 'nokogiri'

class BlogTest < Minitest::Test
  def setup
    @project_dir = Dir.mktmpdir 'TestGerablog'
    @gb = GeraBlog::Blog.new @project_dir
  end

  def teardown
    FileUtils.remove_entry @project_dir
  end

  def test_config_has_all_groups
    assert ['blog', 'dir', 'template'] == @gb.config.get_groups.sort
  end

  def test_config_template_has_all_elements
     assert\
      %w(categories category feed footer header index post) ==
      @gb.config['template'].keys.sort
  end

  def test_config_dir_has_all_elements
     assert\
      %w(assets output root template texts) ==
      @gb.config['dir'].keys.sort
  end

  def test_config_blog_has_all_elements
     assert\
      %w(description itens_in_index itens_in_rss language name root title url) ==
      @gb.config['blog'].keys.sort
  end

  def test_save_config
    @gb.save_config

    assert File.file? File.join(@project_dir, 'gerablog.conf')
  end

  def test_create_category_dir
    category = random_string

    GeraBlog.create_dir(
      File.join(
        @project_dir,
        'texts',
        category,
        'images'
      )
    )
    @gb.create_category_dir category

    assert Dir.exist?\
      File.join(
        @project_dir,
        'output',
        'texts',
        category,
        'images'
      )
  end

  def test_new_blog
    Dir.mktmpdir do |dir|
      blogdir = File.join dir, 'newblog'
      gerablog = GeraBlog::Blog.new blogdir
      gerablog.new_blog

      must_have = %w(
        templates
        templates/category.rbhtml
        templates/feed.rbxml
        templates/categories.rbhtml
        templates/footer.rbhtml
        templates/header.rbhtml
        templates/index.rbhtml
        templates/post.rbhtml
        output
        assets
        assets/css
        assets/css/gerablog.css
        texts
      ).map { |d| File.join blogdir, d }
       .sort

      assert_equal must_have, Dir["#{blogdir}/**/*"].sort
    end
  end

  def test_create_dirs
    @gb.new_blog
    category = random_string
    base_dir = File.join(@project_dir, 'texts', category)
    img_dir = File.join(base_dir, 'images')

    GeraBlog.create_dir(img_dir)
    FileUtils.touch File.join(base_dir, 'test.md')
    FileUtils.touch File.join(img_dir, 'img.png')

    @gb.instance_variable_set "@posts", [ { category: category } ]

    @gb.create_dirs

    must_have = %W(
      texts
      texts/#{category}
      texts/#{category}/images
      texts/#{category}/images/img.png
      assets
      assets/css
      assets/css/gerablog.css
    ).map { |d| File.join @project_dir, 'output', d }
     .sort

    assert_equal must_have, Dir["#{@project_dir}/output/**/*"].sort
  end

  def prepare_test_write_category_index title
    category = random_string
    filename = random_string

    html_filename = "#{filename}.html"

    html_file = File.join(
      @project_dir, 'output', 'texts', category, html_filename
    )

    GeraBlog.create_dir File.join(
      @gb.config['dir']['output'], 'texts', category
    )

    posts = [
      {
        url: "proto://post.url",
        title: "Post Title",
        description: "Post description"
      }
    ]
    @gb.instance_variable_set "@categories", %Q(|#{category}|)

    @gb.write_category_index(
      html_filename,
      @gb.config['template']['category'],
      category,
      title,
      posts
    )

    Nokogiri::HTML open html_file
  end

  def test_write_category_index
    @gb.new_blog
    title = { title: random_string, description: random_string}

    generated_html = prepare_test_write_category_index title

    assert @gb.config['blog']['title'], generated_html.title

    assert\
      title[:title],
      generated_html.at('meta[name="description"]')['content']

    assert\
      generated_html.at_css('header')
                    .text
                    .include? @gb.instance_variable_get('@categories')
  end

  def test_write_posts
    @gb.new_blog

    posts = []
    categories = []

    2.times do
      category = random_string
      categories << category
      category_dir = @gb.config['dir']['output'], 'texts', category
      GeraBlog.create_dir File.join(category_dir, 'images')

      2.times do
        filename = File.join category_dir, "#{random_string}.html"
        FileUtils.touch filename
        posts << { category: category, filename: filename, content: '' }
      end
    end

    @gb.instance_variable_set "@posts", posts
    @gb.instance_variable_set "@categories", categories

    @gb.write_posts

    categories.each do |c|
       assert Dir.exist? File.join @gb.config['dir']['output'], 'texts', c
    end

    posts.each  do |p|
      assert File.exist?(
       File.join(
         @gb.config['dir']['output'],
         'texts',
         p[:category],
         File.basename(p[:filename])
       )
     )
    end
  end

  def test_write_general_rss
  end
end
