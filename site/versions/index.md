---
title: Pages - Jekyll v4
layout: default
---
# {{ page.title }}

# Dependency versions

## The fork of GitHub Pages uses the following dependencies and versions:

|Dependency|Version|
|----------|-------|
{%- for dependency in site.dependencies %}
| [{{ dependency[0] }}](https://rubygems.org/gems/{{ dependency[0] }}/versions/{{ dependency[1] }}) | {{ dependency[1] }} |
{%- endfor %}

For a history of dependency changes, see [the past releases](https://github.com/dunkmann00/pages-gem/releases).

## Programmatic access

Want a more programmatic way to keep your local version of Jekyll up to date?
All dependencies are bundled within the GitHub Pages Ruby gem, or are available
programmatically via [www.georgeh2os.com/pages-gem/versions.json]({% link versions.json %})

Last updated {{ "now" | date: "%Y-%m-%d %I%P %z" }}
