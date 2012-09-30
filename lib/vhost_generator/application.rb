require 'vhost_generator/version'

module VhostGenerator

  ###########################################################################
  # VhostGenerator main application object.  When invoking +vhost-generator+
  # from the command line, a VhostGenerator::Application object is created
  # and run.
  #
  class Application
    def run
      version
    end

    def version
      puts "#{File.basename($0)}, version #{VhostGenerator::VERSION}"
    end
  end
end
