# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Gimhae' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Gimhae

  # Architecture & Reactive
  pod 'CoreEngine'
  pod 'CombineCocoa'

  # UI
  pod 'SnapKit'
  pod 'AddThen'
  pod 'BetterSegmentedControl', '~> 2.0'
  pod 'Cards', :git => 'https://github.com/sobabear/Cards.git', :commit => 'f9f0d3a929df075cc911151291ca33967853f7f5'
  pod 'FSPagerView'
  pod 'SkeletonView'

  # Maps
  pod 'NMapsMap'

  # Networking & Images
  pod 'Kingfisher'

  # Firebase
  pod 'FirebaseAnalytics'
  pod 'CodableFirebase'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  end
end
