require 'vhost_generator/application'

module VhostGenerator

  # VhostGenerator module singleton methods.
  #
  class << self
    # Current VhostGenerator Application
    def application
      @application ||= VhostGenerator::Application.new
    end

    # Set the current VhostGenerator application object.
    def application=(app)
      @application = app
    end
  end
end
