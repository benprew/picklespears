# import "postgres"

Exec { path => "/usr/bin:/bin:/usr/sbin" }

package { "libsqlite3-dev"     : ensure => installed }
package { "g++"                : ensure => installed }
package { "libpq-dev"          : ensure => installed }
package { "ruby1.9.1"          : ensure => installed }
package { "nginx"              : ensure => installed }
package { "git-core"           : ensure => installed }
package { "vim"                : ensure => installed }
package { "libshadow-ruby1.8"  : ensure => installed }
package { "libmysqlclient-dev" : ensure => installed }
package { "libxml2-dev"        : ensure => installed }
package { "libxslt1-dev"       : ensure => installed }
package { "postgresql-8.4"     : ensure => installed, require => Exec["apt-update"] }
package { "rake"               : ensure => installed }

# postgres::database { "picklespears":
#   ensure => present,
#   name => 'picklespears',
#   require => Package['postgresql-8.4'],
# }

# postgres::role { "picklespears":
#   password => "*6F6FAA28F5A830A76C08AA0EDB4E4DF5B0A36C35",
#   ensure => present,
# }

exec { "apt-update":
        command     => "/usr/bin/apt-get update",
        refreshonly => true;
}

exec { "/opt/ruby/bin/gem install bundler": }

file { "/etc/init.d":
  ensure => directory,
  mode => 755,
}

file { "/var/run":
  ensure => directory,
  mode   => 770,
  group  => 'users',
}

file { "/var/log":
  ensure => directory,
  mode   => 755,
}

user { "picklespears":
  home     => '/home/picklespears',
  password => '$6$y8svKzg8$xUgt6TKLMxzc4o9nstWRxQDMrsnNC48Yq/BzQqLEVeLlkBBc5MAtvJiKsAIV0SncRJsGSrFAJu39Nn5vpLPk3/',
  shell    => '/bin/bash',
  groups   => 'users',
  require  => Package['libshadow-ruby1.8'],
  ensure   => present,
}

file { "/home/picklespears":
  ensure  => directory,
  owner   => 'picklespears',
  group   => 'users',
  require => User["picklespears"],
}

file { "/var/www/picklespears":
  ensure  => directory,
  owner   => 'picklespears',
  group   => 'users',
  require => User["picklespears"],
}
