source 'https://github.com/CocoaPods/Specs.git'

xcodeproj 'iSight2'

platform :ios, '9.0'

def install_pods
  pod "FastttCamera/Filters", :path => "./submodules/FastttCamera/FastttCamera.podspec"
  pod 'PebbleKit'
  pod 'Flurry-iOS-SDK/FlurrySDK' #Analytics Pod
end

target 'iSight2' do
  install_pods
end
