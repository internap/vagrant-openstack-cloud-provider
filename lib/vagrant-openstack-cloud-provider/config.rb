require "vagrant"
require "vagrant-openstack-cloud-provider/utils"

module VagrantPlugins
  module OpenStack
    class Config < Vagrant.plugin("2", :config)
      # The API key to access OpenStack.
      #
      # @return [String]
      attr_accessor :api_key

      # The endpoint to access OpenStack.
      #
      # @return [String]
      attr_accessor :endpoint

      # Openstack region, if your openstack instance uses these.
      # Rackspace typically uses these. You need to provide their three letter acronym (for example: DFW)
      # @return [String]
      attr_accessor :region

      # The flavor of server to launch, either the ID or name. This
      # can also be a regular expression to partially match a name.
      attr_accessor :flavor

      # The name or ID of the image to use. This can also be a regular
      # expression to partially match a name.
      attr_accessor :image

      # The name of the server. This defaults to the name of the machine
      # defined by Vagrant (via `config.vm.define`), but can be overriden
      # here.
      attr_accessor :server_name

      # The username to access OpenStack.
      #
      # @return [String]
      attr_accessor :username

      # The name of the keypair to use.
      #
      # @return [String]
      attr_accessor :keypair_name

      # The SSH username to use with this OpenStack instance. This overrides
      # the `config.ssh.username` variable.
      #
      # @return [String]
      attr_accessor :ssh_username

      # User data to be sent to the newly created OpenStack instance. Use this
      # e.g. to inject a script at boot time.
      #
      # @return [String]
      attr_accessor :user_data

      # Metadata to be sent to the newly created OpenStack instance.
      #
      # @return [Hash]
      attr_accessor :metadata

      # @return [String]
      attr_accessor :public_network_name

      # @return [String]
      attr_accessor :networks

      # @return [String]
      attr_accessor :tenant

      # Used by keystone v3

      # @return [String]
      attr_accessor :project_name

      # @return [String]
      attr_accessor :project_id

      # @return [String]
      attr_accessor :domain_name

      # @return [String]
      attr_accessor :domain_id

      # @return [String]
      attr_accessor :project_domain_name

      # @return [String]
      attr_accessor :project_domain_id

      # @return [String]
      attr_accessor :user_domain_name

      # @return [String]
      attr_accessor :user_domain_id

      # @return [String]
      attr_accessor :availability_zone

      # Version to use for keystone authentication
      # Not used for now, will be supported in the next version.
      # Known version are 'v2.0', 'v3'
      # @return [String]
      casting_attr_accessor :identity_api_version, String

      # @return [Hash]
      attr_accessor :scheduler_hints

      # @return [Integer]
      casting_attr_accessor :instance_build_timeout, Integer, greater_than(0)

      # @return [Integer]
      casting_attr_accessor :instance_build_status_check_interval, Integer, greater_than(0)

      # @return [Integer]
      casting_attr_accessor :instance_ssh_timeout, Integer, greater_than(0)

      # @return [Integer]
      casting_attr_accessor :instance_ssh_check_interval, Integer, greater_than(0)

      # @return [Bool]
      attr_accessor :report_progress
      # alias_method :report_progress?, :report_progress

      def initialize
        @api_key  = UNSET_VALUE
        @domain_id  = UNSET_VALUE
        @endpoint = UNSET_VALUE
        @region = UNSET_VALUE
        @flavor   = UNSET_VALUE
        @image    = UNSET_VALUE
        @server_name = UNSET_VALUE
        @username = UNSET_VALUE
        @keypair_name = UNSET_VALUE
        @ssh_username = UNSET_VALUE
        @user_data = UNSET_VALUE
        @metadata = UNSET_VALUE
        @public_network_name = UNSET_VALUE
        @networks = UNSET_VALUE
        @tenant = UNSET_VALUE
        @scheduler_hints = UNSET_VALUE
        @instance_build_timeout = UNSET_VALUE
        @instance_build_status_check_interval = UNSET_VALUE
        @instance_ssh_timeout = UNSET_VALUE
        @instance_ssh_check_interval = UNSET_VALUE
        @report_progress = UNSET_VALUE
        @availability_zone = UNSET_VALUE

        @project_name = UNSET_VALUE
        @project_id = UNSET_VALUE
        @domain_name = UNSET_VALUE
        @domain_id = UNSET_VALUE
        @project_domain_name = UNSET_VALUE
        @project_domain_id = UNSET_VALUE
        @user_domain_name = UNSET_VALUE
        @user_domain_id = UNSET_VALUE
        @identity_api_version = UNSET_VALUE

      end

      def finalize!
        @api_key  = nil if @api_key == UNSET_VALUE
        @domain_id  = nil if @domain_id == UNSET_VALUE
        @endpoint = nil if @endpoint == UNSET_VALUE
        @region = nil if @region == UNSET_VALUE
        @flavor   = /m1.tiny/ if @flavor == UNSET_VALUE
        @image    = /cirros/ if @image == UNSET_VALUE
        @server_name = nil if @server_name == UNSET_VALUE
        @username = nil if @username == UNSET_VALUE

        @project_name = nil if @project_name == UNSET_VALUE
        @project_id = nil if @project_id == UNSET_VALUE
        @domain_name = nil if @domain_name == UNSET_VALUE
        @domain_id = nil if @domain_id == UNSET_VALUE
        @project_domain_name = nil if @project_domain_name == UNSET_VALUE
        @project_domain_id = nil if @project_domain_id == UNSET_VALUE
        @user_domain_name = nil if @user_domain_name == UNSET_VALUE
        @user_domain_id = nil if @user_domain_id == UNSET_VALUE
        @identity_api_version = nil if @identity_api_version == UNSET_VALUE
        @identity_api_version = @identity_api_version.reverse.chomp('v').reverse if @identity_api_version

        # Keypair defaults to nil
        @keypair_name = nil if @keypair_name == UNSET_VALUE

        # The SSH values by default are nil, and the top-level config
        # `config.ssh` values are used.
        @ssh_username = nil if @ssh_username == UNSET_VALUE

        @user_data = "" if @user_data == UNSET_VALUE
        @metadata = {} if @metadata == UNSET_VALUE

        @public_network_name = "public" if @public_network_name == UNSET_VALUE
        @networks = [@public_network_name] if @networks == UNSET_VALUE
        @tenant = nil if @tenant == UNSET_VALUE
        @scheduler_hints = {} if @scheduler_hints == UNSET_VALUE
        @instance_build_timeout = 120 if @instance_build_timeout == UNSET_VALUE
        @instance_build_status_check_interval = 1 if @instance_build_status_check_interval == UNSET_VALUE
        @instance_ssh_timeout = 120 if @instance_ssh_timeout == UNSET_VALUE
        @instance_ssh_check_interval = 2 if @instance_ssh_check_interval == UNSET_VALUE

        @availability_zone = nil if @availability_zone == UNSET_VALUE
        @report_progress = true if @report_progress == UNSET_VALUE
      end

      def validate(machine)
        errors = []

        errors << I18n.t("vagrant_openstack.config.api_key_required") if !@api_key
        errors << I18n.t("vagrant_openstack.config.username_required") if !@username

        { "OpenStack Provider" => errors }
      end
    end
  end
end
