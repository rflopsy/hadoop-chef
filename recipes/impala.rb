template "/etc/apt/sources.list.d/impala.list" do
  owner "root"
  mode "0644"
  source "sources.list.d-impala.list.erb"
  notifies :run, resources("execute[apt-get update]"), :immediately
end

package "impala" do
  action :install
end

jobtracker   = discover(:jobtracker, :server).private_ip rescue nil
namenode     = discover(:namenode, :server).private_ip rescue nil
hive_metastore = discover(:namenode, :server).private_ip rescue nil


site_variables = {
  :zookeeper_address   => "localhost",
  :mapred_map_tasks    => 18,
  :hive_aux_jars_path  => "",
  :hbase_master_host   => 'localhost',
  :hbase_master_port   => 60000,
  :namenode_fqdn       => namenode,
  :jobtracker_fqdn     => jobtracker,
  :hive_metastore      => hive_metastore,
  :hive_heartbeat_interval => 5000
}

template "/etc/impala/conf/hive-site.xml" do
  source "impala-hive-site.xml.erb"
  mode 0664
  owner "root"
  variables(site_variables)
end

package "impala-shell" do
  action :install
end
