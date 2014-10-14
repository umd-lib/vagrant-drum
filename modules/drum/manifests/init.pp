# Class: drum
#
# This class does the following:
# - installs pre-requisites for Drum (Java, Maven, Ant, Tomcat)
#
# Tested on:
# - Ubuntu 12.04
#
# Parameters:
# - $java => version of Java (6 or 7)
#
# Sample Usage:
# include drum
#
class drum ($java_version = "7")
{
    # Default to requiring all packages be installed
    Package {
        ensure => installed,
    }

    include apt
    
    apt::ppa { "ppa:webupd8team/java": }

    exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
        before => Apt::Ppa["ppa:webupd8team/java"],
    }

    exec { 'apt-get update 2':
        command => '/usr/bin/apt-get update',
        require => [ Apt::Ppa["ppa:webupd8team/java"], Package["git-core"] ],
    }

    package { ["oracle-java7-installer"]:
        ensure => present,
        require => Exec["apt-get update 2"],
    }

    package { ["curl",
             "git-core",
             "expect",
             "bash"]:
    ensure => present,
    require => Exec["apt-get update"],
    before => Apt::Ppa["ppa:webupd8team/java"],
    }

    exec {
        "accept_license":
        command => "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
        cwd => "/home/vagrant",
        user => "vagrant",
        path    => "/usr/bin/:/bin/",
        require => Package["curl"],
        before => Package["oracle-java7-installer"],
        logoutput => true,
    }

    # Install Maven & Ant
    package { "maven": 
        require => Package["oracle-java7-installer"],
    }
    package { "ant":
        require => Package["oracle-java7-installer"],
    }
}
