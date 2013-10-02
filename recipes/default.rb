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


execute "#{node['koha']['database']['name']} database" do
  command "/usr/bin/mysqladmin -h #{node['koha']['database']['host']} -u #{node['koha']['database']['admin_user']} -p#{node['koha']['database']['admin_password']} create #{node['koha']['database']['name']}"
  not_if "mysql -h #{node['koha']['database']['host']} -u root -p#{node['mysql']['server_root_password']} --silent --skip-column-names --execute=\"show databases like '#{node['koha']['database']['name']}'\" | grep #{node['koha']['database']['name']}"

end

execute "mysql-install-koha-privileges" do
  command "/usr/bin/mysql -h #{node['koha']['database']['host']} -u #{node['koha']['database']['admin_user']}  -p#{node['koha']['database']['admin_password']} < /etc/mysql/koha-grants.sql"
  action :nothing
end

template "/etc/mysql/koha-grants.sql" do
  path "/etc/mysql/koha-grants.sql"
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node['koha']['database']['user'],
    :password => node['koha']['database']['password'],
    :database => node['koha']['database']['name'],
    :host => node['koha']['database']['host']
  )
  notifies :run, "execute[mysql-install-koha-privileges]", :immediately
end



group "#{node['koha']['user']['group']}" do
  gid 3000
  system true
end

user "#{node['koha']['user']['name']}" do
  comment "Koha System User"
  uid node['koha']['user']['uid']
  gid node['koha']['user']['group']
  home node['koha']['user']['home']
  shell node['koha']['user']['shell']
  supports :manage_home => true
end

git "#{node['koha']['install_base']}" do
  action :sync
  repository node['koha']['repository']
  revision node['koha']['revision']
  user node['koha']['deploy']['user']
  group node['koha']['deploy']['group']
  # shallow clone
  #depth 5
end

execute "configure koha" do
  command "cd #{node['koha']['install_base']} && perl Makefile.PL"
  environment ({
    'WEBSERVER_IP' => node['koha']['webserver']['ip'],
    'INSTALL_MODE' => node['koha']['install_mode'],
    'INSTALL_BASE' => node['koha']['install_base'],
    'PERL_MM_USE_DEFAULT' => '1'
  })
  action :run
  user node['koha']['deploy']['user']
  cwd "#{node['koha']['install_base']}"
  not_if {File.exists?("#{node['koha']['install_base']}/Makefile")}
end

execute "make koha" do
  command "cd #{node['koha']['install_base']} && make"
  environment ({
    'WEBSERVER_IP' => node['koha']['webserver']['ip']
  })
  action :run
  user node['koha']['deploy']['user']
  cwd "#{node['koha']['install_base']}"
  not_if {File.exists?("#{node['koha']['install_base']}/blib")}
end

execute "install koha" do
  command "cd #{node['koha']['install_base']} && make install"
  user node['koha']['deploy']['user']
  action :run
  cwd "#{node['koha']['install_base']}"
  not_if {File.exists?("#{node['koha']['install_base']}/bin")}
end

link "/etc/apache2/sites-available/koha.conf" do
  to "#{node['koha']['install_base']}/etc/koha-httpd.conf"
end

apache_site "koha.conf" do
  enable true
  notifies :restart, "service[apache2]"
end

# zebra
link "/etc/init.d/koha-zebra-daemon" do
  to "#{node['koha']['install_base']}/bin/koha-zebra-ctl.sh"
end

service "koha-zebra-daemon" do
  supports :restart => true
  action [ :enable, :start ]
end

cron "zebra_indexer" do
  command "KOHA_CONF=#{node['koha']['install_base']}/etc/koha-conf.xml #{node['koha']['install_base']}/misc/migration_tools/rebuild_zebra.pl -z -b -a"
  user "koha"
  minute "*/10"
end

# zebra indexing daemon
#   Do not use when running the cron indexer
#cpan_module "Koha::Contrib::Tamil"

#template "koha-index-daemon-ctl.sh" do
#  path "#{node['koha']['install_base']}/bin/koha-index-daemon-ctl.sh"
#  source "koha-index-daemon-ctl.sh.erb"
#  owner "vagrant"
#  mode 0644
#end

