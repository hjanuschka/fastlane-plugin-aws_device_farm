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
          ),
          FastlaneCore::ConfigItem.new(
            key:         :is_unit_test,
            env_name:    'FL_AWS_DEVICE_FARM_IS_UNIT_TEST',
            description: 'Specify is_unit_test to true if this is an iOS unit test',
            is_string:   false,
            optional:    true,
            default_value: false,
            verify_block: proc do |value|
              UI.user_error!("Please pass a valid value for is_unit_test. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
            end
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
