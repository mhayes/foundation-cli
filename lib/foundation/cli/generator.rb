require "thor"

module Foundation
  module CLI
    class Generator < Thor
      include Thor::Actions
      source_root File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

      desc "tester", "tester description"
      def tester
        puts "this is a test module"
      end
    end
  end
end