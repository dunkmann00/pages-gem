# frozen_string_literal: true

require "securerandom"

module GitHubPages
  # Sets and manages Jekyll configuration defaults
  # Most configuration is now set in _default_config.yml
  class Configuration
    # Backward compatability of constants
    DEFAULT_PLUGINS     = GitHubPages::Plugins::DEFAULT_PLUGINS
    PLUGIN_WHITELIST    = GitHubPages::Plugins::PLUGIN_WHITELIST
    DEVELOPMENT_PLUGINS = GitHubPages::Plugins::DEVELOPMENT_PLUGINS
    THEMES              = GitHubPages::Plugins::THEMES

    # User-overwritable defaults used only in production for practical reasons
    PRODUCTION_DEFAULTS = {
      "sass" => {
        "style" => "compressed",
      },
    }.freeze

    class << self
      def processed?(site)
        site.instance_variable_get(:@_github_pages_processed) == true
      end

      def processed(site)
        site.instance_variable_set :@_github_pages_processed, true
      end

      def disable_whitelist?
        !ENV["DISABLE_WHITELIST"].to_s.empty?
      end

      def development?
        Jekyll.env == "development"
      end

      # Returns the effective Configuration
      #
      # Note: this is a highly modified version of Jekyll#configuration
      def effective_config(user_config)
        config = user_config
        if !development?
          config = Jekyll::Utils.deep_merge_hashes PRODUCTION_DEFAULTS, config
        end

        # Allow theme to be explicitly disabled via "theme: null"
        config["theme"] = user_config["theme"] if user_config.key?("theme")

        migrate_theme_to_remote_theme(config)

        restrict_and_config_markdown_processor(config)

        configure_plugins(config)

        config
      end

      # Set the site's configuration. Implemented as an `after_reset` hook.
      # Equivalent #set! function contains the code of interest. This function
      # guards against double-processing via the value in #processed.
      def set(site)
        return if processed? site

        debug_print_versions
        set!(site)
        processed(site)
      end

      # Set the site's configuration with all the proper defaults.
      # Should be called by #set to protect against multiple processings.
      def set!(site)
        site.config = effective_config(site.config)
      end

      private

      # Ensure we're using Kramdown or GFM.  Force to Kramdown if
      # neither of these.
      #
      # This can get called multiply on the same config, so try to
      # be idempotentish.
      def restrict_and_config_markdown_processor(config)
        config["markdown"] = "kramdown" unless \
          %w(kramdown gfm commonmarkghpages).include?(config["markdown"].to_s.downcase)

        return unless config["markdown"].to_s.casecmp("gfm").zero?

        config["markdown"] = "CommonMarkGhPages"
        config["commonmark"] = {
          "extensions" => %w(table strikethrough autolink tagfilter),
          "options" => %w(unsafe footnotes),
        }
      end

      # If the user has set a 'theme', then see if we can automatically use remote theme instead.
      def migrate_theme_to_remote_theme(config)
        # This functionality has been rolled back due to complications with jekyll-remote-theme.
      end

      # Requires default plugins and configures whitelist in development
      def configure_plugins(config)
        # Ensure we have those gems we want.
        config["plugins"] = Array(config["plugins"]) | DEFAULT_PLUGINS
        config["whitelist"] = Array(config["whitelist"]) | PLUGIN_WHITELIST

        # To minimize errors, lazy-require jekyll-remote-theme if requested by the user
        config["plugins"].push("jekyll-remote-theme") if config.key? "remote_theme"

        if disable_whitelist?
          config["whitelist"] = config["whitelist"] | config["plugins"]
        end

        return unless development?

        config["whitelist"] = config["whitelist"] | DEVELOPMENT_PLUGINS
      end

      # Print the versions for github-pages and jekyll to the debug
      # stream for debugging purposes. See by running Jekyll with '--verbose'
      def debug_print_versions
        Jekyll.logger.debug "GitHub Pages:", "jekyll-v4-github-pages v#{GitHubPages::VERSION}"
        Jekyll.logger.debug "GitHub Pages:", "jekyll v#{Jekyll::VERSION}"
      end
    end
  end
end
