Feature: Wrap "foreman export"

  In order to generate and install a foreman web application to a virtualhost
  As a user of the library
  I want to run "foreman export" and "vhost-generator" together with DRY arguments.

  Scenario: display help
    When I run `bundle exec foreman-export-vhost --help`
    Then it should pass with:
      """
      Usage: foreman-export-vhost FORMAT LOCATION

      Foreman options:
          -a, --app=APP
          -l, --log=LOG
          -e, --env=ENV                    # Specify an environment file to load, defaults to .env
          -p, --port=N                     # Default: 5000
          -u, --user=USER
          -t, --template=TEMPLATE
          -c, --concurrency=alpha=5,bar=3
          -f, --procfile=PROCFILE          # Default: Procfile
          -d, --root=ROOT                  # Default: Procfile directory

      Vhost-generator options:
          -F, --static-folder=FOLDER       # Default: "public" folder in Procfile directory
          -L, --server-ports=PORTS         # Default: 80
          -S, --server-names=NAMES         # Default: localhost
          -K, --foreman-process-type=TYPE  # Default: web (must have entry of that name in Procfile)
          -G, --generator=GENERATOR        # Default: "nginx" (try "apache" too)
          -O, --generator-options=OPTIONS  # Comma-separated list of key=value
          -N, --dry-run
          -R, --stop-start-service         # Starts and stops APP service (may not work everywhere)

          -h, -H, --help                   Display this help message.
      """

  Scenario: display source that will be executed
    Given a file named "Procfile" with:
      """
      clock:  ....
      web:   bundle exec webserver -p $PORT
      """
    When I run `bundle exec foreman-export-vhost upstart /etc/init -f Procfile -a MYAPP -u MYUSER -p 6000 -c clock=1,web=2 -L 80,81 -S localhost,myapp.com -K web -G nginx -O assets_expire_in=15d -N -R`
    Then the output should match:
      """
      bundle exec foreman run vhost-generator -a MYAPP -f /.*/public -l 80,81 -s localhost,myapp.com -p 6100,6101 -g nginx -o assets_expire_in\\=15d \| sudo tee /etc/nginx/sites-enabled/vhost-MYAPP.conf
      """
    And the output should contain:
      """
      sudo service nginx reload
      sudo service MYAPP stop >/dev/null 2>&1 || true
      sudo rm -rf /etc/init/MYAPP-*.conf
      """
    And the output should match:
      """
      sudo bundle exec foreman export upstart /etc/init -a MYAPP -p 6000 -u MYUSER -c clock\\=1,web\\=2 -f /.*/Procfile -d /.*$
      """
    And the output should contain:
      """
      sudo service MYAPP start
      echo "Finished, now open your browser and see if everything works."
      # Now, try to run this script again without the --dry-run switch!
      """
