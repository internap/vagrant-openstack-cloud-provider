require 'spec_helper'
require "vagrant-openstack-cloud-provider/config"
require "vagrant-openstack-cloud-provider/utils"

RSpec.describe VagrantPlugins::OpenStack::Config do
  describe "defaults" do
    let(:vagrant_public_key) { Vagrant.source_root.join("keys/vagrant.pub") }

    subject do
      super().tap do |o|
        o.finalize!
      end
    end

    it { is_expected.to have_attributes(api_key: nil) }
    it { is_expected.to have_attributes(endpoint: nil) }
    it { is_expected.to have_attributes(region: nil) }
    it { is_expected.to have_attributes(flavor: /m1.tiny/) }
    it { is_expected.to have_attributes(image: /cirros/) }
    it { is_expected.to have_attributes(server_name: nil) }
    it { is_expected.to have_attributes(username: nil) }
    it { is_expected.to have_attributes(keypair_name: nil) }
    it { is_expected.to have_attributes(ssh_username: nil) }
    it { is_expected.to have_attributes(user_data: "") }
    it { is_expected.to have_attributes(metadata: {}) }
    it { is_expected.to have_attributes(public_network_name: "public") }
    it { is_expected.to have_attributes(networks: ["public"]) }
    it { is_expected.to have_attributes(tenant: nil) }
    it { is_expected.to have_attributes(project_name: nil) }
    it { is_expected.to have_attributes(domain_id: nil) }

    it { is_expected.to have_attributes(project_name: nil) }
    it { is_expected.to have_attributes(project_id: nil) }
    it { is_expected.to have_attributes(domain_name: nil) }
    it { is_expected.to have_attributes(domain_id: nil) }
    it { is_expected.to have_attributes(project_domain_name: nil) }
    it { is_expected.to have_attributes(project_domain_id: nil) }
    it { is_expected.to have_attributes(user_domain_name: nil) }
    it { is_expected.to have_attributes(user_domain_id: nil) }
    it { is_expected.to have_attributes(identity_api_version: nil) }

    it { is_expected.to have_attributes(scheduler_hints: {}) }
    it { is_expected.to have_attributes(availability_zone: nil) }
    it { is_expected.to have_attributes(instance_build_timeout: 120) }
    it { is_expected.to have_attributes(instance_build_status_check_interval: 1) }
    it { is_expected.to have_attributes(instance_ssh_timeout: 120) }
    it { is_expected.to have_attributes(instance_ssh_check_interval: 2) }
    it { is_expected.to have_attributes(report_progress: true) }
  end

  describe "overriding defaults - strings" do
    [:api_key,
      :endpoint,
      :region,
      :flavor,
      :image,
      :server_name,
      :username,
      :keypair_name,
      :ssh_username,
      :metadata,
      :public_network_name,
      :networks,
      :tenant,
      :project_name,
      :project_id,
      :domain_name,
      :domain_id,
      :project_domain_name,
      :project_domain_id,
      :user_domain_name,
      :user_domain_id,
      :identity_api_version,
      :scheduler_hints,
      :availability_zone,
      :report_progress].each do |attribute|
      it "should not default #{attribute} if overridden" do
        subject.send("#{attribute}=", "foo")
        subject.finalize!
        expect(subject.send(attribute)).to eq("foo")
      end
    end
  end

  describe "openstack v3" do
    let(:vagrant_public_key) { Vagrant.source_root.join("keys/vagrant.pub") }

    def test(key, value)
      subject.send("#{key}=", value)
      subject.finalize!
      subject.send(key)
    end

    it 'parses identity version' do
      expect(test('identity_api_version', '3')).to eq('3')
      expect(test('identity_api_version', '2.0')).to eq('2.0')
      expect(test('identity_api_version', '2.1')).to eq('2.1')
      expect(test('identity_api_version', 'v2.0')).to eq('2.0')
      expect(test('identity_api_version', 'v3')).to eq('3')
      expect(test('identity_api_version', 3)).to eq('3')
      expect(test('identity_api_version', 2)).to eq('2')
    end
  end

  describe "overriding defaults - integers" do
    [:instance_build_timeout,
     :instance_build_status_check_interval,
     :instance_ssh_timeout,
     :instance_ssh_check_interval].each do |attribute|
      it "should not default #{attribute} if overridden" do
        subject.send("#{attribute}=", 12345)
        subject.finalize!
        expect(subject.send(attribute)).to eq(12345)
      end
    end
  end

  describe "validation" do
    let(:machine) { double("machine") }

    subject do
      super().tap do |o|
        o.finalize!
      end
    end

    context "the numeric values" do
      [:instance_build_timeout,
       :instance_build_status_check_interval,
       :instance_ssh_timeout,
       :instance_ssh_check_interval].each do |attribute|
        it "should cast #{attribute} to an int" do
          subject.send("#{attribute}=", "100")
          subject.finalize!
          expect(subject.send(attribute)).to eq(100)
        end
        it "should raise when given a wrong value" do
          expect { subject.send("#{attribute}=", "huhu") }.to raise_error(ArgumentError)
        end
      end
    end

    context "non-null positive integers" do
      [:instance_build_timeout,
       :instance_build_status_check_interval,
       :instance_ssh_timeout,
       :instance_ssh_check_interval].each do |attribute|
        it "should cast #{attribute} to an int" do
          expect { subject.send("#{attribute}=", "0") }.to raise_error(InvalidValue)
          expect { subject.send("#{attribute}=", -1) }.to raise_error(InvalidValue)
        end
      end
    end
  end
end
