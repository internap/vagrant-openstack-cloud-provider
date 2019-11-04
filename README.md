# Vagrant OpenStack Cloud Provider
[![Build Status](https://travis-ci.org/mat128/vagrant-openstack-cloud-provider.png?branch=master)](https://travis-ci.org/mat128/vagrant-openstack-cloud-provider)

This is a [Vagrant](http://www.vagrantup.com) 1.2+ plugin that adds an
[OpenStack Cloud](http://www.openstack.org) provider to Vagrant,
allowing Vagrant to control and provision machines within an OpenStack
cloud.

This plugin started as a fork of the Vagrant Rackspace provider.

**Note:** This plugin requires Vagrant 1.2+. The last version of this plugin supporting Vagrant 1.1 is 0.3.0.

## Features

* Boot OpenStack Cloud instances.
* SSH into the instances.
* Provision the instances with any built-in Vagrant provisioner.
* Minimal synced folder support via `rsync`.
* Create instances with a specific list of networks
* Support for both keystone v2 and v3

## Usage

Using keystone v3 :

```bash
$ vagrant plugin install vagrant-openstack-cloud-provider
$ cat <<EOF > Vagrantfile
require 'vagrant-openstack-cloud-provider'

Vagrant.configure("2") do |config|

  # This is a publicly available dummy box.
  config.vm.box = "sharpie/dummy"

  config.vm.provider :openstack do |os|
    os.username = "${OS_USERNAME}"
    os.api_key  = "${OS_PASSWORD}"
    os.flavor   = /m1.tiny/
    os.image    = /Ubuntu/
    os.endpoint = "${OS_AUTH_URL}" # such as http://openstack.invalid/ without /v3/auth/tokens
    os.keypair_name = "" # Your keypair name
    os.ssh_username = "" # Your image SSH username
    os.public_network_name = "public" # Your Neutron network name
    os.networks = %w() # Additional neutron networks
    os.region = "${OS_REGION_NAME}"
    os.project_name = "${OS_PROJECT_NAME}"
    os.project_domain_id = "${OS_PROJECT_DOMAIN_ID}"
    os.user_domain_name = "${OS_USER_DOMAIN_NAME}"
    os.identity_api_version = 'v3'
  end
end
EOF
$ vagrant up --provider=openstack
...
```

### Using keystone v2 (deprecated)

You can use a Vagrantfile such as :

```ruby
require 'vagrant-openstack-cloud-provider'

Vagrant.configure("2") do |config|

  # This is a publicly available dummy box.
  config.vm.box = "sharpie/dummy"

  config.vm.provider :openstack do |os|
    os.username = "${OS_USERNAME}"
    os.api_key  = "${OS_PASSWORD}"
    os.flavor   = /m1.tiny/
    os.image    = /Ubuntu/
    os.endpoint = "${OS_AUTH_URL}/tokens"
    os.keypair_name = "" # Your keypair name
    os.ssh_username = "" # Your image SSH username
    os.public_network_name = "public" # Your Neutron network name
    os.networks = %w() # Additional neutron networks
    os.tenant = "${OS_TENANT_NAME}"
    os.region = "${OS_REGION_NAME}"
  end
end
```

## Configuration

This provider exposes quite a few provider-specific configuration options:

* `api_key` - The API key for accessing OpenStack.
* `flavor` - The server flavor to boot. This can be a string matching
  the exact ID or name of the server, or this can be a regular expression
  to partially match some server flavor.
* `image` - The server image to boot. This can be a string matching the
  exact ID or name of the image, or this can be a regular expression to
  partially match some image.
* `availability_zone` - The availability zone to use with nova, 
this allows to choose which zone your instance will exist on.
* `endpoint` - The keystone authentication URL of your OpenStack installation.
* `server_name` - The name of the server within the OpenStack Cloud. This
  defaults to the name of the Vagrant machine (via `config.vm.define`), but
  can be overridden with this.
* `username` - The username with which to access OpenStack.
* `keypair_name` - The name of the keypair to access the machine.
* `ssh_username` - The username to access the machine.
* `public_network_name` - The name of the public network within your Openstack cluster
* `networks` - A list -- use %w(net1 net2) -- of networks to configure
  on your instance.
* `tenant` - *(Deprecated)* The name of the tenant on which the virtual machine should spawn.

Keystone v3 specific configuration , Having one of those settings incorrect
will result in an `401: Unauthorized` in keystone.

* `project_name` - The name of the project on which the virtual machine should spawn , used to be `tenant`
* `project_id` - The id of the tenant on which the virtual machine should spawn
* `domain_name` -  which domain to use to authenticate
* `domain_id` - the id of the domain
* `project_domain_name` - In which domain your project exists
* `project_domain_id` - The id of the domain your project exists
* `user_domain_name` -  In which domain your user exists in
* `user_domain_id` - the id of the domain your user exists in
* `identity_api_version` - Which version of keystone, specifying this to `3` will
autocomplete your url with /v3/auth/tokens to be forward compatible. Currently known version are `2.0`, `3`

These can be set like typical provider-specific configuration:

```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :openstack do |os|
    os.username = "mitchellh"
    os.api_key  = "foobarbaz"
  end
end
```

## Networks

Networking features in the form of `config.vm.network` are not
supported with `vagrant-openstack`, currently. If any of these are
specified, Vagrant will emit a warning, but will otherwise boot
the OpenStack server.

## Synced Folders

There is minimal support for synced folders. Upon `vagrant up`,
`vagrant reload`, and `vagrant provision`, the OpenStack provider will use
`rsync` (if available) to uni-directionally sync the folder to
the remote machine over SSH.

This is good enough for all built-in Vagrant provisioners (shell,
chef, and puppet) to work!

## Development

To work on the `vagrant-openstack-cloud-provider` plugin, clone this
repository out, and use [Bundler](http://gembundler.com) to get the
dependencies:

```
$ bundle
```

Once you have the dependencies, verify the unit tests pass with `rake`:

```
$ bundle exec rake
```

If those pass, you're ready to start developing the plugin. You can test
the plugin without installing it into your Vagrant environment by just
creating a `Vagrantfile` in the top level of this directory (it is gitignored)
that uses it, and uses bundler to execute Vagrant:

```
$ bundle exec vagrant up --provider=openstack
```
