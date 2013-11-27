require "thor"
require "json"

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

        def install_dependencies(deps=[])
          if deps.include?("git") && !which("git")
            say "Can't find git. You can install it by going here: http://git-scm.com/"
            exit 1
          end

          if deps.include?("node") && !which("node")
            say "Can't find NodeJS. You can install it by going here: http://nodejs.org"
            exit 1
          end

          if deps.include?("bower") && !which("bower")
            say "Can't find bower. You can install it by running: sudo npm install -g bower"
            exit 1
          end

          if deps.include?("grunt") && !which("grunt")
            say "Can't find grunt. You can install it by running: sudo npm install -g grunt-cli"
            exit 1
          end

          if deps.include?("compass") && !which("compass")
            # Auto install Compass as a convenience
            run("gem install compass", capture: true, verbose: false)
            run("rbenv rehash", capture: true, verbose: false) if which("rbenv")
            unless which("compass")
              say "Can't find compass. You can install it by running: gem install compass"
              exit 1 
            end
          end
        end
      end

      desc "version", "Display CLI version"
      def version
        puts "v#{Foundation::CLI::VERSION}"
      end

      desc "upgrade", "Upgrade your Foundation 4 compass project"
      def upgrade
        install_dependencies(%w{git node bower compass})
        
        if File.exists?(".bowerrc")
          begin json = JSON.parse(File.read(".bowerrc"))
          rescue JSON::ParserError
            json = {}
          end
          unless json.has_key?("directory")
            json["directory"] = "bower_components"
          end
          File.open(".bowerrc", "w") {|f| f.puts json.to_json}
        else
          create_file ".bowerrc" do
            {:directory=>"bower_components"}.to_json
          end
        end
        bower_directory = JSON.parse(File.read(".bowerrc"))["directory"]

        gsub_file "config.rb", /require [\"\']zurb-foundation[\"\']/ do |match|
          match = "add_import_path \"#{bower_directory}/foundation/scss\""
        end

        unless File.exists?("bower.json")
          create_file "bower.json" do
            {:name => "foundation_project"}.to_json
          end
        end

        run "bower install zurb/bower-foundation --save"


        if defined?(Bundler)
          Bundler.with_clean_env do
            run("compass compile", capture: true, verbose: false)
          end
        else
          run("compass compile", capture: true, verbose: false)
        end

        say <<-EOS

Foundation 5 has been setup in your project.

Please update references to javascript files to look something like:

<script src="#{bower_directory}/foundation/js/foundation.min.js"></script>

To update Foundation in the future, just run: foundation update

        EOS
      end

      desc "new", "create new project"
      option :libsass, type: :boolean, default: false
      option :version, type: :string
      def new(name)
        if options[:libsass]
          install_dependencies(%w{git node bower grunt})
          repo = "https://github.com/zurb/foundation-libsass-template.git"
        else
          install_dependencies(%w{git node bower compass})
          repo = "https://github.com/zurb/foundation-compass-template.git"
        end

        say "Creating ./#{name}"
        empty_directory(name)
        run("git clone #{repo} #{name}", capture: true, verbose: false)
        inside(name) do
          say "Installing dependencies with bower..."
          run("bower install", capture: true, verbose: false)
          File.open("scss/_settings.scss", "w") {|f| f.puts File.read("#{destination_root}/bower_components/foundation/scss/foundation/_settings.scss") }
          run("git remote rm origin", capture: true, verbose: false)
          if options[:libsass]
            run "npm install"
            run "grunt build"
          else
            if defined?(Bundler)
              Bundler.with_clean_env do
                run "compass compile"
              end
            end
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