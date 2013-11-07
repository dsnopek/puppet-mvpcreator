
class mvpcreator::ci {
  File {
    owner  => 'root',
    group  => 'root',
  }

  # Fix for error in jenkins v1.538 debian package:
  #   https://issues.jenkins-ci.org/browse/JENKINS-20407
  file {'/var/run/jenkins':
  	ensure => directory,
  }

  file {'/etc/apt/sources.list.d/jenkins.list':
    ensure => present,
    source => "puppet:///modules/mvpcreator/ci/apt-jenkins.list",
    notify => Exec['update_apt'],
  }

  package {'jenkins':
    ensure => installed,
    require => [
      File['/etc/apt/sources.list.d/jenkins.list'],
      File['/var/run/jenkins'],
      Exec['update_apt'],
    ],
  }

  service {'jenkins':
    ensure => running,
    enable => true,
    require => Package['jenkins'],
  }
}

