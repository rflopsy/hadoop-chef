
# install and configure Hue

package "impala" do
  options "-f --force-yes"
  action :upgrade
end
 
# directory '/usr/lib/impala/conf' do
#   owner  'impala'
#   group  'impala'
#   mode   '0755'
#   action :create
# end
 
# %w(core-site.xml hdfs-site.xml).each do |file|
#   template "/usr/lib/impala/conf/#{file}" do
#     mode "0644"
#     owner "impala"
#     group "impala"
#     source "etc/hadoop/conf/#{file}.erb"
#   end
# end
 
# template "/usr/lib/impala/conf/hive-site-xml" do
#   mode "0644"
#   owner "impala"
#   group "impala"
#   source "etc/hive/conf/hive-site.xml.erb"
# end

