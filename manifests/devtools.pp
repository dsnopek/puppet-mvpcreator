
class mvpcreator::devtools {
  package {'vim-nox':
    ensure => present,
  }

  package {'vim-scripts':
    ensure  => present,
    require => Package['vim-nox'],
  }

  package {'vim-puppet':
    ensure  => present,
    require => Package['vim-nox'],
  }

  package {'ctags':
    ensure => present,
  }

  package {'screen':
    ensure => present,
  }

  package {'markdown':
    ensure => present,
  }

  # Set as default
  exec {'update-alternatives --set editor /usr/bin/vim.nox':
    path    => '/usr/bin:/usr/sbin',
    unless  => 'test /etc/alternatives/editor -ef /usr/bin/${editor_name}',
    require => Package['vim-nox'],
  }

  # Install the puppet plugin
  exec {'vim-addons install puppet':
    unless  => 'vim-addons --query status puppet | grep -v installed',
    require => Package['vim-puppet'],
  }

  # Install the vim drupal plugin
  # TODO: we should install this system wide, or not at all...
  #exec {"drush dl --destination=${bibliobird::aegir_root}/.drush vimrc --yes":
  #  cwd     => "${bibliobird::aegir_root}",
  #  creates => "${bibliobird::aegir_root}/.drush/vimrc",
  #  before  => Exec['drush vimrc-install'],
  #}
  ## TODO: for some reason our unless check doesn't work...
  #exec {"drush vimrc-install": 
  #  cwd     => "${bibliobird::aegir_root}",
  #  unless  => "cat ${bibliobird::aegir_root}/.vimrc | grep '^call pathogen#infect(.${bibliobird::aegir_root}/.drush/vimrc/bundle.)$'",
  #}
}

