
require "hdfs_jruby/version"

module Hdfs

  JAR_PATTERN_0_20="hadoop-core-*.jar"
  
  if RUBY_PLATFORM =~ /java/
    include Java
  else
    warn "only for use with JRuby"
  end
  
  if ENV["HADOOP_HOME"]
    HADOOP_HOME=ENV["HADOOP_HOME"]
    Dir["#{HADOOP_HOME}/#{JAR_PATTERN_0_20}","#{HADOOP_HOME}/lib/*.jar", "#{HADOOP_HOME}/share/hadoop/common/*.jar", "#{HADOOP_HOME}/share/hadoop/common/lib/*.jar", "#{HADOOP_HOME}/share/hadoop/hdfs/*.jar", "#{HADOOP_HOME}/share/hadoop/hdfs/lib/*.jar"].each  do |jar|
      require jar
    end
    $CLASSPATH << "#{HADOOP_HOME}/conf"
  else
    raise "HADOOP_HOME is not set!"
  end
  
  class FileSystem < org.apache.hadoop.fs.FileSystem
  end

  class Configuration < org.apache.hadoop.conf.Configuration
  end

  class Path < org.apache.hadoop.fs.Path
  end
  
  class FsPermission < org.apache.hadoop.fs.permission.FsPermission
  end
  
  @conf = Hdfs::Configuration.new()
  @fs = Hdfs::FileSystem.get(@conf)

  #def ls(path)
  #  p = _path(path)
  #  @fs.globStatus(p)
  #end
  
  def exists?(path)
    @fs.exists(_path(path))
  end

  def move(src, dst)
    @fs.rename(Path.new(src), Path.new(dst))
  end

  def delete(path, r=false)
    @fs.delete(_path(path), r)
  end

  def file?(path)
    @fs.isFile(_path(path))
  end

  def directory?(path)
    @fs.isDirectory(_path(path))
  end

  def size(path)
    @fs.getFileStatus(_path(path)).getLen()
  end
  
  def mkdir(path)
    @fs.mkdirs(_path(path))
  end

  def put(local, remote)
    @fs.copyFromLocalFile(Path.new(local), Path.new(remote))
  end

  def get(remote, local)
    @fs.copyToLocalFile(Path.new(remote), Path.new(local))
  end
  
  def get_home_directory()
    @fs.getHomeDirectory()
  end
  
  def get_working_directory()
    @fs.getWorkingDirectory()
  end

  def set_working_directory(path)
    @fs.setWorkingDirectory(_path())
  end

  def set_permission(path, perm)
    @fs.setPermission(_path(path), org.apache.hadoop.fs.permission.FsPermission.new(perm))
  end

  module_function :exists?
  module_function :move
  module_function :delete
  module_function :file?
  module_function :directory?
  module_function :size
  module_function :put
  module_function :get
  module_function :get_home_directory
  module_function :get_working_directory
  module_function :set_working_directory
  module_function :set_permission
  #module_function :ls

  private
  def _path(path)
    if path.nil?
      raise "path is nil"
    end
    Path.new(path)
  end

  module_function :_path
end
