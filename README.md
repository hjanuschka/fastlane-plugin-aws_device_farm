# AWS Device Farm Plugin for Fastlane

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-sharethemeal)


## About
> This Plugin Allows XCUITests and android Instrumentation tests run on AWS device Farm





## Setup
### Add Plugin
```
fastlane add_plugin aws_device_farm
```

### Get your UserHash
In Order to automate donation you require to store your payment method (preffered PayPal)
So do a single donation, on iOS this opens a Safari instance, look at the url and extract your `userHash`

Download The App to your Mobile.

| Platform | Link |
|----------|:-------------:|
| IOS |  [AppStore](https://click.google-analytics.com/redirect?tid=UA-58737077-1&url=https%3A%2F%2Fitunes.apple.com%2Fus%2Fapp%2Fsharethemeal%2Fid977130010&aid=org.sharethemeal.app&idfa=%{idfa}&cs=stmwebsite&cm=website&cn=permanent) |
| ANDROID |    [PlayStore](https://play.google.com/store/apps/details?id=org.sharethemeal.app&referrer=utm_source%3Dstmwebsite%26utm_medium%3Dwebsite%26utm_campaign%3Dpermanent)    |

**Donate Once**, in the Safari instance that opens - you'll find your `userHash` - this is required to automate the donation.

## Example

```ruby
lane :donate do
  sharethemeal(
    amount: "0.4",
    userhash: "XXX",
    currency: "EUR",
    team_id: "fastlane"
  )
end
```


## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

## About `fastlane`

`fastlane` is the easiest way to automate building and releasing your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
