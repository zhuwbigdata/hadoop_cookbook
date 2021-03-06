#
# Cookbook Name:: hadoop
# Library:: helpers
#
# Copyright © 2015-2016 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Hadoop
  module Helpers
    #
    # Return HDP 2.2 version, including revision, used for building HDP 2.2+ on-disk paths
    #
    def hdp_version
      case node['hadoop']['distribution_version']
      when '2.2.0.0'
        '2.2.0.0-2041'
      when '2.2.4.2'
        '2.2.4.2-2'
      when '2.2.4.4'
        '2.2.4.4-16'
      when '2.2.6.0'
        '2.2.6.0-2800'
      when '2.2.8.0'
        '2.2.8.0-3150'
      when '2.2.9.0'
        '2.2.9.0-3393'
      when '2.3.0.0'
        '2.3.0.0-2557'
      when '2.3.2.0'
        '2.3.2.0-2950'
      when '2.3.4.0'
        '2.3.4.0-3485'
      when '2.3.4.7'
        '2.3.4.7-4'
      when '2.3.6.0'
        '2.3.6.0-3796'
      when '2.4.0.0'
        '2.4.0.0-169'
      when '2.4.2.0'
        '2.4.2.0-258'
      when '2.5.0.0'
        '2.5.0.0-1245'
      else
        node['hadoop']['distribution_version']
      end
    end

    #
    # Return true if HDP 2.2+
    #
    def hdp22?
      node['hadoop']['distribution'] == 'hdp' && node['hadoop']['distribution_version'].to_f >= 2.2
    end

    #
    # Return correct package name on ODP-based distributions
    #
    # Given name: hadoop-mapreduce-historyserver
    # ODP name: hadoop_2_4_0_0_169-mapreduce-historyserver
    #
    def hadoop_package(name)
      return name unless hdp22? || iop?
      return name if node['platform_family'] == 'debian'
      fw = name.split('-').first
      pv =
        if hdp22?
          hdp_version.tr('.', '_').tr('-', '_')
        else
          node['hadoop']['distribution_version'].tr('.', '_')
        end
      nn = "#{fw}_#{pv}"
      name.gsub(fw, nn)
    end

    # Return true if IOP
    #
    def iop?
      node['hadoop']['distribution'] == 'iop'
    end

    #
    # Return true if Kerberos is enabled
    #
    def hadoop_kerberos?
      node['hadoop']['core_site'].key?('hadoop.security.authorization') &&
        node['hadoop']['core_site'].key?('hadoop.security.authentication') &&
        node['hadoop']['core_site']['hadoop.security.authorization'].to_s == 'true' &&
        node['hadoop']['core_site']['hadoop.security.authentication'] == 'kerberos'
    end

    #
    # Return parent directory for various Hadoop lib directories and homes
    #
    def hadoop_lib_dir
      if hdp22?
        "/usr/hdp/#{hdp_version}"
      elsif iop?
        "/usr/iop/#{node['hadoop']['distribution_version']}"
      else
        '/usr/lib'
      end
    end
  end
end

# Load helpers
Chef::Recipe.send(:include, Hadoop::Helpers)
Chef::Resource.send(:include, Hadoop::Helpers)
