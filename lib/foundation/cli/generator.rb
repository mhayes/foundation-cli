require "thor"

module Foundation
  module CLI
    class Generator < Thor
      include Thor::Actions

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
      option :libsass, type: :boolean, default: false
      option :version, type: :string
      def new(name)
        # RUBY_VERSION == "2.0.0"
        unless which("node") || which("npm")
          say "Please install NodeJS. Aborting."
          exit 1
        end

        unless which("bower")
          say "Please install bower. Aborting."
          exit 1
        end

        unless which("grunt")
          say "Please install grunt-cli. Aborting."
          exit 1
        end

        unless which("git")
          say "Please install git. Aborting."
          exit 1
        end


        if options[:libsass]
          repo = "git@github.com:zurb/foundation-libsass-template.git"
        else
          unless which("compass")
            run("gem install compass", capture: true, verbose: false)
            run("rbenv rehash", capture: true, verbose: false) if which("rbenv")
          end
          repo = "git@github.com:zurb/foundation-compass-template.git"
        end

        say "Creating ./#{name}"
        empty_directory(name)
        run "git clone #{repo} #{name}", capture: true, verbose: false
        inside(name) do
          say "Installing dependencies with bower..."
          run "bower install", capture: true, verbose: false
          run "git remote rm origin", capture: true, verbose: false
          if options[:libsass]
            run "npm install"
            run "grunt build"
          end
        end

        say "./#{name} was created"
      end

      desc "update", "update an existing project"
      option :version, type: :string
      def update
        unless which("bower")
          "Please install bower. Aborting."
          exit 1
        end
        run "bower update"
      end
    end
  end
end