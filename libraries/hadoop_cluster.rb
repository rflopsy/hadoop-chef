module HadoopCluster

  def hadoop_package component
    package_name = (component ? "#{node[:hadoop][:hadoop_handle]}-#{component}" : "#{node[:hadoop][:hadoop_handle]}")
    package package_name do
      if node[:hadoop][:deb_version] != 'current'
        version node[:hadoop][:deb_version]
      end
    end
  end

  # Make a hadoop-owned directory
  def make_hadoop_dir dir, dir_owner, dir_mode="0755"
    directory dir do
      owner    dir_owner
      group    "hadoop"
      mode     dir_mode
      action   :create
      recursive true
    end
  end

  def make_hadoop_dir_on_ebs dir, dir_owner, dir_mode="0755"
    directory dir do
      owner    dir_owner
      group    "hadoop"
      mode     dir_mode
      action   :create
      recursive true
    end
  end

  def ensure_hadoop_owns_hadoop_dirs dir, dir_owner, dir_mode="0755"
    execute "Make sure hadoop owns hadoop dirs" do
      command %Q{mkdir -p #{dir}}
    end

    execute "Make sure hadoop owns hadoop dirs" do
      command %Q{mkdir -p #{dir}}
      command %Q{chown -R #{dir_owner}:hadoop #{dir}}
      command %Q{chmod -R #{dir_mode}         #{dir}}
      not_if{ (File.stat(dir).uid == dir_owner) && (File.stat(dir).gid == 300) }
    end
  end

  # Create a symlink to a directory, wiping away any existing dir that's in the way
  def force_link dest, src
    directory(dest) do
      action :delete ; recursive true
      not_if{ File.symlink?(dest) }
    end
    link(dest){ to src }
  end

  def local_hadoop_dirs
    ["/data1/hadoop", "/data2/hadoop", "/data3/hadoop"]
  end

  def persistent_hadoop_dirs
    ["/data1/hadoop", "/data2/hadoop", "/data3/hadoop"]
  end
  
  def cluster_ebs_volumes_are_mounted?
    return true if cluster_ebs_volumes.nil?
    cluster_ebs_volumes.all?{|vol_info| File.exists?(vol_info['device']) }
  end

  # The HDFS data. Spread out across persistent storage only

  def hadoop_dirs
    persistent_hadoop_dirs.select {|x| x != "/mnt/hadoop"}
  end
  
  def dfs_data_dirs
    hadoop_dirs.map{|dir| File.join(dir, 'hdfs/data')}
  end
  # The HDFS metadata. Keep this on two different volumes, at least one persistent
  def dfs_name_dirs
    dirs = hadoop_dirs.map{|dir| File.join(dir, 'hdfs/name')}
    unless node[:hadoop][:extra_nn_metadata_path].nil?
      dirs << File.join(node[:hadoop][:extra_nn_metadata_path].to_s, node[:cluster_name], 'hdfs/name')
    end
    dirs
  end
  # HDFS metadata checkpoint dir. Keep this on two different volumes, at least one persistent.
  def fs_checkpoint_dirs
    dirs = hadoop_dirs.map{|dir| File.join(dir, 'hdfs/secondary')}
    unless node[:hadoop][:extra_nn_metadata_path].nil?
      dirs << File.join(node[:hadoop][:extra_nn_metadata_path].to_s, node[:cluster_name], 'hdfs/secondary')
    end
    dirs
  end
  # Local storage during map-reduce jobs. Point at every local disk.
  def mapred_local_dirs
    local_hadoop_dirs.map{|dir| File.join(dir, 'mapred/local')}
  end

end

class Chef::Recipe
  include HadoopCluster
end
class Chef::Resource::Directory
  include HadoopCluster
end
