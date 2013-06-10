
#
# Cookbook Name:: hadoop
# Recipe:: hive
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "mysql::server"

package "hive" do
  options "-f"
end

package 'hive-server' do
  options "-f"
end

package 'hive-metastore' do
  options "-f"
end

zk_server_info = []

if node[:vagrant] or node[:standalone]
  jobtracker  = '127.0.0.1'
  namenode     = node['hostname']
  hbase_master = node['hostname']
  zk_server_info = [node['hostname']]
else
  jobtracker   = discover(:jobtracker, :server).private_ip rescue nil
  jobtracker   = discover(:jobtracker, :server).private_ip rescue nil
  namenode     = discover(:namenode, :server).private_ip rescue nil

end

site_variables = {
  :zookeeper_address   => "localhost",
  :mapred_map_tasks    => 18,
  :hive_aux_jars_path  => "",
  :hbase_master_host   => 'localhost',
  :hbase_master_port   => 60000,
  :namenode_fqdn       => namenode,
  :jobtracker_fqdn     => jobtracker,
  :hive_heartbeat_interval => 5000
}

directory "/var/lib/hadoop-0.20/cache/hive" do
  action :create
  recursive true
  owner     "hive"
  group     "hive"
end

template "/etc/hive/conf/hive-default.xml" do
  source "hive-default.xml.erb"
  mode 0664
  owner "root"
end

template "/etc/hive/conf/hive-site.xml" do
  source "hive-site-mysql.xml.erb"
  mode 0664
  owner "root"
  variables(site_variables)
end

env_variables = {
  }

template "/etc/hive/conf/hive-env.sh" do
  source "hive-env.sh.erb"
  mode 0664
  owner "root"
  variables(env_variables)
end

directory "/var/lock/subsys" do
  action :create
  recursive true
end

directory "/var/run/hive" do
  action :create
  recursive true
end


service "hive-server" do
  action [ :enable, :start ]
  running true
  supports :status => true, :restart => true
end

execute "/usr/sbin/update-rc.d -f hadoop-hive-server remove"



# setup mysql..
# node['mysql']['server_root_password'] - Set the server's root password
# node['mysql']['server_repl_password'] - Set the replication user 'repl' password
# node['mysql']['server_debian_password'] - Set the debian-sys-maint user password


grants_path = "/etc/mysql/app_grants.sql"

template grants_path do
  source "app_grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  action :create
end

# bind address should be 0.0.0.0 for jdbc connector
template "/etc/mysql/my.cnf" do
  source "my.cnf.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  action :create
end

execute "mysql-install-application-privileges" do
  command "/usr/bin/mysql -u root -p#{node['mysql']['server_root_password']} < /etc/mysql/app_grants.sql"
  action :nothing
  subscribes :run, resources(:template => "/etc/mysql/app_grants.sql"), :immediately
end

# CREATE USER 'hive'@'localhost' IDENTIFIED BY 'hive';
# GRANT ALL PRIVILEGES ON *.* TO 'hive'@'localhost' WITH GRANT OPTION;

# remote_file https://find-ur-pal.googlecode.com/files/mysql-connector-java-5.1.18-bin.jar
remote_file "/usr/lib/hive/lib/mysql-connector-java-5.1.18-bin.jar" do
  source "https://find-ur-pal.googlecode.com/files/mysql-connector-java-5.1.18-bin.jar"
  mode   "0644"
end
