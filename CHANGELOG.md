# Changelog

Versions through 0.20.0 are documented under
[GitHub Releases](https://github.com/jannewaren/jekyll-toc-plus/releases).

## [Unreleased]

## [0.21.0] - 2026-06-20

### Added

- `no_toc_class` config option to customize the class that excludes a heading
  from the TOC (default: `no_toc`), mirroring the configurable `no_toc_section_class`.

### Changed

- The `{% toc %}` tag now requires `toc: true` strictly, matching the `toc` /
  `toc_only` / `inject_anchors` filters. Previously the tag accepted any truthy
  front-matter value. If you relied on a non-`true` truthy value (e.g. `toc: "yes"`)
  to render the tag, set it to `toc: true`.

### Fixed

- Escape heading ids when interpolating them into `href` attributes, preventing
  HTML/attribute injection from an author-supplied `id` containing characters
  such as `"`.
- De-duplicate headings that share an explicit `id`: a second `id="foo"` now
  links to `#foo-1` instead of emitting a duplicate `#foo` fragment. Previously
  only generated ids were de-duplicated.
