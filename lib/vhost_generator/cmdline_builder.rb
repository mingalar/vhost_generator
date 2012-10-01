require 'shellwords'

module VhostGenerator

  # Represents a Shell command line (to display in vhost comments)
  class CmdlineBuilder
    attr_writer :config, :cwd, :progname, :env

    def initialize(config, cwd, progname, env)
      self.config = config
      self.cwd = cwd
      self.progname = progname
      self.env = env
    end

    def cwd
      @cwd ? ['cd', @cwd] : nil
    end

    def progname
      if @progname
        if @env.keys.grep(/^BUNDLE_/).empty?
          [@progname]
        else
          ['bundle', 'exec', File.basename(@progname)]
        end
      end
    end

    def progargs
      args = []
      args << '-f' << @config.static_folder
      args << '-l' << @config.server_ports.join(',')
      args << '-s' << @config.server_names.join(',')
      args << '-p' << @config.instance_ports.join(',')
      args << '-r' << @config.relative_root
      args << '-g' << 'nginx' # FIXME use @config.generator when real registry
      options = @config.generator_options.collect {|k,v| "#{k}=#{v}" }
      args << '-o' << options.join(',')
      args
    end

    def commands
      if prog_name = progname
        [cwd, prog_name + progargs].compact
      else
        []
      end
    end

    def to_str
      parts = commands.collect { |cmd| Shellwords.shelljoin(cmd) }
      if parts.length > 1
        "(#{ parts.join(' && ') })"
      else
        parts.first
      end
    end
  end
end
