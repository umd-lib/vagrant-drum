# -*- mode: ruby -*-
# vi: set ft=ruby :

####################################
# Vagrantfile for DSpace Development
# 
# WARNING: THIS IS A WORK IN PROGRESS. IT DOES NOT YET FULLY INSTALL DSPACE VIA VAGRANT!
#  
# DO NOT USE IN PRODUCTION. THIS IS FOR DEVELOPMENT/TESTING PURPOSES ONLY.
#
# Currently, this config only sets up the following via Vagrant
#   * Setup SSH Key Forwarding (from local machine to Vagrant VM)
#   * Setup basic Git settings (email & username) on VM
#   * Install Java, Maven, Ant on VM
#   * Checkout DSpace source code from GitHub to VM
#
# ONLY TESTED with VirtualBox provider. Your mileage may vary with other providers
####################################

#======================================================
# QUICK SETTINGS
# Feel free to tweak for your development environment.
#======================================================
# General Settings
#------------------
# Version of Java to install on VM (valid values: 7 or 6)
java = "7"

# Virtual Box Quick Settings
# (Additional options are in the :virtualbox provider settings below.)
#--------------------------
# Name of the VM created in VirtualBox (Also the name of the subfolder in ~/VirtualBox VMs/ where this VM is normally kept)
vb_name = "drum-dev"

# How much memory to provide to VirtualBox (in MB)
# Provide 2GB of memory by default
vb_memory = 2048

####################################  

def ensure_sub_project(name)
  if !File.exists?(File.expand_path("/content/#{name}", __FILE__))
    # you could raise or do other ruby magic, or shell out (for a bash script)
    system('echo -n "This is not present"', name)
  else
    system('echo -n "This is not present"', name)
   end
end

ensure_sub_project('dump.tar.2')

# Actual Vagrant configs
Vagrant.configure("2") do |config|
    # All Vagrant configuration is done here. The most common configuration
    # options are documented and commented below. For a complete reference,
    # please see the online documentation at vagrantup.com.

    # Every Vagrant virtual environment requires a box to build off of.
    config.vm.box = "dspace-precise64"

    # BEGIN Vagrant-Cachier configuration ####################################
    # check for the presence of the Vagrant-Cachier plugin before attempting
    # these configurations
    if Vagrant.has_plugin?("vagrant-cachier")
       # Use a vagrant-cachier cache if one is detected
       config.cache.auto_detect = true

       # set vagrant-cachier scope to :box, so other projects that share the
       # dspace-precise64 box will be able to used the same cached files
       config.cache.scope = :box

       # and lets specifically use the apt cache (note, this is a Debian-ism)
       config.cache.enable :apt

       # use the generic cache bucket for Maven
       config.cache.enable :generic, {
             "maven" => { cache_dir: "/home/vagrant/.m2/repository" },
       }
    end
    # END Vagrant-Cachier configuration #######################################

    # The url from where the 'config.vm.box' box will be fetched if it
    # doesn't already exist on the user's system.
    config.vm.box_url = "http://github.com/DSpace/vagrantbox-ubuntu/releases/download/v1.1/precise64.box"

    # define this box so Vagrant doesn't call it "default"
    config.vm.define "drumvm"

    # Hostname for virtual machine
    config.vm.hostname = "drum.vagrant.dev"

    # configure a private network and set this guest's IP to 192.168.50.2
    config.vm.network "private_network", ip: "192.168.50.2"

    # BEGIN Landrush configuration ###########################################


    if Vagrant.has_plugin?('landrush') 
       config.landrush.enable
    end

    # END Landrush configuration ###########################################

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 8080 on the VM.
    config.vm.network :forwarded_port, guest: 8080, host: 8085,
      auto_correct: true

    # If a port collision occurs (i.e. port 8080 on local machine is in use),
    # then tell Vagrant to use the next available port between 8081 and 8100
    #config.vm.usable_port_range = 8081..8100

    # Turn on SSH forwarding (so that 'vagrant ssh' has access to your local SSH keys, and you can use your local SSH keys to access GitHub, etc.)
    config.ssh.forward_agent = true

    # configure the synced folders between the hosts and the guests
    config.vm.synced_folder "/apps/drum", "/apps/drum"

    # THIS NEXT PART IS TOTAL HACK (only necessary for running Vagrant on Windows)
    # Windows currently doesn't support SSH Forwarding when running Vagrant's "Provisioning scripts" 
    # (e.g. all the "config.vm.provision" commands below). Although running "vagrant ssh" (from Windows commandline) 
    # will work for SSH Forwarding once the VM has started up, "config.vm.provision" commands in this Vagrantfile DO NOT.
    # Supposedly there's a bug in 'net-ssh' gem (used by Vagrant) which causes SSH forwarding to fail on Windows only
    # See: https://github.com/mitchellh/vagrant/issues/1735
    #      https://github.com/mitchellh/vagrant/issues/1404
    # See also underlying 'net-ssh' bug: https://github.com/net-ssh/net-ssh/issues/55
    #
    # Therefore, we have to "hack it" and manually sync our SSH keys to the Vagrant VM & copy them over to the 'root' user account
    # (as 'root' is the account that runs all Vagrant "config.vm.provision" scripts below). This all means 'root' should be able 
    # to connect to GitHub as YOU! Once this Windows bug is fixed, we should be able to just remove these lines and everything 
    # should work via the "config.ssh.forward_agent=true" setting.
    # ONLY do this hack/workaround if the local OS is Windows.
    if Vagrant::Util::Platform.windows?
        # MORE SECURE HACK. You MUST have a ~/.ssh/github_rsa (GitHub specific) SSH key to copy to VM
        # (ensures we are not just copying all your local SSH keys to a VM)
        if File.exists?(File.join(Dir.home, ".ssh", "github_rsa"))
            # Read local machine's GitHub SSH Key (~/.ssh/github_rsa)
            github_ssh_key = File.read(File.join(Dir.home, ".ssh", "github_rsa"))
            # Copy it to VM as the /root/.ssh/id_rsa key
            config.vm.provision :shell, :inline => "echo 'Windows-specific: Copying local GitHub SSH Key to VM for provisioning...' && mkdir -p /root/.ssh && echo '#{github_ssh_key}' > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa"
        else
            # Else, throw a Vagrant Error. Cannot successfully startup on Windows without a GitHub SSH Key!
            raise Vagrant::Errors::VagrantError, "\n\nERROR: GitHub SSH Key not found at ~/.ssh/github_rsa (required for 'vagrant-dspace' on Windows).\nYou can generate this key manually OR by installing GitHub for Windows (http://windows.github.com/)\n\n"
        end   
    end

    ####
    # Provisioning Scripts
    #    These scripts run in the order in which they appear, and setup the virtual machine (VM) for us.
    ####

    # Create a '/etc/sudoers.d/root_ssh_agent' file which ensures sudo keeps any SSH_AUTH_SOCK settings
    # This allows sudo commands (like "sudo ssh git@github.com") to have access to local SSH keys (via SSH Forwarding)
    # See: https://github.com/mitchellh/vagrant/issues/1303
    config.vm.provision :shell do |shell|
        shell.inline = "touch $1 && chmod 0440 $1 && echo $2 > $1"
        shell.args = %q{/etc/sudoers.d/root_ssh_agent "Defaults    env_keep += \"SSH_AUTH_SOCK\""}
    end

    # Check our system locale -- make sure it is set to UTF-8
    config.vm.provision :shell, :inline => "locale | grep 'LANG=en_US.UTF-8' > /dev/null || sudo update-locale --reset LANG=en_US.UTF-8"

    # Turn off annoying console bells/beeps in Ubuntu (only if not already turned off in /etc/inputrc)
    config.vm.provision :shell, :inline => "grep '^set bell-style none' /etc/inputrc || echo 'set bell-style none' >> /etc/inputrc"

    # Shell script to set apt sources.list to something appropriate (close to you, and actually up) via apt-spy2
    config.vm.provision :shell, :inline => "echo '   > > > running apt-spy-2-bootstrap.sh, do not worry if it shows an error, it will be OK, there is a fallback.'"
    config.vm.provision :shell, :path => "apt-spy-2-bootstrap.sh"

    # Shell script to initialize latest Puppet on VM & also install librarian-puppet (which manages our third party puppet modules)
    # This has to be done before the puppet provisioning so that the modules are available when puppet tries to parse its manifests.
    config.vm.provision :shell, :path => "puppet-bootstrap-ubuntu.sh"

    config.vm.provision :shell, :inline => "sudo initctl emit vagrant-ready", run: "always"

    # Call our Puppet initialization script
    config.vm.provision :shell, :inline => "echo '   > > > beginning puppet provisioning, this will appear to hang...'"
    config.vm.provision :shell, :inline => "echo '   > > > PATIENCE! output is only shown after each step completes...'"

    # display the local.yaml file, if it exists, to give us a chance to back out
    # before waiting for this vagrant up to complete

    if File.exists?("config/local.yaml")
        config.vm.provision :shell, :inline => "echo '   > > > using the following local.yaml data, if this is not correct, control-c now...'"
        config.vm.provision :shell, :inline => "echo '---BEGIN local.yaml ---' && cat /vagrant/config/local.yaml && echo '--- END local.yaml -----'"
    end

    config.vm.provision :puppet do |puppet|
        # Set some custom "facts" for Puppet manifest(s)/modules to use.
        puppet.facter = {
            "vagrant"       => "1",
            "fqdn"          => "vagrant-dspace",
            "java_version"  => "#{java}",        # version of Java (used by 'dspace-init.pp')
        }
        puppet.manifests_path = "."
        puppet.manifest_file = "drum-init.pp"
        puppet.options = "--verbose"
        puppet.hiera_config_path = "hiera.yaml"
    end

    # Check if ~/.gitconfig exists locally
    # If so, copy basic Git Config settings to Vagrant VM
    if File.exists?(File.join(Dir.home, ".gitconfig"))
        git_name = `git config user.name`   # find locally set git name
        git_email = `git config user.email` # find locally set git email
        # set git name for 'vagrant' user on VM
        config.vm.provision :shell, :inline => "echo 'Saving local git username to VM...' && sudo -i -u vagrant git config --global user.name '#{git_name.chomp}'"
        # set git email for 'vagrant' user on VM
        config.vm.provision :shell, :inline => "echo 'Saving local git email to VM...' && sudo -i -u vagrant git config --global user.email '#{git_email.chomp}'"
    end


    if File.exists?("config/local-bootstrap.sh")
        config.vm.provision :shell, :inline => "echo '   > > > running config/local_bootstrap.sh'"
        config.vm.provision :shell, :path => "config/local-bootstrap.sh"
    end

    #############################################
    # Customized provider settings for VirtualBox
    # Many of these settings use VirtualBox's
    # 'VBoxManage' tool: http://www.virtualbox.org/manual/ch08.html
    #############################################
    config.vm.provider :virtualbox do |vb|
        # Name of the VM created in VirtualBox (Also the name of the subfolder in ~/VirtualBox VMs/ where this VM is kept)
        vb.name = vb_name

        # Use VBoxManage to provide Virtual Machine with extra memory (default is only 300MB)
        vb.customize ["modifyvm", :id, "--memory", vb_memory]

        # Use VBoxManage to have the Virtual Machine use the Host's DNS resolver
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

        # Use VBoxManage to ensure Virtual Machine only has access to 50% of host CPU
        #vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]

        # This allows symlinks to be created within the /vagrant root directory,
        # which is something librarian-puppet needs to be able to do. This might
        # be enabled by default depending on what version of VirtualBox is used.
        # Borrowed from https://github.com/purple52/librarian-puppet-vagrant/
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    end
end
