require 'vhost_generator/version'
require 'vhost_generator/vhost_configuration'
require 'optparse'
require 'ostruct'

module VhostGenerator

  ###########################################################################
  # VhostGenerator main application object.  When invoking +vhost-generator+
  # from the command line, a VhostGenerator::Application object is created
  # and run.
  #
  class Application
    attr_writer :config

    def initialize(output_stream=$stdout)
      @name = File.basename($0 || 'vhost-generator')
      @output_stream = output_stream
    end

    # Run the VhostGenerator application.
    def run
      standard_exception_handling do
        handle_env(ENV)
        handle_options(ARGV)
        config.cmdline << ['cd', Dir.pwd]
        config.cmdline << [$0] + ARGV
        @output_stream.puts config.output
      end
    end

    def config(configurator=VhostGenerator::VhostConfiguration)
      @config ||= configurator.new # XXX
    end

    def handle_env(env)
      if path = env['STATIC_FOLDER']
        config.static_folder = path
      end
      if ports = env['SERVER_PORTS']
        config.server_ports = ports
      end
      if names = env['SERVER_NAMES']
        config.server_names = names
      end
      if ports = env['INSTANCE_PORTS']
        config.instance_ports = ports
      end
      if root = env['RAILS_RELATIVE_URL_ROOT']
        config.relative_root = root
      end
      if generator = env['GENERATOR']
        config.generator = generator
      end
      if options = env['GENERATOR_OPTIONS']
        config.generator_options = options
      end
    end

    def handle_options(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: #{@name} [options]"

        opts.separator ""
        opts.separator ['Note: all command-line options below also exist as ' \
                        'environment variables.', 'You may try to setenv all ' \
                        'uppercase names in the rest of this summary, eg.',
                        '`export RAILS_RELATIVE_URL_ROOT=/myapp`.'].join($/)

        opts.separator ""
        opts.separator "Application options:"
        application_options.each { |args| opts.on(*args) }

        opts.separator ""
        opts.separator "Generator options:"
        generator_options.each { |args| opts.on(*args) }

        opts.separator ""

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

    def application_options
      [
        ['-f', '--static-folder STATIC_FOLDER',
                %q{Path of your application's static folder (e.g. public/)},
                lambda { |value| config.static_folder = value }],
        ['-l', '--listen SERVER_PORTS',
                %q{Public ports to listen on (e.g. 80,81)},
                lambda { |value| config.server_ports = value }],
        ['-s', '--server-name SERVER_NAMES',
                %q{Server names to listen on (e.g. localhost,example.com)},
                lambda { |value| config.server_names = value }],
        ['-p', '--instance-port INSTANCE_PORTS',
                %q{Internal ports where instances listen on (e.g. 5000,5001)},
                lambda { |value| config.instance_ports = value }],
        ['-r', '--relative-root RAILS_RELATIVE_URL_ROOT',
               lambda { |value| config.relative_root = value }],
      ]
    end

    def generator_options
      [
        ['-g', '--generator GENERATOR',
               %q{Generator to use to output virtualhost configuration file},
               lambda { |value| config.generator = value }],
        ['-o', '--generator-options GENERATOR_OPTIONS',
                %q{Generator options as comma-separated list of key=value},
                lambda { |value| config.generator_options = value }],
      ].freeze
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
      $stderr.puts "#{@name} aborted!"
      $stderr.puts ex.message
      $stderr.puts ex.backtrace.join("\n")
    end
  end
end
