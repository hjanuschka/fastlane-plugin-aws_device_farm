module Fastlane
  module Actions
    class AwsDeviceFarmPackageAction < Action
      def self.run(params)
        FileUtils.rm_rf "#{File.expand_path(params[:derrived_data_path])}/packages"
        Dir["#{File.expand_path(params[:derrived_data_path])}/Build/Products/Development-iphoneos/*.app"].each do |app|
          if app.include? 'Runner'

            FileUtils.mkdir_p "#{File.expand_path(params[:derrived_data_path])}/packages/runner/Payload"
            FileUtils.cp_r app, "#{File.expand_path(params[:derrived_data_path])}/packages/runner/Payload"
            Actions.sh "cd #{File.expand_path(params[:derrived_data_path])}/packages/runner/; zip --recurse-paths -D --quiet #{File.expand_path(params[:derrived_data_path])}/packages/runner.ipa .;"

            ENV['FL_AWS_DEVICE_FARM_TEST_PATH'] = "#{File.expand_path(params[:derrived_data_path])}/packages/runner.ipa"
          else

            FileUtils.mkdir_p "#{File.expand_path(params[:derrived_data_path])}/packages/app/Payload"
            FileUtils.cp_r app, "#{File.expand_path(params[:derrived_data_path])}/packages/app/Payload"
            Actions.sh "cd  #{File.expand_path(params[:derrived_data_path])}/packages/app/; zip --recurse-paths -D --quiet #{File.expand_path(params[:derrived_data_path])}/packages/app.ipa .;"

            ENV['FL_AWS_DEVICE_FARM_PATH'] = "#{File.expand_path(params[:derrived_data_path])}/packages/app.ipa"

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
