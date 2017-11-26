source 'https://github.com/CocoaPods/Specs.git'

xcodeproj 'DigitalGlasses'

platform :ios, '9.0'

def install_pods
  pod "FastttCamera/Filters", :path => "./FastttCamera-master/FastttCamera.podspec"
  pod 'PebbleKit'
  pod 'Flurry-iOS-SDK/FlurrySDK' #Analytics Pod
end

target 'DigitalGlasses', :exclusive => true do
  install_pods
end
