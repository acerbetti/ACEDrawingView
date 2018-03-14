Pod::Spec.new do |s|
  s.name                = 'ACEDrawingView'
  s.version             = '3.0.0'
  s.license             = { :type => 'Apache 2.0 License', :file => 'LICENSE.txt' }
  s.summary             = 'An open source iOS component to create a drawing app.'
  s.homepage            = 'https://github.com/acerbetti/ACEDrawingView'
  s.author              = { 'Stefano Acerbetti' => 'acerbetti@gmail.com' }
  s.source              = { :git => 'https://github.com/acerbetti/ACEDrawingView.git', :tag => s.version }
  s.frameworks          = 'QuartzCore'
  s.default_subspec     = 'DrawingView'
  s.platform            = :ios, '8.0'
  s.requires_arc        = true
  
  s.subspec 'DrawingView' do |ss|
      ss.source_files = "ACEDrawingView/**/*.{h,m}"
      ss.private_header_files = "ACEDrawingView/DrawableTools/*.h"
  end
  
  s.subspec 'DraggableText' do |ss|
      ss.dependency s.name + '/DrawingView'
      
      ss.source_files = "ACEDraggableText/**/*.{h,m}"
      ss.resource_bundles = {
          'ACEDraggableText' => ["ACEDraggableText/**/*.png"],
      }
  end
end
