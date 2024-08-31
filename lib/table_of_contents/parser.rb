# frozen_string_literal: true

require 'table_of_contents/helper'

module Jekyll
  module TableOfContents
    # Parse html contents and generate table of contents
    class Parser
      include ::Jekyll::TableOfContents::Helper

      def initialize(html, options = {})
        @doc = Nokogiri::HTML::DocumentFragment.parse(html)
        @configuration = Configuration.new(options)
        @entries = parse_content
      end

      def toc
        build_toc + inject_anchors_into_html
      end

      def build_toc
        %(<div id="toc">\n#{@entries.map { |entry| build_toc_div(entry) }.join("\n")}\n</div>)
      end

      def build_toc_div(entry)
        %(<div class="toc-#{entry[:node_name]}"><a href="##{entry[:id]}">#{entry[:text]}</a></div>)
      end

      def inject_anchors_into_html
        @entries.each do |entry|
          # NOTE: `entry[:id]` is automatically URL encoded by Nokogiri
          entry[:header_content].add_previous_sibling(
            %(<a class="anchor" href="##{entry[:id]}" aria-hidden="true"><span class="octicon octicon-link"></span></a>)
          )
        end

        @doc.inner_html
      end

      private

      def parse_content
        headers = Hash.new(0)

        (@doc.css(toc_headings) - @doc.css(toc_headings_in_no_toc_section))
          .reject { |n| n.classes.include?(@configuration.no_toc_class) }
          .inject([]) do |entries, node|
          text = node.text
          id = node.attribute('id') || generate_toc_id(text)

          suffix_num = headers[id]
          headers[id] += 1

          entries << {
            id: suffix_num.zero? ? id : "#{id}-#{suffix_num}",
            text: CGI.escapeHTML(text),
            node_name: node.name,
            header_content: node.children.first,
            h_num: node.name.delete('h').to_i
          }
        end
      end

      def toc_headings
        @configuration.toc_levels.map { |level| "h#{level}" }.join(',')
      end

      def toc_headings_in_no_toc_section
        if @configuration.no_toc_section_class.is_a?(Array)
          @configuration.no_toc_section_class.map { |cls| toc_headings_within(cls) }.join(',')
        else
          toc_headings_within(@configuration.no_toc_section_class)
        end
      end

      def toc_headings_within(class_name)
        @configuration.toc_levels.map { |level| ".#{class_name} h#{level}" }.join(',')
      end
    end
  end
end
