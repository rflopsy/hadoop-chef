
include_recipe 'hadoop_cluster::impala' 

%w[core-site.xml hdfs-site.xml].each do |conf_file|
  execute "cp /etc/hadoop/conf/#{conf_file} /etc/impala/conf/"
end


package "impala-server" do
  action :install
end


namenode  = discover(:namenode, :server).private_ip rescue nil

if node[:vagrant]
  namenode = "localhost"
end

site_variables = {
  :state_store  => namenode,
  :num_threads_per_disk => 3,
  :num_disks => 3
}

template "/etc/default/impala" do
  source "default-impala.erb"
  mode 0664
  owner "root"
  variables(site_variables)
end

service "impala-server" do
  action [ :enable, :start ]
  running true
  supports :status => true, :restart => true
end

execute "sudo -E service impala-server start"
