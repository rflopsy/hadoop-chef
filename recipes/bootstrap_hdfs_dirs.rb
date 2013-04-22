#
# Cookbook Name:: hadoop_cluster
# Recipe::        make_standard_hdfs_dirs
#
# Copyright 2010, Infochimps, Inc.
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
# Make the standard HDFS directories:
#
#   /tmp
#   /user
#   /user/hive/warehouse
#
# and
#
#   /user/USERNAME
#
# for each user in the 'supergroup' group.
#
# I'd love feedback on whether this can be made less kludgey,
# and whether the logic for creating the user dirs makes sense.
#
# Also, quoting Tom White:
#   "The [chmod +w] is questionable, as it allows a user to delete another
#    user. It's needed to allow users to create their own user directories"
#
# execute 'create user dirs on HDFS' do
#   only_if "service hadoop-hdfs-namenode status"
#   only_if "sudo -u hdfs hdfs dfsadmin -safemode get | grep -q OFF"
#   not_if do
#     File.exists?("/hvar/hadoop/logs/made_initial_dirs.log")
#   end

#   user 'hdfs'

#   # FIXME: Split the following into jobtracker and hbase master
#   # FIXME: touch the file only if the hdfs commands succeed
#   # command %Q{
#   #   hdfs dfs -mkdir           /hadoop/system/mapred
#   #   hdfs dfs -chown -R mapred /hadoop/system
#   #   hdfs dfs -chmod 755       /hadoop/system/mapred
#   #   hdfs dfs -mkdir           /hadoop/hbase
#   #   hdfs dfs -chown -R hbase  /hadoop/hbase

#   #   touch /hvar/hadoop/logs/made_initial_dirs.log 
#   # }

# end
