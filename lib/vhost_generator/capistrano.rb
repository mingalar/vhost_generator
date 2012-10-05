require 'shellwords'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :vhost do
    _cset(:vhost_port) { 5000 }
    _cset(:vhost_env) { nil }
    _cset(:vhost_concurrency) { nil }
    _cset(:vhost_procfile) { 'Procfile' }
    _cset(:vhost_server_ports) { '80' }
    _cset(:vhost_server_names) { 'localhost' }
    _cset(:vhost_process) { abort "Please specify the foreman process type, set :vhost_process, 'web' (if you have 'web' in your Procfile)" }
    _cset(:vhost_generator) { abort "Please specify the target web server, set :vhost_generator, 'nginx' (or 'apache')" }
    _cset(:vhost_generator_options) { nil }

    desc <<-DESC
  Runs the "foreman-export-vhost" command to manage a foreman-enabled \
application using upstart and generate nginx or apache virtualhost configuration \
file to serve it to web clients.

You can override any of these defaults by setting the variables shown below.

    set :vhost_port,               #{vhost_port.inspect}
    set :vhost_env,                #{vhost_env.inspect}
    set :vhost_concurrency,        #{vhost_concurrency.inspect}
    set :vhost_procfile,           #{vhost_procfile.inspect}
    set :vhost_server_ports,       #{vhost_server_ports.inspect}
    set :vhost_server_names,       #{vhost_server_names.inspect}
    set :vhost_generator,
    set :vhost_generator_options,  #{vhost_generator_options.inspect}
    set :vhost_process
    DESC
    task :export do
      cmdline = "foreman-export-vhost upstart /etc/init -u $USER"
      cmdline << " -a #{application.shellescape}"
      cmdline << " -p #{String(vhost_port).shellescape}"
      cmdline << " -e #{vhost_env.shellescape}" if vhost_env
      cmdline << " -f #{vhost_procfile.shellescape}" if vhost_procfile
      cmdline << " -c #{vhost_concurrency.shellescape}" if vhost_concurrency
      cmdline << " -K #{vhost_process.shellescape}"
      cmdline << " -L #{vhost_server_ports.shellescape}" if vhost_server_ports
      cmdline << " -S #{vhost_server_names.shellescape}" if vhost_server_names
      cmdline << " -G #{vhost_generator.shellescape}" if vhost_generator
      cmdline << " -O #{vhost_generator_options.shellescape}" if vhost_generator_options
      run "cd #{release_path} && #{sudo} RAILS_ENV=#{rails_env} bundle exec #{cmdline}"
    end

    before 'deploy:create_symlink', 'vhost:export'
  end

  # Each application is turned into an upstart service by 'foreman export'.
  namespace :deploy do
    task :start do
      run "#{sudo} service #{application.shellescape} start"
    end

    task :stop do
      run "#{sudo} service #{application.shellescape} stop"
    end

    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{sudo} service #{application.shellescape} restart"
    end
  end
end
