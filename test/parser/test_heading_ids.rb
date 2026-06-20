# frozen_string_literal: true

require 'test_helper'

class TestHeadingIds < Minitest::Test
  # An author-supplied id containing a double quote must not break out of the
  # generated href attribute (which would allow HTML/attribute injection).
  def test_author_id_with_quote_is_escaped_in_toc
    html = '<h1 id=\'a"b\'>Title</h1>'
    toc_html = Jekyll::TableOfContents::Parser.new(html).build_toc
    link = Nokogiri::HTML::DocumentFragment.parse(toc_html).at_css('a')

    assert_equal('#a"b', link['href'])
  end

  def test_author_id_with_quote_is_escaped_in_injected_anchors
    html = '<h1 id=\'a"b\'>Title</h1>'
    anchored = Jekyll::TableOfContents::Parser.new(html).inject_anchors_into_html
    anchor = Nokogiri::HTML::DocumentFragment.parse(anchored).at_css('a.anchor')

    assert_equal('#a"b', anchor['href'])
  end

  # A crafted id must not inject an extra (event-handler) attribute.
  def test_quote_injection_does_not_create_extra_attribute
    html = '<h1 id=\'x" onmouseover="alert(1)\'>Title</h1>'

    toc_link = Nokogiri::HTML::DocumentFragment.parse(
      Jekyll::TableOfContents::Parser.new(html).build_toc
    ).at_css('a')

    assert_nil(toc_link['onmouseover'])

    anchor = Nokogiri::HTML::DocumentFragment.parse(
      Jekyll::TableOfContents::Parser.new(html).inject_anchors_into_html
    ).at_css('a.anchor')

    assert_nil(anchor['onmouseover'])
  end

  # Two headings sharing an explicit id get distinct fragment ids, matching how
  # generated ids are de-duplicated.
  def test_duplicate_explicit_ids_are_suffixed
    html = '<h1 id="dup">A</h1><h2 id="dup">B</h2>'
    toc_html = Jekyll::TableOfContents::Parser.new(html).build_toc

    assert_includes(toc_html, 'href="#dup"')
    assert_includes(toc_html, 'href="#dup-1"')
  end
end
