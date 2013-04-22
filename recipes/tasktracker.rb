hadoop_log_dir = '/hvar/hadoop-0.20-mapreduce/logs'
make_hadoop_dir(hadoop_log_dir, 'hdfs', "0775")
force_link("/var/log/hadoop-0.20-mapreduce", hadoop_log_dir )

package "hadoop-0.20-mapreduce-tasktracker" do
  action :install
end
