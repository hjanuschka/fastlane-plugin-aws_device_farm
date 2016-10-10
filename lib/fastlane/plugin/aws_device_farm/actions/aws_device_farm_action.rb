module Fastlane
  module Actions
    class AwsDeviceFarmAction < Action
      def self.run(params)
        UI.message("The aws_device_farm plugin is working!")
      end

      def self.description
        "Run UI Tests on AWS Devicefarm"
      end

      def self.authors
        ["Helmut Januschka"]
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "AWS_DEVICE_FARM_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
