
#
# Based on this article:
#
#   http://reluctanthacker.rollett.org/using-squid-caching-server-drush-module-downloads
#

class mvpcreator::drush_dl_cache {
  package {'squid3':
    ensure => installed,
  }
  service {'squid3':
    ensure => running,
  }

  file {'/etc/squid3/squid.conf':
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///modules/mvpcreator/drush_dl_cache/squid.conf",
    require => Package['squid3'],
    notify  => Service['squid3'],
  }

#  file {'/var/aegir/.wgetrc':
#   owner => 'aegir',
#   group => 'aegir',
#    source  => "puppet:///modules/mvpcreator/drush_dl_cache/aegir-wgetrc",
#   require => Service['squid3'],
#  }

  # This is cheating! We can't have this Puppet manifest take over /etc/environment...
  file {'/etc/environment':
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///modules/mvpcreator/drush_dl_cache/environment",
    require => Service['squid3'],
  }
}

