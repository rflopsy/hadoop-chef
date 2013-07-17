#
# Cookbook Name:: hadoop
# Recipe::        worker
#
# Copyright 2010, Infochimps, Inc
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

#
# Format Namenode


service "hadoop-hdfs-namenode" do
  supports :status => true, :restart => false
end

execute 'format_namenode **IDEMPOTENT**' do
  command %Q{yes 'Y' | hdfs namenode -format ; true}
  user 'hdfs'
  creates '/data1/hadoop/hdfs/name/current/VERSION'
  notifies  :restart, resources(:service => "hadoop-hdfs-namenode"), :immediately
end
