Vagrant + Drum = vagrant-drum
=================================

[Vagrant](http://vagrantup.com) can be used to spin up a temporary Virtual Machine (VM) in a variety of providers ([VirtualBox](http://www.virtualbox.org), [VMWare](http://www.vmware.com/), [Amazon AWS](http://aws.amazon.com/), etc). This is a fork of the [vagrant-dspace](https://github.com/Dspace/vagrant-dspace) repository.

Simply put, 'vagrant-drum' uses Vagrant and [Puppet](http://puppetlabs.com/) to auto-install latest DSpace on the VM provider of your choice (though so far we've mostly tested with VirtualBox).

Some example use cases for 'vagrant-dspace':
* Lets you easily install the latest version of DSpace on a Virtual Machine in order to try it out or test upgrades, etc.
* Lets you easily setup an offline/local copy of DSpace for demos at conferences or similar.
* Lets you quickly setup a DSpace development environment on a Virtual Machine. You'd need to install your IDE of choice, but besides that, everything else is installed for you.
* Vagrant VMs are "throwaway". Can easily destroy the VM and recreate at will for testing purposes or as needs arise (e.g. `vagrant destroy; vagrant up`)

_BIG WARNING: THIS IS STILL A WORK IN PROGRESS. YOUR MILEAGE MAY VARY. NEVER USE THIS IN PRODUCTION._


Table of Contents
-----------------

1. [How it Works](#how-it-works)
2. [Requirements - The prerequisites you need](#requirements)
3. [Getting Started - How to install and run 'vagrant-dspace'](#getting-started)
4. [What will you get? - What does the end result look like?](#what-will-you-get)
5. [Usage Tips - How to perform common activities in this environment](#usage-tips)
6. [How to Tweak Things to your Liking? - Tips on customizing the 'vagrant-dspace' install process](#how-to-tweak-things-to-your-liking)
7. [Vagrant Plugin Recommendations - Other plugins you may wish to consider installing](#vagrant-plugin-recommendations)
8. [What's Next?](#whats-next)
9. [Tools We Use To Make This All Work](#tools-we-use-to-make-this-all-work)
10. [Reporting Bugs / Requesting Enhancements](#reporting-bugs--requesting-enhancements)
11. [License](#license)

How it Works
------------

'vagrant-drum' does all of the following for you:

* Spins up an Ubuntu 12.04 VM using Vagrant
* Installs some of the basic prerequisites for Drum Development (namely: Git, Java, Maven)
* Installs/Configures PostgreSQL
   * We install [puppetlabs/postgresql](http://forge.puppetlabs.com/puppetlabs/postgresql) (via [librarian-puppet](http://librarian-puppet.com/)),
     and then use that Puppet module to setup PostgreSQL
* Installs Tomcat to `~/tomcat/` (under the default 'vagrant' user account)
   * We install [tdonohue/puppet-tomcat](https://github.com/tdonohue/puppet-tomcat/) (via [librarian-puppet](http://librarian-puppet.com/)),
     and then use that Puppet module to setup Tomcat
   * WARNING: We are just pulling down the latest "master" code from tdonohue/puppet-tomcat at this time.
   * Makes Drum available via Tomcat (e.g. http://localhost:8080/xmlui/)
* Sets up SSH Forwarding, so that you can use your local SSH key(s) on the VM (for development with GitHub)
* Syncs your local Git settings (name and email from local .gitconfig) to VM (for development with GitHub)

**If you want to help, please do.** We'd prefer solutions using [Puppet](https://puppetlabs.com/).

Requirements
------------

* [Vagrant](http://vagrantup.com/) version 1.3.2 or higher
* [VirtualBox](https://www.virtualbox.org/)
* A GitHub account with an associated SSH key:  As vagrant-dspace was built initially as a developer tool, at this time one must have a GitHub account (and an associated SSH key) in order for 'vagrant-dspace' to be able to download DSpace source from GitHub. Please note, we are working on removing this requirement in the future.
* You will need to download Drum and follow the instructions to build it to /apps/drum present at [UMD-LIB: Drum](https://github.com/umd-lib/drum).
* You will also need to download and install solr.

Getting Started
--------------------------

1. Install [Vagrant](http://vagrantup.com) (Only tested with the [VirtualBox](https://www.virtualbox.org/) provider so far)
2. Clone a copy of 'vagrant-drum' to your local computer
   * `git clone git@github.com:umd-lib/vagrant-drum`
3. _WINDOWS ONLY_ : Any users of Vagrant from Windows MUST create a GitHub-specific SSH Key (at `~/.ssh/github_rsa`) which is then connected to your GitHub Account. There are two easy ways to do this:
   * Install [GitHub for Windows](http://windows.github.com/) - this will automatically generate a new `~/.ssh/github_rsa` key.
   * OR, manually generate a new `~/.ssh/github_rsa` key and associate it with your GitHub Account. [GitHub has detailed instructions on how to do this.](https://help.github.com/articles/generating-ssh-keys)
   * SIDENOTE: Mac OSX / Linux users do NOT need this, as Vagrant's SSH Key Forwarding works properly from Mac OSX & Linux. There's just a bug in using Vagrant + Windows.
   * For Mac OSX / Linux users: Make sure that the ssh keys are added by running `ssh-add -L` otherwise add the key using `ssh-add ~/.ssh/id_rsa`.
   
4. Perform the following steps:
    * Clone Drum using: `git clone git@github.com:umd-lib/drum`

5. Install the required software and build Drum on your local machine according to the instructions here: [Drum Installation Documentation](https://github.com/umd-lib/drum/blob/drum-develop/dspace/docs/Drum41LocalInstallation.md). Only the steps in the following sections of the above document need to be performed.
    * Oracle Java JDK 7
    * Apache Maven 3.x (Java build tool)
    * Apache Ant 1.8 or later (Java build tool)
    * Initial Configuration
        * Make the following changes to local.properties:
        ```
        solr.server = http://192.168.50.1:8983/solr 
        ```
    * Build the Installation Package.
    * Install DRUM code
    * Setup Solr Environment for Drum and make sure that it is running before you start the vagrant up.
        * `cd solr-env/jetty`
        * `mvn jetty:run`
    * Create directories to be accessed by webapps

    These are the sections that can be ignored:
    
5. Prerequisite Software and Data:
    * **JDK Installation**: 
        * *Since Oracle requires you to accept a licence, you have to manually download the Oracle JDK from their website [here](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)* 
        * Download the Java Development Kit (Default version: 1.7.0_71) .gz file for Linux x64 from Oracle and place it here: `vagrant-drum/content/jdk-7u71-linux-x64.gz`.
    * **Postgres Database Restoration**:
        * The application will not work properly unless the postgres database contains the relevant information.
        * The provisioning scripts restore the `dspace411` database from a dump present at `vagrant-drum/content/dump.tar.0`. Put the database dump there to restore it to the dspace411 database.

6. Make sure the following are running and in place as mentioned above:
    * solr
    * the Oracle JDK for linux x64
    * The database dump (dump.tar.0)
    
    Once that is done, run `vagrant up`.
    
    * Wait for ~15 minutes while Vagrant & Puppet do all the heavy lifting of setting up the development environment and deploying it to tomcat.

7. `cd [vagrant-drum]/`


8. Once complete, visit `http://localhost:8085/xmlui/` or `http://localhost:8085/jspui/` in your local web browser to see if it worked! _More info below on what to expect._
      
The `vagrant up` command will initialize a new VM based on the settings in the `Vagrantfile` in that directory.  

Once complete, you'll have a fresh Ubuntu VM that you can SSH into by simply typing `vagrant ssh`. Since SSH Forwarding is enabled,
that Ubuntu VM should have access to your local SSH keys, which allows you to immediately use Git/GitHub.

What will you get?
------------------

* A running instance of [DRUM](https://github.com/umd-lib/drum), on top of latest PostgreSQL and Tomcat 7 (and using Oracle JDK)
   * You can visit this instance at `http://localhost:8085/xmlui/` or `http://localhost:8085/jspui/` from your local web browser 
   * If you install and configure the [Landrush plugin](https://github.com/phinze/landrush) for Vagrant, you can instead visit http://dspace.vagrant.dev:8085/xmlui/ or http://drum.vagrant.dev:8085/jspui/
   * An initial Administrator account is also auto-created:
       * Login: `drumdemo+admin@gmail.com` , Pwd: 'vagrant'
* All "out of the box" DSpace webapps running out of `/apps/drum`
* Tomcat 7 instance installed at `~/tomcat/`
* Enough to get you started with developing/building/using DSpace (or debug issues with the DSpace build process, if any pop up)
   * Though you may wish to install your IDE of choice.
* A very handy playground for testing multiple-machine configurations of DSpace, and software that might utilize DSpace as a service

It is up to you to [continue the DSpace setup](https://wiki.duraspace.org/display/DSDOC3x/Installation#Installation-InstallationInstructions), as needed. 
 
It is also worth noting that you may choose to tweak the default `Vagrantfile` to better match your own development environment. 
There's even a few quick settings there to get you started.

If you want to destroy the VM at anytime (and start fresh again), just run `vagrant destroy`. 
No worries, you can always recreate a new VM from scratch with another `vagrant up`.

As you develop with 'vagrant-drum', from time to time you may want to run a `vagrant destroy` cycle (followed by a fresh `vagrant up`), just to confirm that the Vagrant setup is still doing exactly what you want it to do. 
This cleans out any old experiments and starts fresh with a new base image. If you're just using vagrant-drum for dspace development, this isn't advice for you. 
But, if you're working on contributing back to vagrant-drum, do try this from time to time, just to sanity-check your Vagrant and Puppet scripts.

Usage Tips
------------

Here's some common activities which you may wish to perform in `vagrant-dspace`:

* **Restarting Tomcat**
   * `~/tomcat/control restart` 
* **Restarting PostgreSQL**
   * `sudo service postgresql restart`
* **Connecting to DSpace PostgreSQL database**
   * `psql -h localhost -U dspace dspace`  (Password is "dspace")
* **Using the fakeSMTP server**
    * the fakeSMTP server from [here](https://nilhcem.github.io/FakeSMTP/) is installed during provisioning. It is set up at 127.0.0.1:2525.You can use the following commands:
    * To start: `sudo service fakesmtp start`
    * To stop: `sudo service fakesmtp stop`


How to Tweak Things to your Liking?
-----------------------------------

### local.yaml

If you look at the config folder, there are a few files you'll be interested in. The first is common.yaml, it's a [Hiera](http://projects.puppetlabs.com/projects/hiera) configuration file. You may copy this file to one named local.yaml. Any changes to local.yaml will override the defaults set in the common.yaml file. The local.yaml file is ignored in .gitignore, so you won't accidentally commit it. Here are the options:

* git_repo - it would be a good idea to point this to your own fork of Drum
* git_branch - if you're constantly working on another brach than master, you can change it here
* mvn_params - add other maven prameters here (this is added to the Vagrant user's profile, so these options are always on whenever you run mvn as the Vagrant user
* mvn_version - defaults to 3.0.5, but feel free to change it to whatever version you wish to test
* ant_installer_dir - until we figure out how to have the installer just run from whatever version of DSpace is in the target folder produced by Maven, we'll need to hard code the DSpace version so we can have Puppet look in the right place to run the Ant installer for DSpace
* admin_firstname - you may want to change this to something more memorable than the demo DSpace user
* admin_lastname - ditto
* admin_email - likewise
* admin_passwd - you probably have a preferred password
* admin_language - and you my have a language preference, you can set it here

### local-bootstrap.sh

In the config folder, you will also find a file called local-bootstrap.sh.example. If you copy that file to local-bootstrap.sh and edit it to your liking (it is well-commented) you'll be able to customize your git clone folder to your liking (turning on the color.ui, always pull using rebase, set an upstream github repository, add the ability to fetch pull requests from upstream), as well as automatically batch-load content (an example using AIPs is included, but you're welcome to script whatever you need here... if you come up with something interesting, please consider sharing it with the community). 

local-bootstrap.sh is a "shell provisioner" for Vagrant, and our vagrantfile is [configured to run it](https://github.com/DSpace/vagrant-dspace/blob/master/Vagrantfile#L171) if it is present in the config folder. If you have a fork of Vagrant-DSpace for your own repository management, you may add another shell provisioner, to maintain your own workgroup's customs and configurations. You may find an example of this in the [Vagrant-MOspace](https://github.com/umlso/vagrant-mospace/blob/master/config/mospace-bootstrap.sh) repository.

### maven_settings.xml

If you've copied the example local-bootstrap.sh file, you may create a config/dotfiles folder, and place a file called maven_settings.xml in it, that file will be copied to /home/vagrant/.m2/settings.xml every time the local-bootstrap.sh provisioner is run. This will allow you to further customize your Maven builds. One handy (though somewhat dangerous) thing to add to your settings.xml file is the following profile:
```
    <profile>
            <id>sign</id>
            <activation>
                    <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                    <gpg.passphrase>add-your-passphrase-here-if-you-dare</gpg.passphrase>
            </properties>
    </profile>
```

NOTE: any file in config/dotfiles is ignored by Git, so you won't accidentally commit it. But, still, putting your GPG passphrase in a plain text file might be viewed by some as foolish. If you elect to not add this profile, and you DO want to sign an artifact created by Maven using GPG, you'll need to enter your GPG passphrase quickly and consistently. Choose your poison.

### vim and .vimrc

Another optional config/dotfiles folder which is copied (if it exists) by the example local-bootstrap.sh shell provisioner is config/dotfiles/vimrc (/home/vagrant/.vimrc) and config/dotfiles/vim (/home/vagrant/.vim). Populating these will allow you to customize Vim to your heart's content. 

Vagrant Plugin Recommendations
-------------------------------

The following Vagrant plugins are not required, but they do make using Vagrant and vagrant-dspace more enjoyable.

* Land Rush: https://github.com/phinze/landrush (no more recent than version 0.12.0) *
* Vagrant-Cachier: https://github.com/fgrehm/vagrant-cachier
* Vagrant-Proxyconf: https://github.com/tmatilai/vagrant-proxyconf/
* Vagrant-VBox-Snapshot: https://github.com/dergachev/vagrant-vbox-snapshot/

NOTE: * if you do install the Land Rush plugin, we recommend you only install version 0.12.0 at this time, newer versions report errors in communicating with our base machine image. You may do this by typing:
```
    vagrant plugin install landrush --plugin-version 0.12.0
```

If you already have a newer version of the landrush plugin installed, you may revert to an earlier version by typing the following commands:

```
    vagrant plugin uninstall landrush
    vagrant plugin install landrush --plugin-version 0.12.0
```
 
Tools we use to make this all work
----------------------------------

* [Vagrant](http://vagrantup.com) (obviously)
* [Puppet](http://puppetlabs.com) - To actually clone, build, configure & install DSpace from GitHub
* [Librarian-Puppet](https://github.com/rodjek/librarian-puppet) - Used to install the external Puppet Modules which setup Tomcat & PostgreSQL

Reporting Bugs / Requesting Enhancements
----------------------------------------

We encourage you to submit Pull Requests with any recommended changes/fixes. As it is, the 'vagrant-dspace' project is really just a labor of love, and we can use help in making it better.

License
--------

This work is derived from [vagrant-dspace](https://github.com/Dspace/vagrant-dspace) which is licensed under the [DSpace BSD 3-Clause License](http://www.dspace.org/license/), which is just a standard [BSD 3-Clause License](http://opensource.org/licenses/BSD-3-Clause).
