require "thor"
require "zurb-foundation"
require "bundler"

module Foundation
  module CLI
    class Generator < Thor
      include Thor::Actions
      # source_root File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
      source_root Foundation.root

      no_commands do
        def which(cmd)
          exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
          ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
            exts.each { |ext|
              exe = File.join(path, "#{cmd}#{ext}")
              return exe if File.executable? exe
            }
          end
          return nil
        end
      end

      desc "version", "Display CLI version"
      def version
        puts "v#{Foundation::CLI::VERSION}"
      end

      desc "new", "create new project"
      option :version, type: :string, default: Foundation::VERSION
      def new(name)
        # RUBY_VERSION == "2.0.0"
        unless which("compass")
          run("gem install compass", capture: true, verbose: false)
          run("rbenv rehash", capture: true, verbose: false) if which("rbenv")
        end

        empty_directory(name)
        inside(name) do
          if File.exists?("Gemfile")
            gsub_file("Gemfile", /gem ['"]zurb-foundation['"].*/, "gem \"zurb-foundation\", \"~> #{options[:version]}\"")
          else
            create_file("Gemfile") do
              s=<<-EOS
source "https://rubygems.org"
gem "compass"
gem "zurb-foundation", "#{options[:version]}"
              EOS
            end
          end

          Bundler.with_clean_env do
            run "bundle install", :capture => true, :verbose => false
            run "bundle exec compass create . -r zurb-foundation --using foundation", :capture => true, :verbose => false
          end
        end

        say "Foundation project has been created in ./#{name}"
      end

      desc "update", "update an existing project"
      option :version, type: :string, default: Foundation::VERSION
      def update
        directory("js/foundation", "javascripts/foundation")
        remove_file("javascripts/foundation/index.js")
        # copy_file("templates/index.html", "index.html")
      end

      desc "watch", "compile assets"
      def watch
        pid = fork do
          run "bundle exec compass watch"
        end
        Process.wait(pid)
        exit $?.exitstatus
      end
    end
  end
end