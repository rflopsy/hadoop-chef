
include_recipe 'hadoop_cluster::impala' 

package "impala-server" do
  action :install
end

