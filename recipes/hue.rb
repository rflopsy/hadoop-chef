
# install and configure Hue


package "hue" do
  action :install
end

package "hue-server" do
  action :install
end

template "/etc/hue/hue.ini" do
  source "hue.ini.erb"
  mode 0664
  owner "root"
end
