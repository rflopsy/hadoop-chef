
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


execute "service impala-state-store start"
execute "service impala-server start"
