require 'vhost_generator/nginx_generator'

describe VhostGenerator::NginxGenerator do
  let(:config) { double('vhost config').as_null_object }
  subject do
    described_class.new(config, 'upstream' => 'myupstream')
  end

  describe "#render" do
    let(:output) { subject.render }

    it "includes the cmdline in a comment" do
      config.stub(:cmdline).and_return('CMDLINE')
      expect(output).to match(/^#### FILE GENERATED BY .*CMDLINE/)
    end

    context "when multiple upstreams" do
      before { config.stub(:instance_ports).and_return([1337, 1338]) }

      it "declares the named upstream" do
        expect(output).to match(/upstream myupstream {/)
      end

      it "declares all the requested upstream servers" do
        expect(output).to include('server localhost:1337 fail_timeout=0;')
        expect(output).to include('server localhost:1338 fail_timeout=0;')
      end

      it "proxies to the named upstream" do
        expect(output).to include('proxy_pass http://myupstream;')
      end
    end

    context "when single upstream" do
      before { config.stub(:instance_ports).and_return([1337]) }

      it "declares no upstream section" do
        expect(output).not_to match(/upstream \w+ {/)
      end

      it "does not declare any upstream servers" do
        expect(output).not_to include('server localhost:1337 fail_timeout=0;')
      end

      it "proxies the single upstream directly" do
        expect(output).to include('proxy_pass http://localhost:1337;')
      end
    end

    it "listens to the requested server ports" do
      config.stub(:server_ports).and_return([12345, 12346])
      expect(output).to include('listen 12345;')
      expect(output).to include('listen 12346;')
    end

    it "declares the server names it responds to" do
      config.stub(:server_names).and_return(%w(host1 host2))
      expect(output).to include('server_name host1 host2;')
    end

    it "declares the requested document root" do
      config.stub(:static_folder).and_return('STATIC-FOLDER')
      expect(output).to include('root STATIC-FOLDER;')
    end

    it "forwards X-Forwarded-For header" do
      expect(output).to \
        include('proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;')
    end

    it "forwards X-Forwarded-Proto header" do
      expect(output).to include('proxy_set_header X-Forwarded-Proto $scheme;')
    end

    it "respects custom relative_roots" do
      config.stub(:relative_root).and_return('RELATIVE_ROOT')
      expect(output).to include('location RELATIVE_ROOTassets {')
    end
  end
end
