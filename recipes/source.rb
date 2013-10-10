include_recipe "build-essential"

# Add repositories for older platforms
case node.platform
when "centos", "redhat"
  include_recipe "yum::repoforge"
end

# Install required development packages
dev_packages = value_for_platform(
  ["centos", "redhat"] => {
    "default" => %w{freetype-devel ghostscript-devel libwmf-devel jasper-devel
      lcms-devel bzip2-devel librsvg2 librsvg2-devel libtool-ltdl-devel}}
)
dev_packages.each do |pkg|
  package pkg do
    action :install
  end
end

# Build the name of the source archive
version = node['imagemagick']['version']
name_parts = ["ImageMagick"]
if not version.nil?
  name_parts << version
  if not version.end_with?(/-\d+/)
    name_parts << "10"
  end
end
base_name = name_parts.join("-")

# Determine file paths
source_dir = "#{Chef::Config['file_cache_path']}/#{base_name}"
source_file = "#{source_dir}.tar.gz"
remote_source_dir = version.nil? ? "" : "/legacy"

# Download the source
remote_file source_file do
  source "#{node['imagemagick']['base_url']}#{remote_source_dir}/#{base_name}.tar.gz"
  not_if { File.exist?(source_file) }
end

# Build the configure options and binary paths
configure_options = node['imagemagick']['configure_options'].dup
configure_options << "--prefix=#{node['imagemagick']['prefix']}"
configure_options << "--bindir=#{node['imagemagick']['bindir']}"
configure_options << "--libdir=#{node['imagemagick']['libdir']}"
convert = "#{node['imagemagick']['bindir']}/convert"

# Extract and install the source
if version.nil?
  install_check = "which #{convert}"
else
  install_check = "#{convert} --version | grep #{version}"
end
execute "Install ImageMagick" do
  cwd Chef::Config['file_cache_path']
  command <<-COMMAND
    tar -xzf #{source_file}
    cd #{source_dir} #{node['imagemagick']['configure_options'].uniq.join(" ")}
    ./configure
    make
    make install
  COMMAND
  not_if install_check
end

# Add imagemagick's library directory to the library search directories
template "/etc/ld.so.conf.d/imagemagick.conf" do
  source "imagemagick.conf.erb"
  mode "0644"
  variables "library_path" => node['imagemagick']['libdir'] || "/usr/local/lib"
  notifies :run, "execute[Update ImageMagick libraries]", :immediately
end

# Run ldconfig to update the ImageMagick libraries
execute "Update ImageMagick libraries" do
  command "ldconfig"
  action :nothing
end
