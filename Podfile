source 'https://github.com/CocoaPods/Specs.git'

project 'iSight2'

platform :ios, '9.0'

def install_pods
  pod "FastttCamera/Filters", :path => "./submodules/FastttCamera/FastttCamera.podspec"
  pod 'Flurry-iOS-SDK/FlurrySDK', '7.8.2' #Analytics Pod
end

target 'iSight2' do
  install_pods
end

target 'WatchControl' do
    
end

target 'WatchControl Extension' do
    pod 'Flurry-iOS-SDK/FlurryWatchOSSDK', '7.8.2' #Because of linking error in 8.3.2
    platform :watchos, '2.2'
end

