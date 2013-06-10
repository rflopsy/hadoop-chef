# http://wiki.opscode.com/display/chef/Metadata
maintainer        "Infochimps.org"
maintainer_email  "help@infochimps.org"
license           "Apache 2.0"
description       "Installs hadoop and sets up a high-performance cluster. Inspired by Tom White / Cloudera's hadoop-ec2 command line utilities"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "0.9.9"

%w(java silverware hosts mysql).each do |cb|
  depends cb
end

%w{ debian ubuntu }.each do |os|
  supports os
end
