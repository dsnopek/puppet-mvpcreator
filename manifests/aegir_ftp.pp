
# Based on the HOWTO located here:
#
#   http://cafuego.net/2011/11/08/integrating-aegir-linux-and-ftp

class mvpcreator::aegir_ftp (
  $nss_mysql_password,
  $aegir_db_name
) {

  # TODO: we should generate $nss_mysql_password and store it
  # TODO: we get $aegir_db_name automatically via `drush @hostmaster st` (or similar)

  Class['mvpcreator::webserver'] -> Class['mvpcreator::aegir_ftp']

  package {'pure-ftpd':
    ensure  => present,
  }
  service {'pure-ftpd':
    ensure => running,
    require => Package['libnss-mysql-bg'],
  }

  package {'libnss-mysql-bg':
  	ensure => present,
  }
  database_user {'nss@localhost':
    password_hash => mysql_password($nss_mysql_password),
  }
  database_grant {"nss@localhost/${aegir_db_name}":
    privileges => ['Select_priv'],
  }

  File {
    owner   => 'root',
    group   => 'root',
  }

  file {'/etc/libnss-mysql.cfg':
    ensure  => present,
    content => template('mvpcreator/aegir_ftp/libnss-mysql.cfg'),
    require => [
	  Package['libnss-mysql-bg'],
      Database_user['nss@localhost'],
      Database_grant["nss@localhost/${aegir_db_name}"],
    ],
  }
  file {'/etc/nsswitch.conf':
    ensure  => present,
    source  => "puppet:///modules/mvpcreator/aegir_ftp/nsswitch.conf",
    require => [
	  File['/etc/libnss-mysql.cfg'],
    ],
  }
}
 
