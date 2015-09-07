#
# Cookbook Name:: zypper
# Provider:: repository
#
# Copyright 2013-2014, Thomas Boerger <thomas@webhippie.de>
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

action :add do
  if new_resource.keyserver && new_resource.key
    execute "gpg_load_#{new_resource.key}" do
      command "gpg --keyserver #{new_resource.keyserver} --recv-keys #{new_resource.key}"
    end

    execute "gpg_export_#{new_resource.key}" do
      command "gpg -a --export #{new_resource.key} > #{Chef::Config[:file_cache_path]}/#{new_resource.key}.key"
    end

    execute "rpm_import_#{new_resource.key}" do
      command "rpm --import #{Chef::Config[:file_cache_path]}/#{new_resource.key}.key"
    end
  elsif new_resource.key && (new_resource.key =~ /http/)
    execute "rpm_import_#{Digest::MD5.hexdigest(new_resource.key)}" do
      command "rpm --import #{new_resource.key}"
    end
  end

  if ::File.exists? "/etc/zypp/repos.d/repo-#{new_resource.alias}.repo"
    Chef::Log.info "Allready added #{new_resource.alias} repo"
  else
    Chef::Log.info "Adding #{new_resource.alias} repository"

    execute "zypper_addrepo_#{new_resource.alias}" do
      command "zypper --gpg-auto-import-keys -n addrepo '#{new_resource.title}' #{new_resource.uri} repo-#{new_resource.alias}"
    end

    new_resource.updated_by_last_action(true)
  end
end

action :remove do
  if ::File.exists? "/etc/zypp/repos.d/repo-#{new_resource.alias}.repo"
    Chef::Log.info "Removing #{new_resource.alias} repository"

    execute "zypper_removerepo_#{new_resource.alias}" do
      command "zypper --gpg-auto-import-keys -n removerepo repo-#{new_resource.alias}"
    end

    new_resource.updated_by_last_action(true)
  else
    Chef::Log.error "Remove failed for #{new_resource.alias}"
  end
end

action :refresh do
  Chef::Log.info "Refreshing #{new_resource.alias} repository"

  execute "zypper_refresh_#{new_resource.alias}" do
    command "zypper -n --gpg-auto-import-keys refresh repo-#{new_resource.alias}"
  end

  new_resource.updated_by_last_action(true)
end
