name "zypper"
maintainer "Thomas Boerger"
maintainer_email "tboerger@tbpro.de"
license "Apache 2.0"
description "Installs/Configures zypper"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version "0.0.1"
recipe "zypper", "Installs/Configures zypper"

supports "suse"
