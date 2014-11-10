# Class: drum
#
# This class does the following:
# - installs pre-requisites for Drum (Maven, Ant, Tomcat)
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

    package { ["curl",
             "git-core",
             "expect",
             "bash"]:
        ensure => present,
        require => Exec["apt-get update"],
    }
    
    # Install Maven & Ant
    package { "maven": 
        require => Exec["apt-get update"],  
    }
    package { "ant":
        require => Exec["apt-get update"],
    }
}
