# Definition: dspace::install
#
# Each time this is called, the following happens:
#  - DSpace source is pulled down from GitHub
#  - DSpace Maven build process is run (if it has not yet been run)
#  - DSpace Ant installation process is run (if it has not yet been run)
#
# Tested on:
# - Ubuntu 12.04
#
# Parameters:
# - $owner (REQUIRED)   => OS User who should own DSpace instance
# - $version (REQUIRED) => Version of DSpace to install (e.g. "3.0", "3.1", "4.0", etc)
# - $group              => Group who should own DSpace instance. Defaults to same as $owner
# - $src_dir            => Location where DSpace source should be kept (defaults to the home directory of $owner at ~/dspace-src)
# - $install_dir        => Location where DSpace instance should be installed (defaults to the home directory of $owner at ~/dspace)
# - $service_owner      => Owner of the actual DSpace service (i.e. Tomcat service). Defaults to same as $owner
# - $service_group      => Group of the actual DSpace service (i.e. Tomcat service). Defaults to same as $group
# - $git_repo           => Git repository to pull DSpace source from. Defaults to DSpace/DSpace in GitHub
# - $git_branch         => Git branch to build DSpace from. Defaults to "master".
# - $mvn_params         => Any build params passed to Maven. Defaults to "-Denv=vagrant" which tells Maven to use the vagrant.properties file.
# - $ant_installer_dir  => Full path of directory where the Ant installer is built to (via Maven).
# - $admin_firstname    => First Name of the created default DSpace Administrator account.
# - $admin_lastname     => Last Name of the created default DSpace Administrator account.
# - $admin_email        => Email of the created default DSpace Administrator account.
# - $admin_passwd       => Initial Password of the created default DSpace Administrator account.
# - $admin_language     => Language of the created default DSpace Administrator account.
# - $ensure => Whether to ensure DSpace instance is created ('present', default value) or deleted ('absent')
#
# Sample Usage:
# dspace::install {
#    owner      => "vagrant",
#    version    => "4.0-SNAPSHOT",
#    git_branch => "master",
# }
#

define drum::install ($owner,
                        $version,
                        $group             = $owner,
                        $src_dir           = "/home/${owner}/dspace-src", 
                        $install_dir       = "/home/${owner}/dspace",
                        $service_owner     = "${owner}", 
                        $service_group     = "${owner}",

# pull the following from Hiera

                        $git_repo          = hiera('git_repo'),
                        $git_branch        = hiera('git_branch'),
                        $mvn_params        = hiera('mvn_params'),
                        $ant_installer_dir = hiera('ant_installer_dir'),
                        $admin_firstname   = hiera(admin_firstname),
                        $admin_lastname    = hiera(admin_lastname),
                        $admin_email       = hiera(admin_email),
                        $admin_passwd      = hiera(admin_passwd),
                        $admin_language    = hiera(admin_language),
                        $ensure            = present
                        )

{
	
}
