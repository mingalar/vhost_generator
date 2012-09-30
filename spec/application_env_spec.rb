require 'vhost_generator/application'
require 'ostruct'

describe VhostGenerator::Application do
  describe "Env" do
    let(:config) { OpenStruct.new }
    before { subject.config = config }

    options = Hash[
      'static_folder'     => 'STATIC_FOLDER',
      'server_ports'      => 'SERVER_PORTS',
      'server_names'      => 'SERVER_NAMES',
      'instance_ports'    => 'INSTANCE_PORTS',
      'relative_root'     => 'RAILS_RELATIVE_URL_ROOT',
      'generator'         => 'GENERATOR',
      'generator_options' => 'GENERATOR_OPTIONS',
    ]

    options.each_pair do |name, var|
      describe "#{name} option" do
        it "is set by the #{var} variable" do
          expect {
            subject.handle_env(var => 'value')
          }.to change(config, name).to('value')
        end
      end
    end
  end
end
