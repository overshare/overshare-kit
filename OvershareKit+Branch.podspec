Pod::Spec.new do |s|
  s.name         = "OvershareKit+Branch"
  s.version      = "1.3.2"
  s.summary      = "A soup-to-nuts sharing library for iOS, with a little extra zest from Branch."
  s.homepage     = "https://github.com/BranchMetrics/overshare-kit"
  s.license      = { :type => 'MIT', :file => 'LICENSE'  }
  s.author       = { "Scott Hasbrouck" => "scott@branch.io" }
  s.source       = { :git => "https://github.com/BranchMetrics/overshare-kit.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.frameworks   = 'UIKit', 'AddressBook', 'CoreMotion', 'CoreLocation', 'MediaPlayer'
  
  s.compiler_flags = "-fmodules"
  
  s.ios.deployment_target = '7.0'
  
  s.source_files = ['Overshare Kit/*.{h,m}']
  s.resources    = ['Overshare Kit/Images/*', 'Overshare Kit/*.xib', 'Dependencies/GooglePlus-SDK/GooglePlus.bundle']

  s.ios.vendored_frameworks = 'Dependencies/GooglePlus-SDK/GooglePlus.framework', 'Dependencies/GooglePlus-SDK/GoogleOpenSource.framework'
  
  s.dependency 'ADNLogin'
  s.dependency 'PocketAPI'
  s.dependency 'Branch'
end
