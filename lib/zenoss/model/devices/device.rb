#############################################################################
# Copyright © 2010 Dan Wanek <dwanek@nd.gov>
#
#
# This file is part of zenoss_client.
# 
# zenoss_client is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# zenoss_client is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with zenoss_client.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
module Zenoss
  module Model
    class Device < OpenStruct
      include Zenoss::Model
      include Zenoss::Model::EventView
      include Zenoss::Model::RRDView
      include Zenoss::Model::DeviceResultInt
      include Zenoss::Model::ZenPropertyManager

      # Initialize this object from a Hash returned via getDevices from the JSON api
      # @param[Zenoss] zenoss the current instance we are connecting with
      # @param[Hash] zhash a hash of values used to create this Device instance
      def initialize(zenoss,zhash)
        @zenoss = zenoss
        super zhash
        self.ipAddress = IPAddr.new(IPAddr.inet_ntoa(self.ipAddress)) if self.ipAddress
      end

      # -------------------- JSON API Calls ------------------- #

      # Get events for this device
      def get_events
        @zenoss.query_events(self.uid)
      end

      def get_event_history
        @zenoss.query_events(self.uid,{:history => true})
      end

      def get_info(keys = nil)
        @zenoss.get_info(self.uid, keys)
      end

      # ------------------ Legacy REST Calls ------------------ #

      # Move this Device to the given DeviceClass.
      def change_device_class(device_class)
        reset_cache_vars
        rest("changeDeviceClass?deviceClassPath=#{device_class.organizer_name}")
      end


      # Instead of calling the /getId REST method, this method simply returns
      # the @device value since it is the same anyway.
      def get_id()
        @device
      end

      def sys_uptime
        rest("sysUpTime")
      end

      def get_hw_product_name
        rest('getHWProductName')
      end

      # Get the HTML formatted link to the Location that this devices exists at.
      # If you are looking for just the name, use #get_location_name instead.
      def get_location_link
        rest('getLocationLink')
      end

      # Returns a String value of the Location that this device exists at.  You can
      # also issue #get_location_link if you want an HTML link to the location page.
      def get_location_name
        rest('getLocationName')
      end

      # Returns data ready for serialization
      def get_data_for_json
        plist_to_array( rest('getDataForJSON') )
      end

      def get_device_group_names
        plist_to_array( rest('getDeviceGroupNames') )
      end

      # Returns a DateTime instance when this device was last modified.
      def get_last_change
        pdatetime_to_datetime( rest('getLastChange') )
      end

      # Return the management ip for this device.
      def get_manage_ip
        rest('getManageIp')
      end

      # Returns the name of the Zenoss Collector that this host currently belogs to.
      def get_performance_server_name
        rest('getPerformanceServerName')
      end

      # Return the pingStatus as a string
      def get_ping_status_string
        rest('getPingStatusString')
      end

      def get_pretty_link
        rest('getPrettyLink')
      end

      # Return the numeric device priority.
      def get_priority
        (rest('getPriority')).to_i
      end

      # Return the device priority as a string.
      def get_priority_string
        rest('getPriorityString')
      end

      # Return the prodstate as a string.
      def get_production_state_string
        rest('getProductionStateString')
      end

      def get_rrd_templates
      end

      # Returns a DateTime instance when this device was last collected from.
      def get_snmp_last_collection
        pdatetime_to_datetime( rest('getSnmpLastCollection') )
      end

      # Return the snmpStatus as a string.
      def get_snmp_status_string
        rest('getSnmpStatusString')
      end

      # Returns an Array of Zenoss /Systems that this device belogs to.
      def get_system_names
        plist_to_array( rest('getSystemNames') )
      end

      # Returns true if the device production state >= zProdStateThreshold.
      def monitor_device?
        (rest('monitorDevice')).eql?('True') ? true : false
      end

      # Returns true if the device is subject to SNMP monitoring
      def snmp_monitor_device?
        (rest('snmpMonitorDevice')).eql?('True') ? true : false
      end

      # Return the SNMP uptime
      def uptime_str
        rest('uptimeStr')
      end

      # Update the devices hardware tag with the passed string
      def set_hw_tag(asset_tag)
        puts "No REST implementation yet."
        #rest("setHWTag?assettag#{asset_tag}")
      end

      # Return list of monitored DeviceComponents on this device
      def get_monitored_components(collector=nil, type=nil)
        method = "getMonitoredComponents"
        method << '?' unless(collector.nil? && type.nil?)
        method << "collector=#{collector}&" unless collector.nil?
        method << "type=#{type}" unless type.nil?
        components = rest(method)

        # Turn the return string into an array of components
        (components.gsub /[\[\]]/,'').split /,\s+/
      end

      # Return list of all DeviceComponents on this device
      def get_device_components(monitored=nil, collector=nil, type=nil)
        method = "getDeviceComponents"
        method << '?' unless(monitored.nil? && collector.nil? && type.nil?)
        method << "monitored=#{monitored}&" unless monitored.nil?
        method << "collector=#{collector}&" unless collector.nil?
        method << "type=#{type}" unless type.nil?
        components = rest(method)

        plist_to_array(components)
      end

      # Return the Zenoss /Systems that this device belogs to in a string
      # separated by "sep".
      def get_system_names_string(sep=',')
        rest("getSystemNamesString?sep=#{sep}")
      end


      private

      def rest(method)
        @zenoss.rest(URI.encode("#{self.uid}/#{method}"))
      end

      def custom_rest(req_path, callback_func = nil, callback_attr=nil)
        @zenoss.custom_rest(self.uid, req_path, callback_func, callback_attr)
      end

    end # Device
  end # Model
end # Zenoss
