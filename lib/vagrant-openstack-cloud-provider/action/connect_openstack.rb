require "fog/openstack"
require "log4r"
require 'promise'

module VagrantPlugins
  module OpenStack
    module Action
      # This action connects to OpenStack, verifies credentials work, and
      # puts the OpenStack connection object into the `:openstack_compute` key
      # in the environment.
      class ConnectOpenStack
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_openstack::action::connect_openstack")
        end

        def call(env)
          config = env[:machine].provider_config

          auth_uri = complete_auth_url(config.identity_api_version, config.endpoint)

          openstack_options = {
              :provider => :openstack,
              :openstack_region => config.region,
              :openstack_username => config.username,
              :openstack_api_key => config.api_key,
              :openstack_auth_url => auth_uri,
              :openstack_tenant => config.tenant,

              :openstack_project_name => config.project_name,
              :openstack_project_id => config.project_id,
              :openstack_domain_name => config.domain_name,
              :openstack_domain_id => config.domain_id,
              :openstack_user_domain => config.user_domain_name,
              :openstack_user_domain_id => config.user_domain_id,
              :openstack_project_domain => config.project_domain_name,
              :openstack_project_domain_id => config.project_domain_id,
          }


          # For now, fogs autodetects the version in the url.
          # Using version >1.0 of fog-openstack, we will use the
          # identity_api_version to select the right version

          $openstack_compute ||= get_fog_promise('Compute', openstack_options)
          $openstack_network ||= get_fog_promise('Network', openstack_options)

          env[:openstack_compute] = $openstack_compute
          env[:openstack_network] = $openstack_network

          @app.call(env)
        end

        def complete_auth_url(identity_api_version, auth_url)
          if auth_url =~ /\/v([.\d]+)\/auth\/tokens/
            @logger.info("WARNING: Do not use full path in endpoint, the newer version" +
                             " of fog will autodetect the right path")
          end

          #For forward-compatibility with fog ~> 1.0.3

          if identity_api_version =~ /^3[.\d]*$/i
            if auth_url !~ /\/v3[\d.]*(\/)*.*$/
              auth_url =auth_url.chomp('/')
              auth_url << "/v" + identity_api_version
            end
            if auth_url !~ /\/auth\/tokens/
              auth_url =auth_url.chomp('/')
              auth_url << "/auth/tokens"
            end
          elsif identity_api_version =~ /2[.\d]*/i
            if auth_url !~ /\/v2[.\d]?(\/)*.*$/
              auth_url = auth_url.chomp('/')
              if identity_api_version =~ /^[0-9+]$/
                auth_url << "/v%s.0" % identity_api_version
              else
                auth_url << "/v%s" % identity_api_version
              end
            end
            if auth_url !~ /\/tokens/
              auth_url = auth_url.chomp('/')
              auth_url << "/tokens"
            end
          else
            @logger.info("WARNING: Unrecognized identity_api_version, we will use identity_auth_url as-is")
          end

          auth_url
        end

        private

        def get_fog_promise(service_name, openstack_options)
          Kernel.promise {
            @logger.info("Initializing OpenStack #{service_name}...")
            Fog.const_get(service_name).new(openstack_options)
          }
        end
      end
    end
  end
end
