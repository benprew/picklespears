
# == Class: nginx
#
# Full description of class nginx here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { nginx:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2011 Your name here, unless otherwise noted.
#
class teamvite-nginx {
  package { "nginx"                      : ensure => installed, require => Exec["apt-update"] }

  file { "/etc/nginx/conf.d/teamvite.conf":
    source => "puppet:///modules/teamvite-nginx/etc/nginx/conf.d/teamvite.conf",
    ensure => file,
  }

  file { "/etc/ssl/localcerts":
    ensure => directory,
    mode => 750,
  }
}
