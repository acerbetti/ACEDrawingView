/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2018 Stefano Acerbetti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <Foundation/Foundation.h>

// default drawable tools
extern NSString * _Nonnull const kACEDrawingToolViewArrow;
extern NSString * _Nonnull const kACEDrawingToolViewEllipse;
extern NSString * _Nonnull const kACEDrawingToolViewEraser;
extern NSString * _Nonnull const kACEDrawingToolViewLine;
extern NSString * _Nonnull const kACEDrawingToolViewPen;
extern NSString * _Nonnull const kACEDrawingToolViewRectangle;

@protocol ACEDrawingViewTool<NSObject, NSCoding>

+ (nonnull NSString *)identifier;

- (void)setInitialPoint:(CGPoint)firstPoint;
- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
- (void)draw;

@end

#pragma mark -

@protocol ACEDrawingViewDrawableTool<ACEDrawingViewTool>

- (void)setColor:(nonnull UIColor *)color;

- (void)setAlpha:(CGFloat)alpha;

- (void)setLineWidth:(CGFloat)lineWidth;

@end

#pragma mark -

@protocol ACEDrawingViewDraggableTool<ACEDrawingViewTool>

@end

#pragma mark -

@interface ACEDrawingViewTools : NSObject

+ (void)registerToolClass:(nonnull Class<ACEDrawingViewTool>)toolClass;

+ (nullable id<ACEDrawingViewTool>)toolWithIdentifier:(nonnull NSString *)identifier;

@end
