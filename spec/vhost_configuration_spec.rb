require 'vhost_generator/vhost_configuration'

describe VhostGenerator::VhostConfiguration do
  describe "#static_folder" do
    it "is 'public/' by default" do
      expect(subject.static_folder).to eql(File.expand_path('public'))
    end

    it "expanded" do
      expect {
        subject.static_folder = 'html'
      }.to change(subject, :static_folder).to File.expand_path('html')
    end
  end

  describe "#server_ports" do
    it "is 80 by default" do
      expect(subject.server_ports).to eql([80])
    end

    it "parses to Array of Integer" do
      expect {
        subject.server_ports = '80,81'
      }.to change(subject, :server_ports).to [80, 81]
    end

    it "complains when trying to set invalid values" do
      expect {
        subject.server_ports = '80a'
      }.to raise_error(ArgumentError, /invalid value for Integer/)
    end
  end

  describe "#server_names" do
    it "is 'localhost' by default" do
      expect(subject.server_names).to eql(%w(localhost))
    end

    it "parses to Array of String" do
      expect {
        subject.server_names = 'localhost , test.host'
      }.to change(subject, :server_names).to %w(localhost test.host)
    end
  end

  describe "#instance_ports" do
    it "is empty by default" do
      expect(subject.instance_ports).to be_empty
    end

    it "parses to Array of Integer" do
      expect {
        subject.instance_ports = '5000,5001'
      }.to change(subject, :instance_ports).to [5000, 5001]
    end

    it "complains when trying to set invalid values" do
      expect {
        subject.instance_ports = '5000a'
      }.to raise_error(ArgumentError, /invalid value for Integer/)
    end
  end

  describe "#relative_root" do
    it "is '/' by default" do
      expect(subject.relative_root).to eql('/')
    end

    it "appends '/' at end" do
      expect {
        subject.relative_root = '/myapp'
      }.to change(subject, :relative_root).to '/myapp/'
    end

    it "strips redundant slashes" do
      expect {
        subject.relative_root = '/path//to///myapp////'
      }.to change(subject, :relative_root).to '/path/to/myapp/'
    end
  end

  describe "#cmdline" do
    it "is empty by default" do
      subject.cmdline.should be_empty
    end

    it "can be append to using the shovel operator" do
      subject.cmdline.should respond_to(:<<)
    end

    it "can be coerced into string" do
      subject.cmdline.should respond_to(:to_str)
    end
  end

  describe "#generator" do
    it "is present by default" do
      expect(subject.generator).to be
    end

    it "is resolved into a generator plugin" do
      generator = double('generator')
      subject.send(:registry).merge!('test' => generator)
      expect {
        subject.generator = 'test'
      }.to change(subject, :generator).to generator
    end

    it "complains when trying to set invalid values" do
      expect {
        subject.generator = 'xyzzy'
      }.to raise_error(ArgumentError, /unsupported generator/)
    end
  end

  describe "#generator_options" do
    it "is empty by default" do
      expect(subject.generator_options).to be_empty
    end

    it "parses to Hash[key=value]" do
      expect {
        subject.generator_options = 'k=a=b , l=j'
      }.to change(subject, :generator_options).to Hash['k' => 'a=b', 'l' => 'j']
    end
  end
end
