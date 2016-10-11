ACEDrawingView [![Build Status](https://travis-ci.org/acerbetti/ACEDrawingView.svg?branch=master)](https://travis-ci.org/acerbetti/ACEDrawingView) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ACEDrawingView.svg)](http://cocoadocs.org/docsets/ACEDrawingView) [![Platform](https://img.shields.io/cocoapods/p/ACEDrawingView.svg?style=flat)](http://cocoadocs.org/docsets/ACEDrawingView)
==============

![](https://github.com/acerbetti/ACEDrawingView/blob/master/Example.png?raw=true)      ![](https://github.com/deviserRahul/ACEDrawingView/blob/master/Example2.png?raw=true)

Purpose
--------------
ACEDrawingView is a sample project showing exactly how to create a nice and smooth drawing application. In a few lines of code it supports drawing with different colors and line width. 
It also includes a full undo/redo stack and it can export the view as an UIImage.


How-To
------------------
- Import the files from the folder "ACEDrawingView" to your project
- From IB create a view and set the class to "ACEDrawingView"
- Programmatically use the initWithFrame: and add it as subview

### CocoaPods(Recommended)

1. Add `pod 'ACEDrawingView'` to your Podfile.
2. Run `pod install`


Features
------------------
- Undo / Redo stack
- Multiple color lines
- Multiple width lines
- Multiple alpha values
- Draw on image
- Create screenshot of your masterpiece
- Support for multiple tools (pen, line, rectangle, ellipse)
- Eraser tool


ARC Compatibility
------------------
This component can be used in projects using ARC or not


Change Log
------------------
09/21/2016 - v2.0
- Added advanced draggable text tool
- Removed legacy text tools

05/20/2014 - v1.3
- Enhancements to text tool workflow
- Fixed undo/redo with text tool

05/06/2014 - v1.2
- Added text tool #16

06/09/2013 - v1.1
- Added eraser tool #3


06/05/2013 - v1.0.1
- Performance improvements (thanks to [ozzie](https://github.com/oziee))


01/15/2012 - v1.0
- Draw with multiple tools (pen, line, rectangle, ellipse)


01/13/2012 - v0.2
- Performance improvements (use an image to cache the drawing)


01/06/2013 - v0.1
- Initial release


License
------------------
Copyright (c) 2016 Stefano Acerbetti

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
