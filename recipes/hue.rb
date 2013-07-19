
# install and configure Hue


package "hue" do
  action :install
end

package "hue-server" do
  action :install
end


hadoop_host = discover(:namenode, :server).private_ip rescue nil

template_variables = {
  :hadoop_host => hadoop_host
}

template "/etc/hue/hue.ini" do
  source "hue.ini.erb"
  mode 0664
  variables(template_variables)
  owner "root"
end
