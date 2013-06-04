include_recipe 'java'

package "hive"

zk_server_info = []

jobtracker   = discover(:jobtracker, :server).private_ip rescue nil
jobtracker   = discover(:jobtracker, :server).private_ip rescue nil
namenode     = discover(:namenode, :server).private_ip rescue nil
hbase_master = discover(:hbase, :server, node[:hbase][:clustername]).private_ip rescue nil

node[:zookeeper][:myid].keys.each do |nodename|
  chef_nodes = search(:node, "name:#{nodename}")

   begin
      this_node = chef_nodes.first
      info = this_node[:cloud][:private_ips].first
      zk_server_info.push(info)
    rescue NoMethodError
      Chef::Log.warn "Node not found on opscode: #{nodename}"
    end
end

site_variables = {
  :zookeeper_address   => zk_server_info.join(","),
  :mapred_map_tasks    => 18,
  :hive_aux_jars_path  => "",
  :hbase_master_host   => hbase_master,
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
  source "hive-site.xml.erb"
  mode 0664
  owner "root"
  variables(site_variables)
end

env_variables = {
  :hive_aux_jars_path => "/usr/lib/hbase/hbase-*.jar"
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

directory "/var/lib/hivevar/metastore/" do
  action :create
  recursive true
  owner     "hive"
  group     "hive"
end

# package "hive"
# package "hive-server"

