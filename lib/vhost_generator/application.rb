require 'vhost_generator/version'
require 'optparse'
require 'ostruct'

module VhostGenerator

  ###########################################################################
  # VhostGenerator main application object.  When invoking +vhost-generator+
  # from the command line, a VhostGenerator::Application object is created
  # and run.
  #
  class Application
    def initialize(name=nil, output_stream=$stdout)
      @name ||= File.basename($0 || 'vhost-generator')
      @output_stream = output_stream
      @config = OpenStruct.new # XXX
    end

    # Run the VhostGenerator application.
    def run(argv=ARGV)
      standard_exception_handling do
        handle_options(argv)
      end
    end

    def handle_options(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: #{@name} [options]"

        opts.on_tail("-v", "--version", "Display the program version.") do
          @output_stream.puts "#{@name}, version #{VhostGenerator::VERSION}"
          exit(true)
        end

        opts.on_tail("-h", "--help", "-H", "Display this help message.") do
          @output_stream.puts opts
          exit(true)
        end
      end.parse(argv)
    end

    # Provide standard exception handling for the given block.
    def standard_exception_handling
      begin
        yield
      rescue SystemExit => ex
        # Exit silently with current status
        raise
      rescue OptionParser::InvalidOption => ex
        $stderr.puts ex.message
        exit(false)
      rescue Exception => ex
        # Exit with error message
        display_error_message(ex)
        exit(false)
      end
    end

    # Display the error message that caused the exception.
    def display_error_message(ex)
      $stderr.puts "#{name} aborted!"
      $stderr.puts ex.message
      $stderr.puts ex.backtrace.join("\n")
    end
  end
end
