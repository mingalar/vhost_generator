require 'vhost_generator/nginx_generator'
require 'vhost_generator/apache_generator'
require 'shellwords'

module VhostGenerator

  ###########################################################################
  # VhostConfiguration stores all the configuration values (to read from)
  # +env+ or +cmdline+ needed to render the configuration template.
  #
  class VhostConfiguration
    attr_reader :application, :static_folder, :server_ports, :server_names,
                :instance_ports, :relative_root,
                :generator, :generator_options
    attr_accessor :cmdline

    def initialize(application='myapp', static_folder='public',
        server_ports='80', server_names='localhost', instance_ports='',
        relative_root='/', generator='nginx', generator_options='',
        cmdline=nil)
      self.application = application
      self.static_folder = static_folder
      self.server_ports = server_ports
      self.server_names = server_names
      self.instance_ports = instance_ports
      self.relative_root = relative_root
      self.cmdline = cmdline # usually set later using attr_writer
      self.generator = generator
      self.generator_options = generator_options
    end

    def application=(app)
      app = String(app).strip.gsub(/\s+/, '_') # avoid blanks in app name.
      raise ArgumentError, "application is required" unless app && !app.empty?
      @application = app
    end

    def static_folder=(folder)
      @static_folder = File.expand_path(folder)
    end

    def server_ports=(ports)
      @server_ports = parse_integer_list(ports)
    end

    def server_names=(names)
      @server_names = parse_word_list(names)
    end

    def instance_ports=(ports)
      @instance_ports = parse_integer_list(ports)
    end

    def relative_root=(root)
      @relative_root = (String(root) + '/').gsub(%r{/+}, '/')
    end

    def generator=(name)
      generator_for(name) # ensure generator exists
      @generator = name
    end

    def generator_options=(options)
      @generator_options = parse_option_list(options)
    end

    def configure!(parser)
      parser.parse(self)
    end

    def output
      generator_for(self.generator).new(self, self.generator_options).render
    end

    protected

    def generator_for(name)
      raise ArgumentError, "unsupported generator: %s, try any of %s." % [
          name.inspect, registry.keys.inspect
      ] unless registry.has_key?(name)
      registry[name]
    end

    private

    attr_writer :registry
    def registry
      # XXX use a real registry to reduce coupling
      @registry ||= {'nginx' => VhostGenerator::NginxGenerator,
                     'apache' => VhostGenerator::ApacheGenerator}
    end

    def parse_word_list(s)
      String(s).split(/[,\s]+/)
    end

    def parse_option_list(s)
      Hash[ parse_word_list(s).map { |i| i.split('=', 2) } ]
    end

    def parse_integer_list(s)
      parse_word_list(s).map { |i| Integer(i) }
    end
  end
end