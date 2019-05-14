require 'aws-sdk'
module Fastlane
  module Actions
    # rubocop:disable Metrics/ClassLength
    class AwsDeviceFarmAction < Action
      def self.run(params)
        Actions.verify_gem!('aws-sdk')
        UI.message 'Preparing the upload to the device farm.'

        # Instantiate the client.
        @client = ::Aws::DeviceFarm::Client.new

        # Fetch the project
        project = fetch_project params[:name]
        raise "Project '#{params[:name]}' not be found on AWS - please go to 'Device Farm' and create a project named: 'fastlane', or set the 'name' parameter with your custom message." if project.nil?

        # Fetch the device pool.
        device_pool = fetch_device_pool project, params[:device_pool]
        raise "Device pool '#{params[:device_pool]}' not found. 🙈" if device_pool.nil?

        # Create the upload.
        path   = File.expand_path(params[:binary_path])
        type   = File.extname(path) == '.apk' ? 'ANDROID_APP' : 'IOS_APP'
        upload = create_project_upload project, path, type

        # Upload the application binary.
        UI.message 'Uploading the application binary. ☕️'
        upload upload, path

        # Upload the test package if needed.
        test_upload = nil
        if params[:test_binary_path]
          test_path = File.expand_path(params[:test_binary_path])
          if params[:test_package_type]
            test_upload = create_project_upload project, test_path, params[:test_package_type]
          else
            if type == "ANDROID_APP"
              test_upload = create_project_upload project, test_path, 'INSTRUMENTATION_TEST_PACKAGE'
            else
              test_upload = create_project_upload project, test_path, 'XCTEST_UI_TEST_PACKAGE'
            end
          end

          # Upload the test binary.
          UI.message 'Uploading the test binary. ☕️'
          upload test_upload, test_path

          # Wait for test upload to finish.
          UI.message 'Waiting for the test upload to succeed. ☕️'
          test_upload = wait_for_upload test_upload
          raise 'Test upload failed. 🙈' unless test_upload.status == 'SUCCEEDED'
        end

        # Wait for upload to finish.
        UI.message 'Waiting for the application upload to succeed. ☕️'
        upload = wait_for_upload upload
        raise 'Binary upload failed. 🙈' unless upload.status == 'SUCCEEDED'

        # Schedule the run.
        run = schedule_run params[:run_name], project, device_pool, upload, test_upload, type, params
        run_url = get_run_url_from_arn run.arn
        ENV["AWS_DEVICE_FARM_WEB_URL_OF_RUN"] = run_url
        UI.message "The Device Farm console URL for the run: #{run_url}" if params[:print_web_url_of_run] == true

        # Wait for run to finish.
        # rubocop:disable  Metrics/BlockNesting
        if params[:wait_for_completion]
          UI.message 'Waiting for the run to complete. ☕️'
          run = wait_for_run project, run
          if params[:allow_failed_tests] == false
            if params[:allow_device_errors] == true
              raise "#{run.message} Failed 🙈" unless %w[PASSED WARNED ERRORED].include? run.result
            else
              raise "#{run.message} Failed 🙈" unless %w[PASSED WARNED].include? run.result
            end
          end
          UI.message 'Successfully tested the application on the AWS device farm. ✅'.green
        else
          UI.message 'Successfully scheduled the tests on the AWS device farm. ✅'.green
        end

        run
      end
      # rubocop:enable  Metrics/BlockNesting
      #
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Upload the application to the AWS device farm.'
      end

      def self.details
        'Upload the application to the AWS device farm.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key:         :name,
            env_name:    'FL_AWS_DEVICE_FARM_NAME',
            description: 'Define the name of the device farm project',
            is_string:   true,
            default_value: 'fastlane',
            optional:    false
          ),
          FastlaneCore::ConfigItem.new(
            key:         :run_name,
            env_name:    'FL_AWS_DEVICE_FARM_RUN_NAME',
            description: 'Define the name of the device farm run',
            is_string:   true,
            optional:    true
          ),
          FastlaneCore::ConfigItem.new(
            key:         :binary_path,
            env_name:    'FL_AWS_DEVICE_FARM_PATH',
            description: 'Define the path of the application binary (apk or ipa) to upload to the device farm project',
            is_string:   true,
            optional:    false,
            verify_block: proc do |value|
              raise "Application binary not found at path '#{value}'. 🙈".red unless File.exist?(File.expand_path(value))
            end
          ),
          FastlaneCore::ConfigItem.new(
            key:         :test_binary_path,
            env_name:    'FL_AWS_DEVICE_FARM_TEST_PATH',
            description: 'Define the path of the test bundle to upload to the device farm project',
            is_string:   true,
            optional:    true,
            verify_block: proc do |value|
              raise "Test bundle not found at path '#{value}'. 🙈".red unless File.exist?(File.expand_path(value))
            end
          ),
          FastlaneCore::ConfigItem.new(
            key:         :test_package_type,
            env_name:    'FL_AWS_DEVICE_FARM_TEST_PACKAGE_TYPE',
            description: 'Define the type of the test binary to upload to the device farm project',
            is_string:   true,
            optional:    true,
            verify_block: proc do |value|
              valid_values = ['APPIUM_JAVA_JUNIT_TEST_PACKAGE',
                              'APPIUM_JAVA_TESTNG_TEST_PACKAGE',
                              'APPIUM_PYTHON_TEST_PACKAGE',
                              'APPIUM_WEB_JAVA_JUNIT_TEST_PACKAGE',
                              'APPIUM_WEB_JAVA_TESTNG_TEST_PACKAGE',
                              'APPIUM_WEB_PYTHON_TEST_PACKAGE',
                              'CALABASH_TEST_PACKAGE',
                              'INSTRUMENTATION_TEST_PACKAGE',
                              'UIAUTOMATION_TEST_PACKAGE',
                              'UIAUTOMATOR_TEST_PACKAGE',
                              'XCTEST_TEST_PACKAGE',
                              'XCTEST_UI_TEST_PACKAGE']
              raise "Test package type not found valid values are: '#{valid_values}'. 🙈".red unless valid_values.include? value
            end
          ),
          FastlaneCore::ConfigItem.new(
            key:         :test_type,
            env_name:    'FL_AWS_DEVICE_FARM_TEST_TYPE',
            description: 'Define the type of the test binary to upload to the device farm project',
            is_string:   true,
            optional:    true,
            verify_block: proc do |value|
              valid_values = ['UIAUTOMATOR',
                              'APPIUM_WEB_PYTHON',
                              'CALABASH',
                              'APPIUM_JAVA_TESTNG',
                              'UIAUTOMATION',
                              'BUILTIN_FUZZ',
                              'INSTRUMENTATION',
                              'APPIUM_JAVA_JUNIT',
                              'XCTEST_UI',
                              'APPIUM_WEB_JAVA_JUNIT',
                              'APPIUM_PYTHON',
                              'BUILTIN_EXPLORER',
                              'XCTEST',
                              'APPIUM_WEB_JAVA_TESTNG']
              raise "Test type not found valid values are: '#{valid_values}'. 🙈".red unless valid_values.include? value
            end
          ),
          FastlaneCore::ConfigItem.new(
            key:         :path,
            env_name:    'FL_AWS_DEVICE_FARM_PATH',
            description: 'Define the path of the application binary (apk or ipa) to upload to the device farm project',
            is_string:   true,
            optional:    false,
            verify_block: proc do |value|
              raise "Application binary not found at path '#{value}'. 🙈".red unless File.exist?(File.expand_path(value))
            end
          ),
          FastlaneCore::ConfigItem.new(
            key:         :device_pool,
            env_name:    'FL_AWS_DEVICE_FARM_POOL',
            description: 'Define the device pool you want to use for running the applications',
            default_value: 'IOS',
            is_string:   true,
            optional:    false
          ),
          FastlaneCore::ConfigItem.new(
            key:           :wait_for_completion,
            env_name:      'FL_AWS_DEVICE_FARM_WAIT_FOR_COMPLETION',
            description:   'Wait for the scheduled run to complete',
            is_string:     false,
            optional:      true,
            default_value: true
          ),
          FastlaneCore::ConfigItem.new(
            key:           :allow_device_errors,
            env_name:      'FL_AWS_DEVICE_FARM_ALLOW_ERROR',
            description:   'Do you want to allow device booting errors?',
            is_string:     false,
            optional:      true,
            default_value: false
          ),
          FastlaneCore::ConfigItem.new(
            key:           :allow_failed_tests,
            env_name:      'FL_AWS_DEVICE_FARM_ALLOW_FAILED_TESTS',
            description:   'Do you want to allow failing tests?',
            is_string:     false,
            optional:      true,
            default_value: false
          ),
          FastlaneCore::ConfigItem.new(
            key:           :filter,
            env_name:      'FL_AWS_DEVICE_FARM_FILTER',
            description:   'Define a filter for your test run and only run the tests in the filter',
            is_string:     true,
            optional:      true,
            default_value: ''
          ),
          FastlaneCore::ConfigItem.new(
            key:           :billing_method,
            env_name:      'FL_AWS_DEVICE_FARM_BILLING_METHOD',
            description:   'Specify the billing method for the run',
            is_string:     true,
            optional:      true,
            default_value: 'METERED' # accepts METERED, UNMETERED
          ),
          FastlaneCore::ConfigItem.new(
            key:           :locale,
            env_name:      'FL_AWS_DEVICE_FARM_LOCALE',
            description:   'Specify the locale for the run',
            is_string:     true,
            optional:      true,
            default_value: 'en_US'
          ),
          FastlaneCore::ConfigItem.new(
            key:         :test_spec,
            env_name:    'FL_AWS_TEST_SPEC',
            description: 'Define the device farm custom TestSpec ARN to use (can be obtained using the AWS CLI `devicefarm list-uploads` command)',
            is_string:   true,
            optional:    true
          ),
          FastlaneCore::ConfigItem.new(
            key:         :print_web_url_of_run,
            env_name:    'FL_AWS_DEVICE_FARM_WEB_URL_OF_RUN',
            description: 'Print the web url of the test run to or not',
            is_string:   false,
            optional:    true,
            default_value: false
          )
        ]
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ["fousa/fousa", "hjanuschka", "cmarchal"]
      end

      def self.is_supported?(platform)
        platform == :ios || platform == :android
      end

      POLLING_INTERVAL = 10

      def self.fetch_project(name)
        projects = @client.list_projects.projects
        projects.detect { |p| p.name == name }
      end

      def self.create_project_upload(project, path, type)
        @client.create_upload({
          project_arn:  project.arn,
          name:         File.basename(path),
          content_type: 'application/octet-stream',
          type:         type
        }).upload
      end

      def self.upload(upload, path)
        url = URI.parse(upload.url)
        contents = File.open(path, 'rb').read
        Net::HTTP.new(url.host).start do |http|
          http.send_request("PUT", url.request_uri, contents, { 'content-type' => 'application/octet-stream' })
        end
      end

      def self.fetch_upload_status(upload)
        @client.get_upload({
          arn:  upload.arn
        }).upload
      end

      def self.wait_for_upload(upload)
        upload = fetch_upload_status upload
        while upload.status == 'PROCESSING' || upload.status == 'INITIALIZED'
          sleep POLLING_INTERVAL
          upload = fetch_upload_status upload
        end

        upload
      end

      def self.fetch_device_pool(project, device_pool)
        device_pools = @client.list_device_pools({
          arn: project.arn
        })
        device_pools.device_pools.detect { |p| p.name == device_pool }
      end

      def self.schedule_run(name, project, device_pool, upload, test_upload, type, params)
        # Prepare the test hash depening if you passed the test apk.
        test_hash = { type: 'BUILTIN_FUZZ' }
        if test_upload
          if params[:test_type]
            test_hash[:type] = params[:test_type]
          else
            test_hash[:type] = 'XCTEST_UI'
            if type == "ANDROID_APP"
              test_hash[:type] = 'INSTRUMENTATION'
            end
          end

          if params[:test_spec]
              test_hash[:test_spec_arn] = params[:test_spec]
          else
              test_hash[:filter] = params[:filter]
          end

          test_hash[:test_package_arn] = test_upload.arn
        end

        configuration_hash = {
          billing_method: params[:billing_method],
          locale: params[:locale]
        }

        @client.schedule_run({
          name:            name,
          project_arn:     project.arn,
          app_arn:         upload.arn,
          device_pool_arn: device_pool.arn,
          test:            test_hash,
          configuration:   configuration_hash
        }).run
      end

      def self.fetch_run_status(run)
        @client.get_run({
          arn:  run.arn
        }).run
      end

      def self.wait_for_run(project, run)
        while run.status != 'COMPLETED'
          sleep POLLING_INTERVAL
          print '.'
          run = fetch_run_status run
        end
        UI.message "The run ended with result #{run.result}."
        UI.important "Minutes Counted: #{run.device_minutes.total}"

        UI.verbose "RUN ARN: #{run.arn}."
        ENV["AWS_DEVICE_FARM_RUN_ARN"] = run.arn
        UI.verbose "PROJECT ARN: #{project.arn}."
        ENV["AWS_DEVICE_FARM_PROJECT_ARN"] = project.arn

        job = @client.list_jobs({
            arn: run.arn
        })

        rows = []
        job.jobs.each do |j|
          if j.result == "PASSED"
            status = "💚 (#{j.result})"
          elsif j.result == "ERRORED"
            status = "📵 (#{j.result})"
          else
            status = "💥 (#{j.result})"
          end
          rows << [status, j.name, j.device.form_factor, j.device.platform, j.device.os]
        end
        puts ""
        puts Terminal::Table.new(
          title: "Device Farm Summary".green,
          headings: ["Status", "Name", "Form Factor", "Platform", "Version"],
          rows: rows
        )
        puts ""

        run
      end
      def self.get_run_url_from_arn(arn)
        project_id = get_project_id_from_arn arn
        run_id = get_run_id_from_arn arn
        region_id = get_region_from_arn arn
        "https://#{region_id}.console.aws.amazon.com/devicefarm/home?region=#{region_id}#/projects/#{project_id}/runs/#{run_id}"
      end
      def self.get_project_id_from_arn(arn)
        project_run_id = split_run_arn arn
        project_run_id[0]
      end
      def self.get_run_id_from_arn(arn)
        project_run_id = split_run_arn arn
        project_run_id[1]
      end
      def self.get_region_from_arn(arn)
        arn.split(':')[3]
      end
      def self.split_run_arn(arn)
        arn.split(':')[6].split('/')
      end
    end
  end
end
