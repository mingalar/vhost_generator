# VhostGenerator

This gem outputs a general-purpose VirtualHost configuration file
to run your web application behind an nginx or apache frontend.

The motivation of this gem is to automate that tedious task the first time, but
also every time the virtualhost parameters (such as the number of instances to
run and the ports where the instances are listening).

The gem features tries to integrate with the [foreman][1] gem by:
* reading configuration parameters from `ENV` (or from the `.env` file if present)
* detecting whether to proxy to tcp or unix socket from `Procfile` if present
* reading configuration from foreman's standard environment variables to allow
for generating a virtualhost that matches the last `foreman export`.

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

Protip: pipe with `sudo tee` to save the configuration in your nginx sites-enabled directory.

    $ bundle exec vhost-generator -l 80 -s myapp.com -p 5000,5001,5002 | sudo tee /etc/nginx/sites-enabled/myapp

More advanced usages: see `features/` directory or run:

    $ bundle exec vhost-generator --help

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: https://github.com/ddollar/foreman "Foreman"