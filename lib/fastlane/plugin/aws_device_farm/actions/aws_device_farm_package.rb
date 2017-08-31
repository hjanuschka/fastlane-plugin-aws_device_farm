module Fastlane
  module Actions
    class AwsDeviceFarmPackageAction < Action
      def self.run(params)
        derrived_data_dir = File.expand_path(params[:derrived_data_path])
        packages_dir = "#{derrived_data_dir}/packages"
        FileUtils.rm_rf packages_dir
        Dir["#{derrived_data_dir}/Build/Products/#{params[:configuration]}-iphoneos/*.app"].each do |app|
          if app.include? 'Runner'

            FileUtils.mkdir_p "#{packages_dir}/runner/Payload"
            FileUtils.cp_r app, "#{packages_dir}/runner/Payload"
            Actions.sh "cd #{packages_dir}/runner/; zip --recurse-paths -D --quiet #{packages_dir}/runner.ipa .;"

            ENV['FL_AWS_DEVICE_FARM_TEST_PATH'] = "#{packages_dir}/runner.ipa"
          else

            FileUtils.mkdir_p "#{packages_dir}/app/Payload"
            FileUtils.cp_r app, "#{packages_dir}/app/Payload"
            Actions.sh "cd #{packages_dir}/app/; zip --recurse-paths -D --quiet #{packages_dir}/app.ipa .;"

            ENV['FL_AWS_DEVICE_FARM_PATH'] = "#{packages_dir}/app.ipa"

          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Packages .app from deriveddata to an aws-compatible ipa'
      end

      def self.details
        'Packages .app to .ipa'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key:         :derrived_data_path,
            env_name:    'FL_AWS_DEVICE_FARM_DERIVED_DATA',
            description: 'Derrived Data Path',
            is_string:   true,
            optional:    false
          ),
          FastlaneCore::ConfigItem.new(
            key:         :configuration,
            env_name:    'FL_AWS_DEVICE_FARM_CONFIGURATION',
            description: 'Configuration',
            is_string:   true,
            optional:    true,
            default_value: "Development"
          )
        ]
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.is_supported?(platform)
        platform == :ios || platform == :android
      end
    end
  end
end
