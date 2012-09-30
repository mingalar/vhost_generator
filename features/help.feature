Feature: Output help summary

  In order to know how to invoke the program
  As a user of the library
  I want to display the program's help summary.

  Scenario: output program help summary
    When I run `bundle exec vhost-generator --help`
    Then it should pass with:
      """
      Display this help message.
      """
