
include_recipe 'hadoop_cluster::impala' 

package "impala-state-store" do
  action :install
end

package "impala-server" do
  action :install
end

