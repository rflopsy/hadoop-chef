#
# Cookbook Name:: hadoop
# Recipe::        datanode
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

package "hadoop-hdfs-datanode" do
  action :install
end

namenode_address = discover(:namenode, :server).private_ip rescue nil
jobtracker = discover(:jobtracker, :server).private_ip rescue nil

template_variables = {
  :namenode_address       => namenode_address,
  :jobtracker_address     => jobtracker,
  :mapred_local_dirs      => mapred_local_dirs.join(','),
  :dfs_name_dirs          => dfs_name_dirs.join(','),
  :dfs_data_dirs          => dfs_data_dirs.join(','),
  :fs_checkpoint_dirs     => fs_checkpoint_dirs.join(','),
  :local_hadoop_dirs      => local_hadoop_dirs,
  :persistent_hadoop_dirs => persistent_hadoop_dirs,
  :fs_trash_interval      => node['hadoop']['fs_trash_interval'] || "60"
}

# create after installing packages
%w[ core-site.xml hdfs-site.xml mapred-site.xml hadoop-metrics.properties].each do |conf_file|
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

# Make hadoop logs live on /hvar/hadoop
hadoop_log_dir = '/hvar/hadoop/logs'
make_hadoop_dir(hadoop_log_dir, 'hdfs', "0775")
force_link("/var/log/hadoop", hadoop_log_dir )

hdfs_log_dir = '/hvar/hadoop-hdfs/logs'
make_hadoop_dir(hdfs_log_dir, 'hdfs', "0775")
force_link("/var/log/hadoop-hdfs", hadoop_log_dir )

# Make hadoop point to /var/run for pids
make_hadoop_dir('/var/run/hadoop', 'root', "0775")
