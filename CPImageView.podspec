#
#  Be sure to run `pod spec lint CPImageView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "CPImageView"
  s.version      = "0.1.0"
  s.summary      = "A small, lightweight subclass of `UIImageView` which supports async loading from URLs."
  s.description  = "A small, lightweight subclass of `UIImageView` which supports async loading from URLs and caching both in memory and storage."
  s.homepage     = "https://github.com/canpoyrazoglu/CPImageView"


  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  s.author             = { "Can Poyrazoğlu" => "can@canpoyrazoglu.com" }
  s.social_media_url   = "http://twitter.com/canpoyrazoglu"



  s.platform     = :ios, "8.0"


  s.source       = { :git => "https://github.com/canpoyrazoglu/CPImageView.git", :tag => 'v0.1.0' }


  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"



end
