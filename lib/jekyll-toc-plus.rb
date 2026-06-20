# frozen_string_literal: true

require 'nokogiri'
require 'table_of_contents/configuration'
require 'table_of_contents/parser'

module Jekyll
  module TableOfContents
    # Resolves the effective TOC config by merging site-wide `_config.yml`
    # `toc:` settings with per-page `toc_config:` front matter, where page
    # values override site values. Shared by the filter and the tag.
    module ConfigResolver
      private

      def merge_toc_config(registers)
        site_config = registers[:site].config['toc'] || {}
        page_config = registers[:page]['toc_config'] || {}
        site_config.merge(page_config)
      end
    end
  end

  # toc tag for Jekyll
  class TocTag < Liquid::Tag
    include TableOfContents::ConfigResolver

    def render(context)
      return '' unless context.registers[:page]['toc']

      content_html = context.registers[:page]['content']
      toc_config = merge_toc_config(context.registers)
      TableOfContents::Parser.new(content_html, toc_config).build_toc
    end
  end

  # Jekyll Table of Contents filter plugin
  module TableOfContentsFilter
    include TableOfContents::ConfigResolver

    # Renders the TOC only (no anchors injected into the content).
    # Kept as a supported filter: unlike the {% toc %} tag, it works on any
    # page because it receives the content as input, whereas the tag reads
    # page['content'] and therefore only works for Posts and Collections.
    def toc_only(html)
      return '' unless toc_enabled?

      TableOfContents::Parser.new(html, toc_config).build_toc
    end

    def inject_anchors(html)
      return html unless toc_enabled?

      TableOfContents::Parser.new(html, toc_config).inject_anchors_into_html
    end

    def toc(html)
      return html unless toc_enabled?

      TableOfContents::Parser.new(html, toc_config).toc
    end

    private

    def toc_enabled?
      @context.registers[:page]['toc'] == true
    end

    def toc_config
      merge_toc_config(@context.registers)
    end
  end
end

Liquid::Template.register_filter(Jekyll::TableOfContentsFilter)
Liquid::Template.register_tag('toc', Jekyll::TocTag)
