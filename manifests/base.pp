import "postgres"

Exec { path => "/usr/bin:/bin:/usr/sbin" }

exec { "apt-update":
  command     => "/usr/bin/apt-get update",
  refreshonly => true,
  require     => Exec['ruby-1.9.3-repository', 'postgres-9-repository'],
}

package { "curl"                       : ensure => installed, require => Exec["apt-update"] }
package { "g++"                        : ensure => installed, require => Exec["apt-update"] }
package { "git-core"                   : ensure => installed, require => Exec["apt-update"] }
package { "libmysqlclient-dev"         : ensure => installed, require => Exec["apt-update"] }
package { "libpq-dev"                  : ensure => installed, require => Exec["apt-update"] }
package { "libsqlite3-dev"             : ensure => installed, require => Exec["apt-update"] }
package { "libxml2-dev"                : ensure => installed, require => Exec["apt-update"] }
package { "libxslt1-dev"               : ensure => installed, require => Exec["apt-update"] }
package { "nginx"                      : ensure => installed, require => Exec["apt-update"] }
package { "postgresql-9.2"             : ensure => installed, require => Exec["apt-update"] }
package { "rake"                       : ensure => installed, require => Exec["apt-update"] }
package { "ruby1.9.3"                  : ensure => installed, require => Exec["apt-update"] }
package { "vim"                        : ensure => installed, require => Exec["apt-update"] }
package { "python-software-properties" : ensure => installed }
package { "make"                       : ensure => installed, require => Exec["apt-update"] }

# security packages
package { "ufw"                        : ensure => installed, require => Exec["apt-update"] }
package { "fail2ban"                   : ensure => installed, require => Exec["apt-update"] }
package { "logcheck"                   : ensure => installed, require => Exec["apt-update"] }
package { "psad"                       : ensure => installed, require => Exec["apt-update"] }

postgres::database { "picklespears":
  ensure => present,
  name => 'picklespears',
  require => Package['postgresql-9.2'],
}

exec { "picklespears-privs":
  command => "/usr/bin/psql -c \"grant all on database picklespears to picklespears\"",
  user => 'postgres',
  require => Package['postgresql-9.2'],
}

exec { "picklespearstest-privs":
  command => "/usr/bin/psql -c \"grant all on database picklespearstest to picklespears\"",
  user => 'postgres',
  require => Package['postgresql-9.2'],
}

postgres::database { "picklespearstest":
  ensure => present,
  name => 'picklespearstest',
  require => Package['postgresql-9.2'],
}

postgres::role { "picklespears":
  password => "md570a9605e0eb7892dd928b47db8e2d0ca",
  ensure => present,
  require => Package['postgresql-9.2'],
}

exec { "ruby-alternative":
  command => "update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
    --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby.1.9.1.1.gz \
    --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
    --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
    --slave   /usr/bin/testrb testrb /usr/bin/testrb1.9.1 \
    --slave   /usr/bin/rake rake /usr/bin/rake1.9.1 \
    --slave   /usr/bin/erb erb /usr/bin/erb1.9.1 \
    --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1",
  require => Package['ruby1.9.3'],
}

exec { "ruby-1.9.3-repository":
  command => "/usr/bin/add-apt-repository ppa:brightbox/ruby-ng",
  require => Package['python-software-properties'],
}

exec { "postgres-9-repository":
  command => "/usr/bin/add-apt-repository ppa:pitti/postgresql",
  require => Package['python-software-properties'],
}

group { "puppet":
  ensure => "present",
}

exec { "bundler":
  command => "/usr/bin/gem install bundler",
  require => Package['ruby1.9.3'],
}

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
