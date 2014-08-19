#
# Cookbook Name:: imagemagick
# Recipe:: source
#
# Copyright 2009, Opscode, Inc.
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

::Chef::Recipe.send(:include, ::Imagemagick::Source)

include_recipe "build-essential"

# Add repositories for older platforms
case node.platform
when "centos", "redhat"
  include_recipe "yum-repoforge"
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
source_url = imagemagick_source_url(version)
source_archive = imagemagick_source_archive(version)

# Determine file paths
source_dir = "#{Chef::Config['file_cache_path']}/#{source_archive}"
source_file = "#{source_dir}.tar.gz"

# Download the source
remote_file source_file do
  source source_url
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
