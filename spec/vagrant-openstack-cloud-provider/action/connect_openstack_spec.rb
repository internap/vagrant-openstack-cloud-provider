require 'spec_helper'
require 'vagrant-openstack-cloud-provider/errors'
require 'vagrant-openstack-cloud-provider/action/connect_openstack'
require "fog/openstack"

RSpec.describe VagrantPlugins::OpenStack::Action::ConnectOpenStack do
  describe '#call?' do
    let (:app) { double }
    let (:machine) { double }

    default_config = {
        :region    => nil,
        :tenant    => nil,
        :project_name => nil,
        :project_id => nil,
        :domain_name => nil,
        :domain_id => nil,
        :project_domain_name => nil,
        :project_domain_id => nil,
        :user_domain_name => nil,
        :user_domain_id => nil,
        :identity_api_version=> nil,
    }

    let (:config) { double(default_config.merge(
        :username  => 'username',
        :api_key   => 'password',
        :endpoint  => 'http://openstack.invalid/',
    ))}

    subject {
      described_class.new(app, nil)
    }

    after(:each) {
      $openstack_compute = nil
      $openstack_network = nil
    }

    it "should new members in env" do
      expect(app).to receive(:call)
      expect(machine).to receive(:provider_config).and_return(config)
      env = { :machine => machine }

      subject.call(env)

      expect(env).to have_key(:openstack_compute)
      expect(env).to have_key(:openstack_network)
    end

    {Fog::Compute => :openstack_compute,
     Fog::Network => :openstack_network}.each do |klass, attribute|
      it "should late-evaluate #{klass}" do
        expect(app).to receive(:call)
        expect(machine).to receive(:provider_config).and_return(config)
        env = { :machine => machine }

        expect(klass).to receive(:new).and_raise(MyError)

        subject.call(env)

        expect { env[attribute].any_call }.to raise_error(MyError)
      end
    end

    it "should initialize correctly on v2", :type => 'legacy' do
      expect(app).to receive(:call).at_least(:once)
      expect(subject).to receive(:get_fog_promise).at_least(:once).with(
          "Compute", hash_including(:openstack_auth_url => 'http://openstack.invalid/v2.0/tokens')
      ).ordered
      expect(subject).to receive(:get_fog_promise).at_least(:once).with("Network", any_args).ordered
      env = { :machine => machine }

      expect(machine).to receive(:provider_config).at_least(:once).and_return(
          double(default_config.merge(
            :username  => 'username',
            :api_key   => 'password',
            :endpoint  => 'http://openstack.invalid/v2.0/tokens',
          ))
      )

      subject.call(env)
    end

    it "should initialize correctly" do
      expect(app).to receive(:call).at_least(:once)
      expect(subject).to receive(:get_fog_promise).at_least(:once).with(
          "Compute", hash_including(
            :openstack_auth_url => 'http://openstack.invalid/v3/auth/tokens',
            :openstack_project_name => 'project_name',
            :openstack_domain_id => 'default',
            :openstack_user_domain => 'default',
            )
      )
      expect(subject).to receive(:get_fog_promise).at_least(:once).with("Network", any_args)
      env = { :machine => machine }

      expect(machine).to receive(:provider_config).at_least(:once).and_return(
          double(default_config.merge(
              :username  => 'username',
              :api_key   => 'password',
              :endpoint  => 'http://openstack.invalid/',
              :project_name => 'project_name',
              :domain_id => 'default',
              :user_domain_name => 'default',
              :identity_api_version => '3',
          ))
      )

      subject.call(env)
    end

    it "autocompletes keystone url according to the version" do
      expect(subject.complete_auth_url('2', "http://openstack.invalid/v2.0/tokens")).to eq("http://openstack.invalid/v2.0/tokens")
      expect(subject.complete_auth_url('2', "http://openstack.invalid/v2.0")).to eq("http://openstack.invalid/v2.0/tokens")
      expect(subject.complete_auth_url('2', "http://openstack.invalid/")).to eq("http://openstack.invalid/v2.0/tokens")
      expect(subject.complete_auth_url('2.0', "http://openstack.invalid/")).to eq("http://openstack.invalid/v2.0/tokens")

      expect(subject.complete_auth_url('3', "http://openstack.invalid/v3/auth/tokens")).to eq("http://openstack.invalid/v3/auth/tokens")
      expect(subject.complete_auth_url('3', "http://openstack.invalid/v3/")).to eq("http://openstack.invalid/v3/auth/tokens")
      expect(subject.complete_auth_url('3', "http://openstack.invalid/")).to eq("http://openstack.invalid/v3/auth/tokens")

      expect(subject.complete_auth_url('45', "http://openstack.invalid/untouched")).to eq("http://openstack.invalid/untouched")
    end

    it "should memoize the fog call" do
      expect(app).to receive(:call).at_least(:once)
      expect(machine).to receive(:provider_config).at_least(:once).and_return(config)
      env = { :machine => machine }

      expect(Kernel).to receive(:promise).twice.and_return('TEST') # 1x compute, 1x network
      10.times { subject.call(env) }
    end
  end
end

class MyError < StandardError

end
