#
# Cookbook Name:: hadoop
# Recipe:: namenode
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

class Chef::Recipe; include HadoopCluster ; end

package "hadoop-hdfs-namenode" do
  action :install
end

announce(:namenode, :server)

namenode = discover(:namenode, :server).private_ip rescue nil

template_variables = {
  :namenode_address       => namenode,
  :fs_checkpoint_dirs     => fs_checkpoint_dirs.join(','),
  :fs_trash_interval      => node['hadoop']['fs_trash_interval'] || "60",
  :dfs_name_dirs          => dfs_name_dirs.join(','),
  :dfs_data_dirs          => dfs_data_dirs.join(','),
}

# create after installing packages
# FIXME: Hadoop-metrics requires Ganglia
%w[ core-site.xml hdfs-site.xml hadoop-metrics.properties].each do |conf_file|
  template "/etc/hadoop/conf/#{conf_file}" do
    owner "root"
    mode "0644"
    variables(template_variables)
    source "#{conf_file}.erb"
  end
end

directory "/etc/hadoop-0.20/conf/" do
  owner    "mapred"
  group    "hadoop"
  mode     "0755"
  action   :create
  recursive true
end

template "/etc/hadoop-0.20/conf/fairscheduler.xml" do
  owner "root"
  mode "0644"
  variables(template_variables)
  source "fairscheduler.xml.erb"
end


file "/etc/hadoop-0.20/conf/dfs.hosts.exclude" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

# Make hadoop-hdfs logs live on /hvar/hadoop
hadoop_log_dir = '/hvar/hadoop-hdfs/logs'
make_hadoop_dir(hadoop_log_dir, 'hdfs', "0775")
force_link("/var/log/hadoop-hdfs", hadoop_log_dir )
