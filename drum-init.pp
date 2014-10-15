# Drum initialization script
#
# This Puppet script does the following:
# - installs Java, Maven, Ant
# - starts a tomcat instance running Drum
#
# Tested on:
# - Ubuntu 12.04

# grab Maven version from hiera for later use
$mvn_version = hiera('mvn_version')

# Global default to requiring all packages be installed & apt-update to be run first
Package {
  ensure => latest,                # requires latest version of each package to be installed
  require => Exec["apt-get-update"],
}

# Ensure the rcconf package is installed, we'll use it later to set runlevels of services
package { "rcconf":
  ensure => "installed"
}

# Global default path settings for all 'exec' commands
Exec {
  path => "/usr/bin:/usr/sbin:/bin",
}


# Add the 'partner' repositry to apt
# NOTE: $lsbdistcodename is a "fact" which represents the ubuntu codename (e.g. 'precise')
file { "partner.list":
  path    => "/etc/apt/sources.list.d/partner.list",
  ensure  => file,
  owner   => "root",
  group   => "root",
  content => "deb http://archive.canonical.com/ubuntu ${lsbdistcodename} partner
              deb-src http://archive.canonical.com/ubuntu ${lsbdistcodename} partner",
  notify  => Exec["apt-get-update"],
}

# Run apt-get update before installing anything
exec {"apt-get-update":
  command => "/usr/bin/apt-get update",
  refreshonly => true, # only run if notified
}

# Install DSpace pre-requisites (from DSpace module's init.pp)
include drum

 # Install Maven
class { "maven::maven":
  version => $mvn_version, # version to install
}


# Install Vim for a more rewarding command-line-based editor experience
class {'vim':
   ensure => present,
   set_as_default => true
}

# Install PostgreSQL package

class { 'postgresql::globals':
  encoding => 'UTF8',
}->

# Setup/Configure PostgreSQL server
class { 'postgresql::server':
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '0.0.0.0/0',
  listen_addresses           => '*',
  manage_firewall            => false,
  postgres_password          => 'dspace',
}

->

postgresql::server::role{'root':
  createdb        => true,
  createrole      => true,
  login           => true,
  superuser       => true,
  password_hash   => postgresql_password('root','root'),
}

->

postgresql::server::role{'dspace':
  createdb        => true,
  createrole      => false,
  login           => true,
  superuser       => false,
  password_hash   => postgresql_password('dspace',''),
}

->

# Create a 'dspace411' database
postgresql::server::db { 'dspace411':
  user            => 'dspace',
  password        => '',
  encoding        => 'UNICODE',
}

-> 

exec {
    'restore_db':
        command     => 'pg_restore -U root -d dspace411 /vagrant/dump.tar.0',
        logoutput   => on_failure,
        onlyif      => ['test -f /vagrant/dump.tar.0'],
        #path   => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        #refreshonly => true,
        user        => root,
}


include tomcat

# Create a new Tomcat instance
tomcat::instance { 'dspace':
   owner   => "vagrant",
   appBase => "/apps/drum/webapps", # Tell Tomcat to load webapps from this directory
   ensure  => present,
}

->

file {
    '/home/vagrant/tomcat/control':
        ensure  => file,
        source  => '/vagrant/control',
        owner   => 'vagrant',
        group   => 'vagrant',
        mode    => '0777';
}

-> 

exec {
    'start-tomcat':
        command     => '/home/vagrant/tomcat/control start',
        logoutput   => on_failure,
}