
include_recipe 'hadoop_cluster::impala' 

package "impala-state-store" do
  action :install
end

package "impala-server" do
  action :install
end


if node[:vagrant]
  statestore = "33.33.33.33"
else
  statestore = "localhost"
end

site_variables = {
  :state_store  => statestore,
  :num_threads_per_disk => 3,
  :num_disks => 3
}

template "/etc/default/impala" do
  source "default-impala.erb"
  mode 0664
  owner "root"
  variables(site_variables)
end

execute "service impala-state-store start" do
  command "service impala-state-store start"
  ignore_failure true
end

# execute "impala-server start" do
#   user  'ubuntu'
#   command "export LC_ALL=en_US.UTF-8 /etc/init.d/impala-server start"
#   environment ({'LC_ALL' => 'en_US.UTF-8'})
# end

bash "impala-server start" do
  user 'root'
  environment ({'LC_ALL' => 'en_US.UTF-8'})
  code <<-EOH
    LC_ALL=en_US.UTF-8 /etc/init.d/impala-server start
  EOH
end


