#
# Cookbook Name:: koha
# Recipe:: requirements
#
# Copyright 2012, Elliot Pahl
#
# All rights reserved - Do Not Redistribute
#

#r = apt_repository "koha-community" do
#  uri "http://debian.koha-community.org/koha"
#  distribution "squeeze"
#  components ["main"]
#  keyserver "keys.gnupg.net"
#  key "A99CEB6D"
#  action :nothing
#end
#
#r.run_action(:add)

a = execute "apt-get update" do
  action :nothing
end

a.run_action(:run)

%w{ python-software-properties }.each do |pack|
  package pack do
    action :nothing
  end.run_action(:install)
end

t = execute "add-apt-repository 'deb http://debian.koha-community.org/koha squeeze main'" do
  action :nothing
end

t.run_action(:run)

unless system("apt-key list | grep A99CEB6D")
  execute "install-key A99CEB6D" do
    command "apt-key adv --keyserver keys.gnupg.net --recv A99CEB6D"
    action :nothing
  end.run_action(:run)
end

u = execute "apt-get update" do
  action :nothing
end

u.run_action(:run)

%w{ make git }.each do |pack|
  package pack do
    action :nothing
  end.run_action(:install)
end

%w{ libalgorithm-checkdigits-perl libauthen-cas-client-perl libbiblio-endnotestyle-perl libbusiness-isbn-perl libcgi-session-driver-memcached-perl libcgi-session-perl libcgi-session-serialize-yaml-perl libclass-factory-util-perl libdata-ical-perl libdate-calc-perl libdate-manip-perl libdatetime-perl libdatetime-format-dateparse-perl libdatetime-format-ical-perl libdatetime-format-mail-perl libdatetime-format-mysql-perl libdatetime-format-strptime-perl libdatetime-format-w3cdtf-perl libdatetime-locale-perl libdatetime-timezone-perl libdbd-mysql-perl libdbd-sqlite2-perl libdbi-perl libemail-date-perl libgd-barcode-perl libgraphics-magick-perl libgravatar-url-perl libhtml-scrubber-perl libhtml-template-pro-perl libhttp-oai-perl liblingua-ispell-perl liblingua-stem-perl liblingua-stem-snowball-perl liblist-moreutils-perl liblocale-currency-format-perl liblocale-gettext-perl liblocale-po-perl libmail-sendmail-perl libmarc-charset-perl libmarc-crosswalk-dublincore-perl libmarc-record-perl libmarc-xml-perl libmemoize-memcached-perl libmime-lite-perl libmodern-perl libmodule-install-perl libnet-ldap-perl libnet-server-perl libpdf-api2-simple-perl libreadonly-perl libreadonly-xs-perl libnet-z3950-zoom-perl libnumber-format-perl libpdf-api2-perl libpdf-reuse-perl libpdf-reuse-barcode-perl libpdf-table-perl libpoe-perl libschedule-at-perl libsms-send-perl libtemplate-perl libtemplate-plugin-htmltotext-perl libtext-charwidth-perl libtext-csv-encoded-perl libtext-csv-perl libtext-iconv-perl libtext-unaccent-perl libtext-wrapi18n-perl libtimedate-perl libtime-duration-perl libtime-format-perl libuniversal-require-perl libunix-syslog-perl libxml-perl libxml-dom-perl libxml-dumper-perl libxml-libxml-perl libxml-libxslt-perl libxml-namespacesupport-perl libxml-parser-perl libxml-regexp-perl libxml-rss-perl libxml-sax-writer-perl libxml-simple-perl libxml-xslt-perl libyaml-perl libyaml-syck-perl }.each do |pack|
  package pack do
    action :nothing
  end.run_action(:install)
end

template "ParserDetails.ini" do
  path "/etc/perl/XML/SAX/ParserDetails.ini"
  source "perl.XML.SAX.ParserDetails.ini.erb"
  owner "root"
  mode 0644
end

gem_package "mysql" do
  action :install
end

