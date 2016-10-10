module Fastlane
  module Helper
    class AwsDeviceFarmHelper
      # class methods that you define here become available in your action
      # as `Helper::AwsDeviceFarmHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the aws_device_farm plugin helper!")
      end
    end
  end
end
