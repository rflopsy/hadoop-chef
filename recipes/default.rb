#
# Cookbook Name:: hadoop
# Recipe:: default
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

include_recipe "java"

class Chef::Recipe; include HadoopCluster ; end

package "openjdk-6-jdk"
# Hadoop users and group
#

group 'hdfs' do
  gid 302
  action [:create]
end

user 'hdfs' do
  uid        302
  group      'hdfs'
  home       "/var/run/hadoop"
  shell      "/bin/false"
  password   nil
  supports   :manage_home => true
  action     [:create, :manage]
end

group 'mapred' do gid 303
  action [:create]
end

user 'mapred' do
  comment    'Hadoop Mapred Runner'
  uid        303
  group      'mapred'
  home       "/var/run/hadoop"
  shell      "/bin/false"
  password   nil
  supports   :manage_home => true
  action     [:create, :manage]
end

group 'hadoop' do
  group_name 'hadoop'
  gid         node[:groups]['hadoop'][:gid]
  action      [:create, :manage]
  members     ['hdfs', 'mapred']
end

# Create the group hadoop uses to mean 'can act as filesystem root'
group 'supergroup' do
  group_name 'supergroup'
  gid        node[:groups]['supergroup'][:gid]
  action     [:create]
end
