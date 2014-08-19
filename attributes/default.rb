default['imagemagick']['install_type'] = "package"
default['imagemagick']['version'] = nil

default['imagemagick']['configure_options'] = []
default['imagemagick']['prefix'] = "/usr/local"
default['imagemagick']['bindir'] = "#{imagemagick['prefix']}/bin"
default['imagemagick']['libdir'] = "#{imagemagick['prefix']}/lib"
