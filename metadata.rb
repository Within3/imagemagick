name             "imagemagick"
maintainer       "Opscode, Inc."
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Installs/Configures imagemagick"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.3"

depends "build-essential"
depends "yum-repoforge", "~> 0.1"

recipe "imagemagick", "Installs imagemagick using the requested instalation method"
recipe "imagemagick::devel", "Installs imagemagick development libraries"
recipe "imagemagick::package", "Installs imagemagick from a package"
recipe "imagemagick::rmagick", "Installs rmagick gem"
recipe "imagemagick::source", "Installs imagemagick from source"

%w{fedora centos rhel ubuntu debian}.each do |os|
  supports os
end
