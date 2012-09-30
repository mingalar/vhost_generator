require 'ostruct'
require 'erb'

module VhostGenerator

  # Nginx VhostGenerator
  #
  class NginxGenerator
    attr_reader :cfg, :options
    def initialize(cfg, options={})
      @cfg = cfg
      @options = OpenStruct.new(default_options.merge(options)).freeze
    end

    def render
      template.result(binding)
    end

    protected

    def default_options
      Hash[ 'client_max_body_size' => '4G', 'keepalive_timeout' => '10',
            'assets_expire_in' => '60d' ].freeze
    end

    private

    def template
      @template ||= ERB.new <<EOF
#### FILE GENERATED BY `<%= String(cfg.cmdline) %>`, EDIT AT YOUR OWN RISK ####

upstream <%= options.upstream %> {
<% cfg.instance_ports.each do |p| %>  server localhost:<%= p %> fail_timeout=0;
<% end %>}

server {
  <% cfg.server_ports.each do |p| %>listen <%= p %>;
  <% end %>
  <% unless cfg.server_names.empty? %>server_name <%=
       cfg.server_names.join(', ') %>;<% end %>

  root <%= cfg.static_folder %>;

  try_files $uri/index.html $uri @upstream;
  location @upstream {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://<%= options.upstream %>;
  }

  location <%= cfg.relative_root %>assets {
    gzip_static on; # to serve pre-gzipped version
    expires <%= options.assets_expire_in %>;
    add_header  Cache-Control public;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size <%= options.client_max_body_size %>;
  keepalive_timeout <%= options.keepalive_timeout %>;
}
EOF
    end
  end
end