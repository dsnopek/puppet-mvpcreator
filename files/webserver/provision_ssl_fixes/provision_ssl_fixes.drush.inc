<?php

/**
 * Implementation of hook_provision_drupal_config().
 */
function provision_ssl_fixes_provision_drupal_config($uri, $data) {
}

/**
 * Implementation of hook_provision_apache_dir_config().
 *
 * Apache config for the platform.
 */
function provision_ssl_fixes_provision_apache_dir_config($data) {
}

/**
 * Implementation of hook_provision_apache_vhost_config().
 */
function provision_ssl_fixes_provision_apache_vhost_config($uri, $data) {
  $config = array();

  $aegir_root = '/var/aegir';
  $ssl_root = "$aegir_root/config/ssl.d";

  $http = $data['server']->service('http', "@$uri");

  if ($http->context->ssl_enabled) {
    // From http://www.startssl.com/?app=21
    $config[] .= '    SSLProtocol all -SSLv2';
    $config[] .= '    SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM';

    $key = $http->context->ssl_key;
    if (file_exists("$ssl_root/$key/sub.class2.server.ca.pem")) {
      $config[] .= "    SSLCertificateChainFile $ssl_root/$key/sub.class2.server.ca.pem";
    }
    if (file_exists("$ssl_root/$key/ca.pem")) {
      $config[] .= "    SSLCACertificateFile $ssl_root/$key/ca.pem";
    }

    $config[] .= '    SetEnvIf User-Agent ".*MSIE.*" nokeepalive ssl-unclean-shutdown';
  }

  return $config;
}

