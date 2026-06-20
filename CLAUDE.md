# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`jekyll-toc-plus` is a Ruby gem / Jekyll plugin that generates a Table of Contents from rendered HTML content. It is a fork of [`toshimaru/jekyll-toc`](https://github.com/toshimaru/jekyll-toc), adding the options `div_list`, `flat_list`, `toc_only_direct_text`, and per-page `toc_config` front-matter overrides. It aims to stay a drop-in replacement for upstream.

## Commands

```sh
bundle install                 # install dev dependencies
bundle exec rake               # run the full test suite (default task)
bundle exec rake test          # same, explicit
bundle exec rubocop            # lint
bundle exec rubocop -A         # lint with autocorrect

# Run a single test file (note: tests `require 'test_helper'`, so -Itest is required)
bundle exec ruby -Ilib -Itest test/parser/test_toc_filter.rb

# Run a single test by name
bundle exec ruby -Ilib -Itest test/parser/test_toc_filter.rb -n test_nested_toc

bundle exec rake build         # build the .gem
```

CI (`.github/workflows`) runs the test suite across Ruby `3.2`, `3.3`, `3.4`, and `4.0` (on Jekyll 4.4), plus a separate RuboCop job. RuboCop targets Ruby 3.2 syntax; keep new code compatible.

## Architecture

The plugin is two thin Liquid integrations over one parser.

**Entry point — `lib/jekyll-toc-plus.rb`** (the file `require`d by Jekyll). Registers:
- `Jekyll::TableOfContentsFilter`, a Liquid filter module exposing three filters: `toc` (TOC + anchored content), `toc_only` (just the TOC list; a supported filter, kept because — unlike the `{% toc %}` tag — it works on any page), and `inject_anchors` (just the anchored content). Each is gated by `toc_enabled?`, which requires the page's front matter to have `toc: true`.
- `Jekyll::TocTag`, the `{% toc %}` Liquid tag. Equivalent to `toc_only` but reads `content` directly from the page register, so it only works for Posts/Collections (documented limitation).

**Config resolution** is shared via `TableOfContents::ConfigResolver#merge_toc_config`, mixed into both the filter (called through `toc_config`) and the tag: site-wide `_config.yml` `toc:` settings are merged with per-page `toc_config:` front matter, where **page values override site values**. This is the mechanism behind per-page `min_level`/`max_level`/`toc_only_direct_text` overrides.

**`TableOfContents::Parser`** (`lib/table_of_contents/parser.rb`) does all real work:
- Parses the HTML once with Nokogiri (`DocumentFragment`) in `initialize`, then `parse_content` walks the configured heading levels, skipping headings with the `no_toc` class or inside any `no_toc_section_class` container. Each entry records its id (existing `id` attribute, else a slug from the heading text), escaped text, node name, and heading number.
- `build_toc` emits the list; it dispatches to `build_flat_toc_list` (when `flat_list`) or the recursive `build_nested_toc_list`, which builds nested sublists by comparing each entry's heading number to the minimum level in the slice.
- `inject_anchors_into_html` mutates the parsed doc, inserting `<a class="anchor">` before each heading, and returns the modified HTML.
- `list_tag` / `list_parent_tag` select the output element: `div` when `div_list`, otherwise `ul`/`ol` (per `ordered_list`) + `li`.

**`Configuration`** (`configuration.rb`) merges user options over the single source of truth `DEFAULT_CONFIG` and exposes them as readers. When adding a new option, add it to `DEFAULT_CONFIG`, expose an `attr_reader`, assign it in `initialize`, and document it in `README.md`'s Default Configuration block.

**`Helper`** (`helper.rb`) is mixed into `Parser`: `generate_toc_id` slugifies heading text (downcase, strip punctuation via a Unicode-aware regexp, dasherize, URL-encode) and `extract_text` implements `toc_only_direct_text` by pulling only direct text-node children of a heading.

## Tests

Minitest, run via Rake. `test/test_helper.rb` boots SimpleCov + Minitest reporters and defines `SIMPLE_HTML` (h1–h6) plus the `TestHelpers#read_html_and_create_parser` helper. Parser-level behavior lives in `test/parser/`; the Liquid tag/front-matter override behavior is in `test/test_page_config_override.rb` and `test/test_toc_tag.rb` (which stub the Liquid context with `Struct`). New options should get a focused file under `test/parser/`.
