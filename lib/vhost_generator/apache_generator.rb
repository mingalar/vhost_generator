require 'ostruct'
require 'erb'

module VhostGenerator

  # Apache VhostGenerator
  #
  class ApacheGenerator
    attr_reader :cfg, :options
    def initialize(cfg, options={})
      @cfg = cfg
      @options = OpenStruct.new(default_options.merge(options))
      @options.upstream ||= cfg.application
      @options.has_upstream = cfg.instance_ports.length > 1
      @options.proxy_pass =
          if @options.has_upstream
            "balancer://#{@options.upstream}"
          elsif cfg.instance_ports.length > 0
            "http://localhost:#{cfg.instance_ports.first}"
          else
            raise ArgumentError, "Please specify at least 1 instance-port."
          end
      # by commodity, support same syntax as nginx: 15d, 2m, 1y
      expires = {'d' => 'days', 'm' => 'months', 'y' => 'years'}
      @options.assets_expire_in.gsub!(/\A(\d+)([dmy])\Z/) do |_|
        [$~[1], expires.fetch($~[2])].join(' ') # s/15d/15 days/g
      end
      # by commodity, support same syntax as nginx: 2k, 2M, 2G
      sizes = {'k' => 1024, 'M' => 1024**2, 'G' => 1024**3}
      if @options.client_max_body_size =~ /\A(\d+)([kMG])\Z/
        @options.client_max_body_size = Integer($~[1]) * sizes[$~[2]] - 1
      else
        @options.client_max_body_size = Integer(@options.client_max_body_size)
      end
      # apache does not support body sizes > 2G
      if @options.client_max_body_size > (size_max = 2 * sizes['G'] - 1)
        @options.client_max_body_size = size_max
      end
      @options.freeze
    end

    def render
      template.result(binding)
    end

    protected

    def default_options
      Hash[ 'client_max_body_size' => '2G', # max for apache
            'keepalive_timeout' => '10',
            'assets_expire_in' => '60d' ].freeze
    end

    private

    def template
      @template ||= ERB.new <<EOF
#### FILE GENERATED BY `<%= String(cfg.cmdline) %>`, EDIT AT YOUR OWN RISK ####
#### Note: you may need to a2enmod the following modules: proxy_http, proxy_balancer, rewrite, headers, expires

<VirtualHost <%= cfg.server_ports.map{ |p| "*:\#{p}" }.join(' ') %>>
  <% unless cfg.server_names.empty? %>ServerName <%= cfg.server_names.first %><% end %>
  <% if cfg.server_names.length >= 2 %>ServerAlias <%=
       cfg.server_names[1..-1].join(' ') %><% end %>

  DocumentRoot <%= cfg.static_folder %>;

  AllowEncodedSlashes On

  <% if options.has_upstream %>
  <Proxy balancer://<%= options.upstream %>>
  <% cfg.instance_ports.each do |p| %>  BalancerMember http://localhost:<%= p %>
  <% end %></Proxy>
  <% end %>

  # Redirect all non-static requests to instances
  RewriteEngine On
  RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
  RewriteRule ^/(.*)$ <%= options.proxy_pass %>%{REQUEST_URI} [P,QSA,L]

  <Location <%= cfg.relative_root %>assets>
    ExpiresActive On
    Header unset ETag
    FileETag None
    ExpiresDefault "access plus <%= options.assets_expire_in %>"
  </Location>

  ErrorDocument 500 /500.html
  ErrorDocument 502 /500.html
  ErrorDocument 503 /500.html
  ErrorDocument 504 /500.html
  LimitRequestBody <%= options.client_max_body_size %>
  KeepAliveTimeout <%= options.keepalive_timeout %>
</VirtualHost>
EOF
    end
  end
end
