import "postgres"

Exec { path => "/usr/bin:/bin:/usr/sbin" }

package { "curl"               : ensure => installed }
package { "g++"                : ensure => installed }
package { "git-core"           : ensure => installed }
package { "libmysqlclient-dev" : ensure => installed }
package { "libpq-dev"          : ensure => installed }
package { "libsqlite3-dev"     : ensure => installed }
package { "libxml2-dev"        : ensure => installed }
package { "libxslt1-dev"       : ensure => installed }
package { "nginx"              : ensure => installed }
package { "postgresql-8.4"     : ensure => installed, require => Exec["apt-update"] }
package { "rake"               : ensure => installed }
package { "ruby1.9.1"          : ensure => installed }
package { "vim"                : ensure => installed }

postgres::database { "picklespears":
  ensure => present,
  name => 'picklespears',
  require => Package['postgresql-8.4'],
}

postgres::database { "picklespearstest":
  ensure => present,
  name => 'picklespearstest',
  require => Package['postgresql-8.4'],
}

postgres::role { "picklespears":
  password => "md570a9605e0eb7892dd928b47db8e2d0ca",
  ensure => present,
  require => Package['postgresql-8.4'],
}

exec { "apt-update":
        command     => "/usr/bin/apt-get update",
        refreshonly => true;
}

group { "puppet":
  ensure => "present",
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
