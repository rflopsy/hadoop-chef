include_recipe 'java' 

include_recipe 'silverware'
include_recipe 'hadoop_cluster::add_cloudera_repo'
include_recipe 'hosts'

node.set[:hosts][:config] = "/etc/hosts"

hosts "127.0.1.1" do
  action :remove
  force  true
end

hosts node[:vagrant_ip] do
  entries [node[:vagrant_hostname]]
end

#
# Hadoop users and group
#

# daemon_user(:hadoop){ user(:hdfs)   }
# daemon_user(:hadoop){ user(:mapred) }

group 'hdfs' do gid 302 ; action [:create] ; end
user 'hdfs' do
  comment    'Hadoop HDFS User'
  uid        302
  group      'hdfs'
  home       "/var/run/hadoop-0.20"
  shell      "/bin/false"
  password   nil
  supports   :manage_home => true
  action     [:create, :manage]
end

group 'mapred' do gid 303 ; action [:create] ; end
user 'mapred' do
  comment    'Hadoop Mapred Runner'
  uid        303
  group      'mapred'
  home       "/var/run/hadoop-0.20"
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

#
# Primary hadoop packages
#
# (do this *after* creating the users)

# standard_dirs('hadoop') do
#   directories   :conf_dir, :pid_dir
# end

namenode_dir = "/var/lib/hadoop-hdfs/cache/hdfs/dfs/name"
secondarynamenode_dir = "/var/lib/hadoop-hdfs/cache/hdfs/dfs/namesecondary"
data_dir = "/var/lib/hadoop-hdfs/cache/hdfs/dfs/data"

directory namenode_dir do
  action :create
  owner  "hdfs"
  group  "hadoop"
  recursive true
end

directory secondarynamenode_dir do
  action :create
  owner  "hdfs"
  group  "hadoop"
  recursive true
end

directory data_dir do
  action :create
  owner  "hdfs"
  group  "hadoop"
  recursive true
end

package "hadoop-0.20-conf-pseudo" do
  action :install
end

temp_vars = {
  :namenode_address    => node['hostname'],
  :fs_trash_interval   => node['hadoop']['fs_trash_interval'] || "60"
}

template "/etc/hadoop/conf/core-site.xml" do
  owner "root"
  mode "0755"
  variables(temp_vars)
  source "pseudo-core-site.xml.erb"
end

execute 'format_namenode' do
  command %Q{yes 'Y' | hadoop namenode -format ; true}
  user 'hdfs'
  creates "#{namenode_dir}/current/VERSION"
  creates "#{namenode_dir}/current/seen_txid"
end

%w{hdfs-namenode hdfs-secondarynamenode hdfs-datanode 0.20-mapreduce-jobtracker 0.20-mapreduce-tasktracker}.each do |d|
  service "hadoop-#{d}" do
    supports :start => true, :stop => true, :restart => true, :status => true 
    action [ :start, :enable ]
  end
end

execute 'Set HDFS permissions' do
  user 'hdfs'
  command "hadoop fs -chmod 777 /"
end

