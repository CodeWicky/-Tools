Pod::Spec.new do |s|
s.name = 'DWPlayer'
s.version = '0.0.0.2'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = '基于AVFoundation的视频播放组件。Component to play video based on AVFoundation.'
s.homepage = 'https://github.com/CodeWicky/-Tools/tree/master/DWPlayer'
s.authors = { 'codeWicky' => 'codewicky@163.com' }
s.source = { :git => 'https://github.com/CodeWicky/-Tools.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '9.1'
s.source_files = 'DWPlayer/**/*.{h,m}'
s.frameworks = 'UIKit'

end
