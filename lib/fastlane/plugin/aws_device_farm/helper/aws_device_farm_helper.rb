require 'rexml/document'
require 'fileutils'

module Fastlane
  module Helper
    class AwsDeviceFarmHelper

      # create Junit.xml
      def self.create_junit_xml(test_results:, file_path:)
        doc = REXML::Document.new
        doc << REXML::XMLDecl.new('1.0', 'UTF-8')

        # test_suites
        root = REXML::Element.new('testsuites')
        root.add_attribute('name', "#{test_results['name']}")
        root.add_attribute('tests', "#{test_results['tests']}")
        root.add_attribute('failures', "#{test_results['failures']}")
        root.add_attribute('time', "#{test_results['time']}")
        doc.add_element(root)

        test_results['test_suites'].each do |suite|
          testsuite = REXML::Element.new('testsuite')
          testsuite.add_attribute('name', "#{suite['name']}")
          testsuite.add_attribute('tests', "#{suite['tests']}")
          testsuite.add_attribute('errors', "#{suite['errors']}")
          testsuite.add_attribute('failures', "#{suite['failures']}")
          testsuite.add_attribute('time', "#{suite['time']}")
          root.add_element(testsuite)

          suite['test_lists'].each do |test|
            testcase = REXML::Element.new('testcase')
            testcase.add_attribute('classname', "#{test['class_name']}")
            testcase.add_attribute('name', "#{test['name']}")
            testcase.add_attribute('time', "#{test['time']}")
            testsuite.add_element(testcase)
          end
        end

        # output
        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, 'w') do |file|
          doc.write(file, indent=2)
        end
      end

    end
  end
end
