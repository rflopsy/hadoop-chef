#
# Cookbook Name::       hadoop_cluster
# Description::         Add Cloudera repo to package manager
# Recipe::              add_cloudera_repo
# Author::              Chris Howe - Infochimps, Inc
#
# Copyright 2011, Chris Howe - Infochimps, Inc
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

execute("apt-get update"){ action :nothing }

remote_file "/tmp/cdh4-repository_1.0_all.deb" do
  source "http://archive.cloudera.com/cdh4/one-click-install/precise/amd64/cdh4-repository_1.0_all.deb"
end

execute "dpkg -i cdh4-repository_1.0_all.deb" do
  command "dpkg -i cdh4-repository_1.0_all.deb"
  cwd     "/tmp"
end

template "/etc/apt/sources.list.d/cloudera.list" do
  owner "root"
  mode "0644"
  source "sources.list.d-cloudera.list.erb"
  notifies :run, resources("execute[apt-get update]"), :immediately
end
