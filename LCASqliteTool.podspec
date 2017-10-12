#
# Be sure to run `pod lib lint LCASqliteTool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LCASqliteTool'
  s.version          = '1.1.3'
  s.summary          = '对sqlite增删改查的封装'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 对sqlite的简单封装，简化对sqlite的操作
                       DESC

  s.homepage         = 'hhttps://github.com/changanli/LCASqliteTool'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '931985308@qq.com' => 'lichangan' }
  s.source           = { :git => 'https://github.com/changanli/LCASqliteTool.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LCASqliteTool/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LCASqliteTool' => ['LCASqliteTool/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
