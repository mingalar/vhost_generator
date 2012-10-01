require 'vhost_generator/cmdline_builder'

describe VhostGenerator::CmdlineBuilder do
  let(:config) { double('vhost config').as_null_object }
  subject do
    described_class.new(config, nil, nil, [])
  end

  describe "#cwd" do
    context "when a current directory is provided" do
      it "returns 'cd' followed by the current directory" do
        subject.cwd = 'CWD'
        expect(subject.cwd).to eql(['cd', 'CWD'])
      end
    end

    context "when no current directory is provided" do
      it "is nil" do
        subject.cwd = nil
        expect(subject.cwd).to be_nil
      end
    end
  end

  describe "#progname" do
    before { subject.progname = '/path/to/progname' }

    context "when no progname is provided" do
      it "is nil" do
        subject.progname = nil
        expect(subject.progname).to be_nil
      end
    end

    context "when bundler is in environment" do
      it "returns 'bundle exec' followed by the basename" do
        subject.env = Hash['BUNDLE_GEMFILE' => true, 'BUNDLE_BIN' => 'true']
        expect(subject.progname).to eql(['bundle', 'exec', 'progname'])
      end
    end

    context "when bundler is not in environment" do
      it "returns the full program name" do
        subject.env = Hash[]
        expect(subject.progname).to eql(['/path/to/progname'])
      end
    end
  end

  describe "#progargs" do
    it "describes config as commandline switches" do
      subject.config = mock(:static_folder => 'SF', :server_ports => [80,81],
                            :server_names => %w(A B),
                            :instance_ports => [5000,5001],
                            :relative_root => 'RR', :generator => 'nginx',
                            :generator_options => {'k' => 'a=b', 'l' => 'c'})
      expect(subject.progargs).to eql(['-f', 'SF', '-l', '80,81', '-s', 'A,B',
                                       '-p', '5000,5001', '-r', 'RR',
                                       '-g', 'nginx', '-o', 'k=a=b,l=c'])
    end
  end

  describe "#commands" do
    context "when a pwd is present" do
      it "is same as [#pwd, #progname + #progargs]" do
        subject.should_receive(:cwd).and_return('CWD')
        subject.should_receive(:progname).and_return('PROGNAME')
        subject.should_receive(:progargs).and_return('ARGS')
        expect(subject.commands).to eql(['CWD', 'PROGNAMEARGS'])
      end
    end

    context "when no pwd is present" do
      it "is same as [#progname + #progargs]" do
        subject.should_receive(:cwd).and_return(nil)
        subject.should_receive(:progname).and_return('PROGNAME')
        subject.should_receive(:progargs).and_return('ARGS')
        expect(subject.commands).to eql(['PROGNAMEARGS'])
      end
    end

    context "when no progname is present" do
      it "is empty" do
        subject.should_receive(:progname).and_return(nil)
        expect(subject.commands).to be_empty
      end
    end
  end

  describe "#to_str" do
    let(:cmd1) { %w(cd /path/to/directory) }
    let(:cmd2) { %w(bundle exec progname -x arg -y arg2) }

    it "is escaped #commands" do
      subject.should_receive(:commands).and_return([cmd2])
      cmdline = "bundle exec progname -x arg -y arg2"
      expect(subject.to_str).to eql(cmdline)
    end

    it "is escaped #commands joined by && & parenthesis" do
      subject.should_receive(:commands).and_return([cmd1, cmd2])
      cmdline = "(cd /path/to/directory && bundle exec progname -x arg -y arg2)"
      expect(subject.to_str).to eql(cmdline)
    end
  end
end
