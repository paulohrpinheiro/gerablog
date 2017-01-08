require_relative 'test_helper'
require_relative '../lib/gerablog/render'

class RenderTest < Minitest::Test
  def setup
    @language = 'test'
    @gb = GeraBlog::Blog.new '/tmp'
    @r = GeraBlog::Render.new(@gb.config)
  end

  def test_make_full_url
    url = 'http://nonexist.a'
    @gb.config['blog']['url'] = url

    category = 'test'
    filename = 'first.html'

    assert_equal\
      File.join(url, 'texts', category, filename),
      @r.make_full_url(filename, category)
  end

  def test_make_full_filename
    output = '/somedir'
    @gb.config['dir']['output'] = output

    category = 'test'
    filename = 'first.html'

    assert_equal\
      File.join(output, 'texts', category, filename),
      @r.make_full_filename(filename, category)
  end

end
