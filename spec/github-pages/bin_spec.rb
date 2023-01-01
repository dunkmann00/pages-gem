# frozen_string_literal: true

require "spec_helper"

describe(GitHubPages) do
  it "lists the dependency versions" do
    output = `jekyll-v4-github-pages versions`
    expect(output).to include("Gem")
    expect(output).to include("Version")
    GitHubPages::Dependencies.gems.each do |name, version|
      expect(output).to include("| #{name}")
      expect(output).to include("| #{version}")
    end
  end

  it "outputs the branch" do
    expect(`./bin/jekyll-v4-github-pages branch`).to eql("gem 'jekyll-v4-github-pages', :branch => 'master', :git => 'git://github.com/dunkmann00/pages-gem'\n")
  end

  it "detects the CNAME when running health check" do
    File.write("CNAME", "foo.invalid")
    expect(`./bin/jekyll-v4-github-pages health-check --trace`).to include("Checking domain foo.invalid...")
    File.delete("CNAME")
  end
end
