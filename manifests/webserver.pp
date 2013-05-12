
class mvpcreator::webserver {
  # TODO: either upgrade to wheezy or add the dotdeb.org to the apt sources
  #package {'php5-fpm':
  #  ensure => present,
  #}

  # TODO: Setup apache2-mpm-worker (needs PHP to be in FastCGI)
  # TODO: Make sure that libapache2-mod-php5 is purged

  package {'php-apc':
    ensure => present,
  }
}

