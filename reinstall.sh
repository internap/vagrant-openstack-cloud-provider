#!/usr/bin/env bash


vagrant plugin uninstall vagrant-openstack-cloud-provider || true && \
bundle && \
gem build vagrant-openstack-cloud-provider.gemspec -q && \
vagrant plugin install vagrant-openstack-cloud-provider-1.1.13.gem && \
vagrant up && \
vagrant destroy
