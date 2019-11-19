# AWS Device Farm Plugin for Fastlane

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-aws_device_farm)


## About
> This Plugin allows tests run on AWS device Farm


| iOS | Android | Fail |
|----------|-------------|-------------|
| ![Screenshot](assets/screen_done.png) |  ![Screenshot](assets/screen_don_android.png)| ![Screenshot](assets/fail.png) |




## Setup
### Add Plugin
```
fastlane add_plugin aws_device_farm
```

### Create Device Pools
Open your AWS dashboard and under `AWS-Device Farm` - configure your Device Pools.
Select the devices you want to run the tests on.


### Create a project on AWS
in this example we called this `fastlane`

## Example iOS

```ruby
lane :aws_device_run_ios do
  ENV['AWS_ACCESS_KEY_ID']     = 'xxxxx'
  ENV['AWS_SECRET_ACCESS_KEY'] = 'xxxxx'
  ENV['AWS_REGION']            = 'us-west-2'
  #Build For Testing
  xcodebuild(
    scheme: 'UITests',
    destination: 'generic/platform=iOS',
    configuration: 'Release',
    derivedDataPath: 'aws',
    xcargs: "GCC_PREPROCESSOR_DEFINITIONS='AWS_UI_TEST' ENABLE_BITCODE=NO CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO build-for-testing"
  )
  # Transform .app into AWS compatible IPA
  aws_device_farm_package(
    derrived_data_path: "aws",
    configuration: "Release"
  )
  # RUN tests on AWS Device Farm
  aws_device_farm
end
```


## Example Android

```ruby
lane :aws_device_run_android do
  ENV['AWS_ACCESS_KEY_ID']     = 'xxxxx'
  ENV['AWS_SECRET_ACCESS_KEY'] = 'xxxxx'
  ENV['AWS_REGION']            = 'us-west-2'

  #Build Debug App + Instrumentation Apk
  gradle(task: 'assembleDebug')
  gradle(task: 'assembleAndroidTest')

  # RUN tests on AWS Device Farm
  aws_device_farm(
    binary_path:         'app/build/outputs/apk/app-debug.apk',
    test_binary_path:    'app/build/outputs/apk/app-debug-androidTest-unaligned.apk'
  )
end
```

The plugin also exposes two ENV variables in case you want to make additional calls after the action is finished.
`ENV["AWS_DEVICE_FARM_RUN_ARN"] containing the arn of the run` \
`ENV["AWS_DEVICE_FARM_PROJECT_ARN"] containing the arn of the project` \
`ENV["AWS_DEVICE_FARM_WEB_URL_OF_RUN"] containg the web url of the run`


## Options

 * **aws_device_farm**

|  Option |  Default  |  Description |  Type |
|---|---|---|---|
|  name |  fastlane  |  AWS Device Farm Project Name |  String |
|  binary_path |    |  Path to App Binary |  String |
|  test_binary_path |    |  Path to test bundle |  String |
|  test_package_type |    |  Type of test package |  String |
|  test_type |    |  Type of test |  String |
|  device_pool | IOS | AWS Device Farm Device Pool | String |
|  wait_for_completion | true | Wait for Test-Run to be completed | Boolean |
|  allow_device_errors | false | Do you want to allow device booting errors? | Boolean |
|  allow_failed_tests | false | Do you want to allow failing tests? | Boolean |
|  test_spec |    | Define the device farm custom TestSpec ARN to use (can be obtained using the AWS CLI `devicefarm list-uploads` command) | String |
|  filter |    | Define a filter for your test run and only run the tests in the filter (note that using `test_spec` overrides the `filter` option) | String |
|  print_web_url_of_run  | false | Do you want to print the web url of run in the messages? | Boolean |

Possible types see: http://docs.aws.amazon.com/sdkforruby/api/Aws/DeviceFarm/Client.html#create_upload-instance_method

* **aws_device_farm_package**

|  Option |  Default  |  Description |  Type |
|---|---|---|---|
|  derrived_data_path |    |  Derrived Data Path, containing a `build-for-testing` derrived-data folder |  String |
|  derrived_data_path |  Development   |  Specify the Build-Configuration that was used e.g.: Development |  String |


## Credit
it is based on a custom action by @icapps (https://github.com/icapps/fastlane-configuration)
added the following:
  * iOS Support for XCUITests
  * support current `fastlane` version
  * improve output
  * make it available as a `fastlane` plugin


## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.


## About `fastlane`

`fastlane` is the easiest way to automate building and releasing your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
