Pod::Spec.new do |s|
s.name = 'DWNavigationTransition'
s.version = '0.0.0.1'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = '导航栏平滑处理。Help you handle navigationBar.'
s.homepage = 'https://github.com/CodeWicky/-Tools/tree/master/DWNavigationTransition'
s.authors = { 'codeWicky' => 'codewicky@163.com' }
s.source = { :git => 'https://github.com/CodeWicky/-Tools.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '9.1'
s.source_files = 'DWNavigationTransition/**/*.{h,m}'
s.frameworks = 'UIKit'

end
