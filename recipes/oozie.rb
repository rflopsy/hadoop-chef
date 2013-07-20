
package "oozie"

# bash "Create oozie dirs" do
#   user "hdfs"
#   cwd "/tmp"
#   code <<-EOH
#      hadoop fs -mkdir  /user/oozie
#      hadoop fs -chown oozie:oozie /user/oozie
#      EOH
# end

# bash "Untar oozie sharelib" do
#   user 'root'
#   cwd "/tmp"
#   code <<-EOH
#      tar xzf /usr/lib/oozie/oozie-sharelib.tar.gz
#   EOH
# end

# bash "Copy sharelib" do
#   user 'root'
#   cwd "/tmp"
#   code <<-EOH
#    sudo -u oozie hadoop fs -put share /user/oozie/share
#   EOH
# end

# execute "Update oozie database" do
#   user 'oozie'
#   command "/usr/lib/oozie/bin/ooziedb.sh upgrade -run"
# end

service "oozie" do
  action [ :start, :enable ]
end


