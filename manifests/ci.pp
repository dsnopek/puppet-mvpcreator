
class mvpcreator::ci::jenkins {
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

define mvpcreator::ci::jenkins_plugin($plugin_name = $title, $version = 'UNSET') {
  $plugin_name_real  = "${plugin_name}.hpi"
  $plugin_dir        = '/var/lib/jenkins/plugins'
  $plugin_parent_dir = '/var/lib/jenkins'

  if $version != 'UNSET' {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  }
  else {
    $base_url = 'http://updates.jenkins-ci.org/latest/'
  }

  if !defined(File[$plugin_dir]) {
    file { [$plugin_parent_dir, $plugin_dir]:
      ensure  => directory,
      owner   => 'jenkins',
      group   => 'nogroup',
      require => Package['jenkins'],
    }
  }

  exec { "jenkins-plugin-download-${name}":
    command => "wget --no-check-certificate ${base_url}${plugin_name_real}",
    cwd     => $plugin_dir,
    user    => 'jenkins',
    unless  => "test -f ${plugin_dir}/${plugin_name_real}",
    notify  => Service['jenkins'],
    require => [Package['jenkins'], File[$plugin_dir]],
  }
}

class mvpcreator::ci {
  include mvpcreator::ci::jenkins

  mvpcreator::ci::jenkins_plugin {[
	# Static analysis stuff
  	'analysis-core', 'analysis-collector', 'checkstyle', 'dry', 'plot', 'pmd',
	# Phing
	'phing',
	# Git stuff
	'token-macro', 'multiple-scms', 'ssh-credentials', 'parameterized-trigger', 'scm-api', 'promoted-builds', 'git-client', 'git',
  ]: }
}

