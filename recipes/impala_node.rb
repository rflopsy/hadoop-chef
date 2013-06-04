
include_recipe 'hadoop_cluster::impala' 

%w[core-site.xml hdfs-site.xml].each do |conf_file|
  execute "cp /etc/hadoop/conf/#{conf_file} /etc/impala/conf/"
end


package "impala-server" do
  action :install
end

namenode  = discover(:namenode, :server).private_ip rescue nil

site_variables = {
    :state_store  => namenode,
}

template "/etc/default/impala" do
  source "default-impala.erb"
  mode 0664
  owner "root"
  variables(site_variables)
end

execute("/etc/init.d/impala-server start")

