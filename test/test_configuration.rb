# frozen_string_literal: true

require 'test_helper'

class TestConfiguration < Minitest::Test
  def test_default_configuration
    configuration = Jekyll::TableOfContents::Configuration.new({})

    assert_equal(1..6, configuration.toc_levels)
    refute(configuration.ordered_list)
    assert_equal('no_toc', configuration.no_toc_class)
    assert_equal('no_toc_section', configuration.no_toc_section_class)
    assert_equal('toc', configuration.list_id)
    assert_equal('section-nav', configuration.list_class)
    assert_equal('', configuration.sublist_class)
    assert_equal('toc-entry', configuration.item_class)
    assert_equal('toc-', configuration.item_prefix)
    refute(configuration.flat_list)
  end

  def test_custom_no_toc_class
    configuration = Jekyll::TableOfContents::Configuration.new('no_toc_class' => 'skip-toc')

    assert_equal('skip-toc', configuration.no_toc_class)
  end

  def test_non_hash_options_fall_back_to_defaults
    configuration = Jekyll::TableOfContents::Configuration.new('not a hash')

    assert_equal(1..6, configuration.toc_levels)
    refute(configuration.ordered_list)
    assert_equal('no_toc_section', configuration.no_toc_section_class)
    assert_equal('toc', configuration.list_id)
    assert_equal('section-nav', configuration.list_class)
    assert_equal('', configuration.sublist_class)
    assert_equal('toc-entry', configuration.item_class)
    assert_equal('toc-', configuration.item_prefix)
    refute(configuration.flat_list)
  end

  def test_flat_list_configuration
    configuration = Jekyll::TableOfContents::Configuration.new('flat_list' => true)

    assert(configuration.flat_list)
  end
end
