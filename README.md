# VhostGenerator

This gem outputs a general-purpose VirtualHost configuration file
to run your web application behind an nginx or apache frontend.

The motivation of this gem is to automate that tedious task the first time, but
also every time the virtualhost parameters (such as the number of instances to
run and the ports where the instances are listening).

The gem features tries to integrate with the [foreman][1] gem by:
* reading configuration parameters from `ENV` (or from the `.env` file if invoked via `foreman run`)


## Installation

Add this line to your application's Gemfile:

    gem 'vhost_generator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vhost_generator

## Usage

Basic usage:

    $ bundle exec vhost-generator -l 80 -s myapp.com -p 5000,5001,5002

Advanced usage: all command-line switches have their equivalent environment variables. See note in `bundle exec vhost-generator --help`.

    $ SERVER_PORTS=80 SERVER_NAMES=myapp.com INSTANCE_PORTS=5000,5001,5002 bundle exec vhost-generator

More advanced usages: see `features/` directory or run:

    $ bundle exec vhost-generator --help

This gem also contains a wrapper to `foreman export` that will extract as many parameters from your `foreman export` command-line to make your generated virtualhost consistent with your `Procfile`, especially regarding the instance ports used.

    $ bundle exec foreman-export-vhost --help

## Tips

Pipe with `sudo tee` to save the configuration in your nginx sites-enabled directory.

    $ bundle exec vhost-generator -l 80 -s myapp.com -p 5000,5001,5002 | sudo tee /etc/nginx/sites-enabled/myapp

Run through `foreman run` to leverage your application's `.env` (DRY and handy when having a configured `RAILS_RELATIVE_URL_ROOT` for example).

    $ echo RAILS_RELATIVE_URL_ROOT='/myapp' >> .env
    $ bundle exec foreman run vhost-generator -l 80 -s myapp.com -p 5000,5001,5002

Check the comment at top of each virtualhost configuration file for a command-line that can regenerate the file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: https://github.com/ddollar/foreman "Foreman"