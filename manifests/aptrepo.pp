
# Based on the walk-through found here:
#
#   http://joseph.ruscio.org/blog/2010/08/19/setting-up-an-apt-repository/

class mvpcreator::aptrepo {
  package {'gnupg':
    ensure => present,
  }

  package {'reprepro':
    ensure => present,
  }

  group {'aptrepo':
    ensure => present,
  }

  user {'aptrepo':
    ensure     => present,
    gid        => 'aptrepo',
    home       => '/var/packages',
    shell      => '/bin/bash',
    managehome => false,
  }

  File {
    owner => 'aptrepo',
    group => 'aptrepo',
    mode  => 2664,
  }

  # Setup directories
  file {'/var/packages':
    ensure => directory,
  }
  file {'/var/packages/debian':
    ensure => directory,
  }
  file {'/var/packages/debian/conf':
    ensure => directory,
  }

  # Setup config files
  file {'/var/packages/debian/conf/distributions':
    ensure  => present,
    source  => "puppet:///modules/mvpcreator/aptrepo/distributions",
  }
  file {'/var/packages/debian/conf/options':
    ensure  => present,
    source  => "puppet:///modules/mvpcreator/aptrepo/options",
  }
  file {'/var/packages/debian/conf/override.squeeze':
    ensure  => present,
    content => '',
    # This will get updated later, we don't want to replace it
    # with empty later!
    replace => 'no',
  }
  file {'/var/packages/debian/conf/override.wheezy':
    ensure  => present,
    content => '',
    # This will get updated later, we don't want to replace it
    # with empty later!
    replace => 'no',
  }

}

class mvpcreator::aptrepo::devtools {
  # Based on the following sources:
  #
  #   http://edseek.com/~jasonb/articles/pbuilder_backports/index.html
  #   https://wiki.ubuntu.com/PbuilderHowto
  #   http://xn.pinkhamster.net/blog/tech/host-a-debian-repository-on-s3.html

  $packages = ['pbuilder', 'debootstrap', 'fakeroot', 'devscripts', 'apt-utils', 's3cmd']
  package {$packages:
    ensure => present,
  }

  # TODO: we need a script for adding a package and syncing the repo to S3

  file {'/etc/pbuilder/pbuilderrc':
    ensure  => present,
    source  => "puppet:///modules/mvpcreator/aptrepo/pbuilderrc",
    require => Package['pbuilder'],
  }
  file {'/etc/pbuilder/hook.d':
    ensure  => directory,
    require => Package['pbuilder'],
  }
  file {'/etc/pbuilder/hook.d/D01apt-ftparchive':
    ensure  => present,
    source  => "puppet:///modules/mvpcreator/aptrepo/pbuilder-hook.d/D01-ftparchive",
  }

  Exec {
    path => [
      '/usr/sbin',
      '/usr/bin',
      '/sbin',
      '/bin',
    ],
  }

  # TODO: not sure I should do this automatically... It takes a while!

  #exec {'pbuilder create --distribution squeeze':
  #  creates => '/var/cache/pbuilder/base.tgz',
  #  require => [
  #    Package['pbuilder'],
  #    File['/etc/pbuilder/pbuilderrc'],
  #    File['/etc/pbuilder/hook.d/D01apt-ftparchive'],
  #  ],
  #}
}

