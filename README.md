MVPCreator Puppet Module
========================

Used for configuring Debian Squeeze servers for the MVPCreator Drupal hosting enviroment.

mvpcreator::apache_solr
-----------------------

Sets up Apache SOLR for working with the [apachesolr-3.x module](https://drupal.org/project/apachesolr)
and automatically provisioning new cores per the method described in
[this article](http://davehall.com.au/blog/dave/2010/06/26/multi-core-apache-solr-ubuntu-1004-drupal-auto-provisioning).

To provision a new core, make a GET request to this URL:

  http://solr:8983/solr/admin/cores?action=CREATE&name=**core-name**&instanceDir=**core-name**

... where:

 * **core-name** is the name of the core you want to create. I usually use the website's
 canonical domain, ex. www.example.com

 * 'solr' is listed in your /etc/hosts file with the IP of the server actually running SOLR.

