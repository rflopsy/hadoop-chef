
#
# Cookbook Name:: hadoop
# Recipe:: jobtracker
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

package "hadoop-0.20-mapreduce-jobtracker" do
  action :install
end

announce(:jobtracker, :server)

hadoop_log_dir = '/mnt/hadoop-0.20-mapreduce/logs'
make_hadoop_dir(hadoop_log_dir, 'hdfs', "0775")
force_link("/var/log/hadoop-0.20-mapreduce", hadoop_log_dir )

jobtracker = discover(:jobtracker, :server).private_ip rescue nil


zk_server_info = []

node[:zookeeper][:myid].keys.each do |nodename|
  chef_nodes = search(:node, "name:#{nodename}")

  begin
    this_node = chef_nodes.first
    info = this_node[:cloud][:private_ips].first
    zk_server_info.push(info)
  rescue NoMethodError
    Chef::Log.warn "Node not found on opscode: #{nodename}"
  end
end

template_variables = {
  :jobtracker_address     => jobtracker,
  :mapred_local_dirs      => mapred_local_dirs.join(','),
  :zookeeper_address      => zk_server_info.join(",")
}

template "/etc/hadoop/conf/fairscheduler.xml" do
  owner  "root"
  mode   "0644"
  variables(template_variables)
  source "fairscheduler.xml.erb"
end

template "/etc/hadoop/conf/mapred-site.xml" do
  owner  "root"
  mode   "0644"
  variables(template_variables)
  source "mapred-site.xml.erb"
end

template "/etc/hadoop/conf/hadoop-env.sh" do
  owner  "root"
  mode   "0644"
  variables(template_variables)
  source "hadoop-env.sh.erb"
end


execute 'create user dirs on HDFS' do
  only_if "service hadoop-hdfs-namenode status"
  only_if "hdfs dfsadmin -safemode get | grep -q OFF"
  not_if do File.exists?("/mnt/hadoop-hdfs/logs/made_initial_dirs.log") end
  user 'hdfs'
  
  command %Q{
    hdfs dfs -mkdir           /hadoop/system/mapred
    hdfs dfs -chown -R mapred /hadoop/system
    hdfs dfs -chmod 755       /hadoop/system/mapred

    touch /mnt/hadoop-hdfs/logs/made_initial_dirs.log 
  }
end

# FIXME: is running true required ?
service "hadoop-0.20-mapreduce-jobtracker" do
  running true
  supports :status => true, :restart => false
  action :start
end
