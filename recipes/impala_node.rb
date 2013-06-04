
include_recipe 'hadoop_cluster::impala' 

%w[ core-site.xml hdfs-site.xml].each do |conf_file|
  execute "cp /etc/hadoop/conf/#{conf_file} /etc/impala/conf/"
end

package "impala-server" do
  action :install
end

