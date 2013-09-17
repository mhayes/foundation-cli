require "thor"
require "foundation/cli/version"

module Foundation
  module CLI
    include Thor::Actions
    source_root File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

    desc "tester", "tester description"
    def tester
      puts "this is a test module"
    end
  end
end