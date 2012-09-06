#
# Cookbook Name:: koha
# Attributes:: koha
#
# Copyright 2012, Elliot Pahl
#

default['koha']['install_mode']               = "dev"
default['koha']['install_base']               = "/home/vagrant/koha"

default['koha']['user']['name']               = "koha"
default['koha']['user']['group']              = "koha"
default['koha']['user']['uid']                = "3000"
default['koha']['user']['gid']                = "3000"
default['koha']['user']['home']               = "/home/vagrant/koha"
default['koha']['user']['shell']              = "/bin/bash"

default['koha']['deploy']['user']             = "vagrant"
default['koha']['deploy']['group']            = "vagrant"

default['koha']['release_type']               = "scm"
default['koha']['repository']                 = "git://git.koha-community.org/koha.git"
default['koha']['revision']                   = "3.8.x"

default['koha']['database']['type']           = "mysql"
default['koha']['database']['name']           = "koha"
default['koha']['database']['host']           = "localhost"
default['koha']['database']['port']           = "3306"
default['koha']['database']['user']           = "kohaadmin"
default['koha']['database']['password']       = "katikoan"
default['koha']['database']['admin_user']     = "root"
default['koha']['database']['admin_password'] = node['mysql']['server_root_password']

default['koha']['webserver']['ip']            = ipaddress
default['koha']['webserver']['host']          = "localhost"
default['koha']['webserver']['opac_port']     = "80"
default['koha']['webserver']['admin_port']    = "8080"

