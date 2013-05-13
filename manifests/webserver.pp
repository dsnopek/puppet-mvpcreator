
class mvpcreator::webserver (
  $aegir_url,
  $aegir_email = 'aegir@example.com',
  $production = false
) {

  # We get our PHP and Apache from dotdeb
  apt::sources_list {"dotdeb":
    content => "deb http://packages.dotdeb.org squeeze all",
    require => Apt::Keys::Key['dotdeb'],
  }
  apt::keys::key {"dotdeb":
    source => "puppet:///modules/mvpcreator/webserver/dotdeb.gpg",
  }

  Exec {
    path => [
      '/usr/sbin',
      '/usr/bin',
      '/sbin',
      '/bin',
    ],
  }

  # TODO: Does keeping this in a seperate class even make sense?
  include mvpcreator::webserver::aegir

  # Setup PHP
  service {'php5-fpm':
    ensure => running,
    require => Package['php5-fpm'],
  }
  package {'php5-fpm':
    ensure => present,
    require => [ Apt::Sources_list['dotdeb'] ],
  }
  package {'php-apc':
    ensure => present,
    require => [ Apt::Sources_list['dotdeb'] ],
  }
  file {'/etc/php5/fpm/php.ini':
    ensure => present,
    source => "puppet:///modules/mvpcreator/webserver/php.ini",
    require => [ Package['php5-fpm'] ],
    notify => Service['php5-fpm'],
  }

  # Setup Apache
  service {'apache2':
    ensure => running,
    require => [ 
      Package['apache2-mpm-worker'],
      Exec['a2enmod actions'],
    ],
  }
  package {'apache2-mpm-worker':
    ensure => present,
    require => [ Apt::Sources_list['dotdeb'] ],
  }
  package {'libapache2-mod-fastcgi':
    ensure => present,
    require => [ Apt::Sources_list['dotdeb'] ],
  }
  exec {'a2enmod actions':
    creates => '/etc/apache2/mods-enabled/actions.load',
    notify => Service['apache2'],
  }
  package {'libapache2-mod-php5':
    ensure => absent,
  }
  # We can't purge the 'libapache2-mod-php5' package because 'aegir' depends on it,
  # but we CAN disable the module in the Apache config
  #exec {'a2dismod php5':
  #  onlyif => 'test -f /etc/apache2/mods-enabled/php5.load',
  #  notify => Service['apache2'],
  #  require => Package['libapache2-mod-php5'],
  #}
  # So we can setup the dependency above...
  #package {'libapache2-mod-php5':
  #  ensure => present,
  #}

  # Configure to run with FastCGI
  file {'/etc/apache2/conf.d/php-fpm':
    ensure => present,
    source => "puppet:///modules/mvpcreator/webserver/apache-php-fpm",
    require => [ Package['php5-fpm'], Package['apache2-mpm-worker'] ],
    notify => Service['apache2'],
  }
  file {'/etc/php5/fpm/pool.d/www.conf':
    ensure => present,
    source => "puppet:///modules/mvpcreator/webserver/php-fpm-www.conf",
    require => [ Package['php5-fpm'] ],
    notify => Service['php5-fpm'],
  }
}

class mvpcreator::webserver::aegir {
  $aegir_hostmaster_url = $mvpcreator::webserver::aegir_url
  $aegir_hostmaster_email = $mvpcreator::webserver::aegir_email
  # TODO: this shouldn't be necessary...
  $aegir_dev_build = true
  $aegir_manual_build = true
  $aegir_version = '6.x-1.9'

  Exec {
    path => '/usr/bin:/bin',
  }

  # Necessary because Exec['hostmaster-install'] depends on Package['git-core'] - bug in the
  # Aegir puppet module, I think...
  package {'git-core':
    ensure => present,
  }

  include aegir::manual_build
  include aegir::queue_runner
}
 
