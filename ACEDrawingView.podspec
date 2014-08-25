Pod::Spec.new do |s|
  s.name         = 'ACEDrawingView'
  s.version      = '1.3.1'
  s.license      = { :type => 'Apache 2.0 License', :file => 'LICENSE.txt' }
  s.summary      = 'An open source iOS component to create a drawing app.'
  s.homepage     = 'https://github.com/acerbetti/ACEDrawingView'
  s.author       = { 'Stefano Acerbetti' => 'acerbetti@gmail.com' }
  s.source       = { :git => 'https://github.com/alex-luca/ACEDrawingView.git'}
  s.platform     = :ios, '7.0'
  s.source_files = 'ACEDrawingView/*.{h,m}'
  s.requires_arc = true
end
