#!/usr/bin/env bash
(
    cd $(dirname $0)/../ &&
    vagrant plugin uninstall vagrant-openstack-cloud-provider || true &&
    rm -f vagrant-openstack-cloud-provider-*.gem || true &&
    bundle &&
    gem build vagrant-openstack-cloud-provider.gemspec -q &&
    vagrant plugin install vagrant-openstack-cloud-provider-*.gem
)
