#
# Make sure hadoop is the owner of all files in the special hadoop dirs.
#
owners = node['owners']

dfs_name_dirs.each{      |dir| ensure_hadoop_owns_hadoop_dirs(dir, owners['hadoop']['uid'], "0700") }
dfs_data_dirs.each{      |dir| ensure_hadoop_owns_hadoop_dirs(dir, owners['hadoop']['uid'], "0755") }
fs_checkpoint_dirs.each{ |dir| ensure_hadoop_owns_hadoop_dirs(dir, owners['hadoop']['uid'], "0700") }
mapred_local_dirs.each{  |dir| ensure_hadoop_owns_hadoop_dirs(dir, owners['mapred']['uid'], "0755") }
ensure_hadoop_owns_hadoop_dirs('/hvar/hadoop-hdfs/logs',           owners['hadoop']['uid'], "0775")
ensure_hadoop_owns_hadoop_dirs('/hvar/hadoop-0.20-mapreduce/logs', owners['mapred']['uid'], "0775")
