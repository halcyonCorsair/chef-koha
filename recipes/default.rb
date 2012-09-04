#
# Cookbook Name:: koha
# Recipe:: default
#
# Copyright 2012, Elliot Pahl
#
# All rights reserved - Do Not Redistribute
#

template "utf8.cnf" do
  path "#{node['mysql']['confd_dir']}/utf8.cnf"
  source "mysql.utf8.cnf.erb"
  owner "root"
  mode 0644
  notifies :restart, "service[mysql]"
end

mysql_connection_info = {
  :host => "localhost",
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

mysql_database "koha" do
  connection mysql_connection_info
  provider Chef::Provider::Database::Mysql
  action :create
end

mysql_database_user "kohaadmin" do
  connection mysql_connection_info
  provider Chef::Provider::Database::MysqlUser
  password "katikoan"
  action :create
  database_name "koha"
  action :grant
end

mysql_database_user "" do
  connection mysql_connection_info
  action :drop
end

group "koha" do
  gid 3000
  system true
end

user "koha" do
  comment "Koha System User"
  uid 3000
  gid "koha"
  home "/home/koha"
  shell "/bin/bash"
end

git "/home/vagrant/koha" do
  action :sync
  repository "git://git.koha-community.org/koha.git"
  revision "3.8.x"
  user "vagrant"
  group "vagrant"
  # shallow clone
  #depth 5
end

execute "setup koha" do
  command "cd /home/vagrant/koha && perl Makefile.PL"
  environment ({'WEBSERVER_IP' => '192.168.33.10', 'INSTALL_MODE' => 'dev', 'INSTALL_BASE' => '/home/vagrant/koha', 'PERL_MM_USE_DEFAULT' => '1'})
  action :run
  user "vagrant"
  cwd "/home/vagrant/koha"
  not_if {File.exists?("/home/vagrant/koha/Makefile")}
end

execute "make koha" do
  command "cd /home/vagrant/koha && make"
  environment ({'WEBSERVER_IP' => '192.168.33.10'})
  action :run
  user "vagrant"
  cwd "/home/vagrant/koha"
  not_if {File.exists?("/home/vagrant/koha/blib")}
end

execute "install koha" do
  command "cd /home/vagrant/koha && make install"
  user "vagrant"
  action :run
  cwd "/home/vagrant/koha"
  not_if {File.exists?("/home/vagrant/koha/bin")}
end

link "/etc/apache2/sites-available/koha.conf" do
  to "/home/vagrant/koha/etc/koha-httpd.conf"
end

apache_site "000-default" do
  enable false
end

apache_site "koha.conf" do
  enable true
  notifies :restart, "service[apache2]"
end


# zebra
link "/etc/init.d/koha-zebra-daemon" do
  to "/home/vagrant/koha/bin/koha-zebra-ctl.sh"
end

service "koha-zebra-daemon" do
  supports :restart => true
  action [ :enable, :start ]
end

cron "zebra_indexer" do
  command "KOHA_CONF=/home/vagrant/koha/etc/koha-conf.xml /home/vagrant/koha/misc/migration_tools/rebuild_zebra.pl -z -b -a"
  user "koha"
  minute "*/10"
end

# zebra indexer
#cpan_module "Koha::Contrib::Tamil"

#template "koha-index-daemon-ctl.sh" do
#  path "/home/vagrant/koha/bin/koha-index-daemon-ctl.sh"
#  source "koha-index-daemon-ctl.sh.erb"
#  owner "vagrant"
#  mode 0644
#end

