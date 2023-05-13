# frozen_string_literal: true

Jekyll::Hooks.register :site, :after_init do |site|
  dependencies = GitHubPages::Dependencies.versions
  dependencies_sorted = {}
  dependencies_sorted["jekyll"] = ""
  dependencies_sorted["jekyll-v4-github-pages"] = ""
  dependencies.keys.sort.each { |key|
    dependencies_sorted[key] = dependencies[key]
  }
  site.config["dependencies"] = dependencies_sorted
end
