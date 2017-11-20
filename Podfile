source 'https://github.com/CocoaPods/Specs.git'

xcodeproj 'iSight2'

platform :ios, '9.0'

def install_pods
  pod "FastttCamera/Filters", :path => "./FastttCamera-master/FastttCamera.podspec"
  pod 'PebbleKit'
end

target 'iSight2', :exclusive => true do
  install_pods
end