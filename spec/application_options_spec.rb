require 'vhost_generator/application'
require 'ostruct'

describe VhostGenerator::Application do
  describe "Options" do
    let(:config) { OpenStruct.new }
    before { subject.config = config }

    options = Hash[
      'static_folder'     => %w(-f --static-folder),
      'server_ports'      => %w(-l --listen),
      'server_names'      => %w(-s --server-name),
      'instance_ports'    => %w(-p --instance-port),
      'relative_root'     => %w(-r --relative-root),
      'generator'         => %w(-g --generator),
      'generator_options' => %w(-o --generator-options)
    ]

    options.each_pair do |name, flags|
      describe "#{name} option" do
        flags.each do |flag|
          it "is set by the #{flag} flag" do
            expect {
              subject.handle_options([flag, 'value'])
            }.to change(config, name).to('value')
          end
        end
      end
    end
  end
end
