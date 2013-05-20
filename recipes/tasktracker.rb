hadoop_log_dir = '/mnt/hadoop-0.20-mapreduce/logs'
make_hadoop_dir(hadoop_log_dir, 'hdfs', "0775")
force_link("/var/log/hadoop-0.20-mapreduce", hadoop_log_dir )

package "hadoop-0.20-mapreduce-tasktracker" do
  action :install
end

template "/etc/hadoop/conf/hadoop-env.sh" do
  owner  "root"
  mode   "0644"
  source "hadoop-env.sh.erb"
end

service "hadoop-0.20-mapreduce-tasktracker" do
  running true
  supports :status => true, :restart => true
  action :start
end

execute "mkdir -p /opt/ruby/bin"
execute "rm -f /opt/ruby/bin/ruby"
execute "cp /opt/chef/embedded/bin/ruby /opt/ruby/bin/ruby"
