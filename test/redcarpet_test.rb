require_relative 'test_helper'
require_relative '../lib/gerablog/redcarpet'

class RedCarpetCustomTest < Minitest::Test
  LANGUAGE = 'test'.freeze

  def setup
    @rc = GeraBlog::RedcarpetCustom.new(lang: LANGUAGE)
  end

  def teardown
  end

  def test_default_parameter
    assert_equal LANGUAGE, @rc.lang
  end

  def test_has_html_escape
    assert @rc.respond_to? :html_escape
  end

  def test_html_escape_amp
    assert_equal %(&amp;), @rc.html_escape(%(&))
  end

  def test_html_escape_lt
    assert_equal %(&lt;), @rc.html_escape(%(<))
  end

  def test_html_escape_gt
    assert_equal %(&gt;), @rc.html_escape(%(>))
  end

  def test_html_escape_quote
    assert_equal %(&quot;), @rc.html_escape(%("))
  end

  def test_html_escape_apost
    assert_equal %(&#x27;), @rc.html_escape(%('))
  end

  def test_html_escape_slash
    assert_equal %(&#x2F;), @rc.html_escape(%(/))
  end

  def test_block_code_prettify_code
    assert_equal\
      %(<pre><code class="language-#{LANGUAGE}">\nCODE\n</code></pre>),
      @rc.block_code('CODE')
  end

  def test_block_code_escape_code
    escaped = %(#include &lt;stdio.h&gt;)

    assert_equal\
      %(<pre><code class="language-#{LANGUAGE}">\n#{escaped}\n</code></pre>),
      @rc.block_code('#include <stdio.h>')
  end
end
