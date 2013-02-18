# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "lucid64"
  config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
  config.vm.customize ["modifyvm", :id, "--memory", 2048, "--cpus", 2]
  config.vm.host_name = "controller.cf.int"
  config.vm.network :hostonly, "10.10.10.250"
  config.vm.provision :shell do |shell|
    shell.path = "provision.sh"
    # the following will allow a custom branch of amara-puppet ; whatever the value of the
    # environment variable PUPPET_BRANCH is, the vagrant.sh script will attempt to checkout
    # that branch ; i.e. PUPPET_BRANCH=dev vagrant provision
    if (ENV['VCAP_DOMAIN'])
      shell.args = "%{vcap_domain}" % { :vcap_domain => ENV['VCAP_DOMAIN']}
    end
  end
end
