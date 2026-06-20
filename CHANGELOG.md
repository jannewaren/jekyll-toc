# Changelog

Released versions are documented under [GitHub Releases](https://github.com/jannewaren/jekyll-toc-plus/releases).
Unreleased, not-yet-tagged changes are listed below.

## [Unreleased]

### Added

- `no_toc_class` config option to customize the class that excludes a heading
  from the TOC (default: `no_toc`), mirroring the configurable `no_toc_section_class`.

### Changed

- The `{% toc %}` tag now requires `toc: true` strictly, matching the `toc` /
  `toc_only` / `inject_anchors` filters. Previously the tag accepted any truthy
  front-matter value. If you relied on a non-`true` truthy value (e.g. `toc: "yes"`)
  to render the tag, set it to `toc: true`.
