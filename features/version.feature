Feature: Output program version

  In order to know if I am up to date
  As a user of the library
  I want to know the current version of vhost-generator.

  Scenario: output program version
    When I run `bundle exec vhost-generator --version`
    Then it should pass with:
      """
      vhost-generator, version 0.0.2
      """
