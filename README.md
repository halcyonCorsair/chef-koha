Description
===========

This cookbook installs a copy of the Koha library software (http://koha-community.org/) from git.

Requirements
============

## Cookbooks:

* apache2
* mysql
* perl

## Platforms:

Currently only Ubuntu 12.04 is supported.

Attributes
==========

* `default['koha']['install_mode']` - Koha install mode: "dev", "standard" or "single"
* `default['koha']['install_base']` - Where to put the git checkout
* `default['koha']['user']['name']` - User koha runs as
* `default['koha']['user']['home']` - Home directory for koha user
* `default['koha']['repository']` - Defaults to "git://git.koha-community.org/koha.git"
* `default['koha']['revision']` - Defaults to "3.8.x"
* `default['koha']['database']['type']` - mysql or postgres (only mysql supported by this cookbook)
* `default['koha']['database']['name']` - Name of the koha database
* `default['koha']['database']['host']` - Hostname of the database server
* `default['koha']['database']['port']` - Database port
* `default['koha']['database']['user']` - Database username for koha
* `default['koha']['database']['password']` - Database password for koha
* `default['koha']['database']['admin_user']` - Database admin user
* `default['koha']['database']['admin_password']` - Database admin password
* `default['koha']['webserver']['ip']` - IP address to serve koha on
* `default['koha']['webserver']['host']` - Hostname to serve koha on
* `default['koha']['webserver']['opac_port']` - Port for the OPAC to listen on
* `default['koha']['webserver']['admin_port']` - Port for the admin interface

Usage
=====

    {
      "koha": {
        "install_base": "/home/ubuntu/koha",
        "deploy": {
          "user": "ubuntu",
          "group": "ubuntu"
        },
        "user": {
          "home": "/home/ubuntu"
        }
      },
      "mysql": {
         "server_root_password": "password",
         "server_repl_password": "password",
         "server_debian_password": "password"
      },
      "apache": {
        "listen_ports": [
          "80", "8080"
        ]
      },
      "run_list": [
        "recipe[apache2]",
        "recipe[apache2::mod_rewrite]",
        "recipe[apache2::mod_headers]",
        "recipe[apache2::mod_deflate]",
        "recipe[perl]",
        "recipe[mysql::client]",
        "recipe[mysql::server]",
        "recipe[koha::requirements]",
        "recipe[koha]"
      ]
    }
