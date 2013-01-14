/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2013 Stefano Acerbetti
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

#import "ACEDrawingView.h"
#import <QuartzCore/QuartzCore.h>

#if __has_feature(objc_arc)
#define ACE_HAS_ARC 1
#define ACE_RETAIN(exp) (exp)
#define ACE_RELEASE(exp)
#define ACE_AUTORELEASE(exp) (exp)
#else
#define ACE_HAS_ARC 0
#define ACE_RETAIN(exp) [(exp) retain]
#define ACE_RELEASE(exp) [(exp) release]
#define ACE_AUTORELEASE(exp) [(exp) autorelease]
#endif


#define kDefaultLineColor       [UIColor blackColor]
#define kDefaultLineWidth       10.0f;
#define kDefaultLineAlpha       1.0f


@interface UIColoredBezierPath : UIBezierPath
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineAlpha;
@end

#pragma mark -

@implementation UIColoredBezierPath

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (void)addQuadCurveToPoint:(CGPoint)endPoint fromPoint:(CGPoint)startPoint
{
    [self addQuadCurveToPoint:midPoint(endPoint, startPoint) controlPoint:startPoint];
}

#if !ACE_HAS_ARC

- (void)dealloc
{
    self.lineColor = nil;
    [super dealloc];
}

#endif

@end

#pragma mark -

@interface ACEDrawingView ()
@property (nonatomic, strong) NSMutableArray *pathArray;
@property (nonatomic, strong) NSMutableArray *bufferArray;
@property (nonatomic, strong) UIColoredBezierPath *bezierPath;
@property (nonatomic, strong) UIImage *image;
@end

#pragma mark -

@implementation ACEDrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure
{
    // init the private arrays
    self.pathArray = [NSMutableArray array];
    self.bufferArray = [NSMutableArray array];
    
    // set the default values for the public properties
    self.lineColor = kDefaultLineColor;
    self.lineWidth = kDefaultLineWidth;
    self.lineAlpha = kDefaultLineAlpha;
    
    // set the transparent background
    self.backgroundColor = [UIColor clearColor];
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [self.image drawInRect:rect];
    [self drawPath];
}

- (void)drawPath
{
    // draw the latest line
    UIColoredBezierPath *path = [self.pathArray lastObject];
    [path.lineColor setStroke];
    [path strokeWithBlendMode:kCGBlendModeNormal alpha:path.lineAlpha];
}

- (void)cacheImage
{
    // init a context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    
    // add the new line
    [self.image drawAtPoint:CGPointZero];
    
    if (self.image == nil) {
        // I need to redraw all the lines
        for (UIColoredBezierPath *path in self.pathArray) {
            [path.lineColor setStroke];
            [path strokeWithBlendMode:kCGBlendModeNormal alpha:path.lineAlpha];
        }
        
    } else {
        // just draw the latest line
        [self drawPath];
    }
    
    // store the image
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)setNeedsDisplay
{
    [self cacheImage];
    [super setNeedsDisplay];
}


#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // init the bezier path
    self.bezierPath = ACE_AUTORELEASE([UIColoredBezierPath new]);
    self.bezierPath.lineCapStyle = kCGLineCapRound;
    self.bezierPath.lineWidth = self.lineWidth;
    self.bezierPath.lineColor = self.lineColor;
    self.bezierPath.lineAlpha = self.lineAlpha;
    [self.pathArray addObject:self.bezierPath];
    
    // add the first touch
    UITouch *touch = [touches anyObject];
    [self.bezierPath moveToPoint:[touch locationInView:self]];
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:willBeginDrawBezierPath:)]) {
        [self.delegate drawingView:self willBeginDrawBezierPath:self.bezierPath];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // save all the touches in the path
    UITouch *touch = [touches anyObject];
    
    // add the current point to the path
    [self.bezierPath addQuadCurveToPoint:[touch locationInView:self] fromPoint:[touch previousLocationInView:self]];
    
    // update the view
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesMoved:touches withEvent:event];
    
    // clear the redo queue
    [self.bufferArray removeAllObjects];
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:didEndDrawBezierPath:)]) {
        [self.delegate drawingView:self didEndDrawBezierPath:self.bezierPath];
    }
}


#pragma mark - Actions

- (void)clear
{
    [self.bufferArray removeAllObjects];
    [self.pathArray removeAllObjects];
    self.image = nil;
    [self setNeedsDisplay];
}


#pragma mark - Undo / Redo

- (NSUInteger)undoSteps
{
    return self.bufferArray.count;
}

- (BOOL)canUndo
{
    return self.pathArray.count > 0;
}

- (void)undoLatestStep
{
    if ([self canUndo]) {
        UIColoredBezierPath *path = [self.pathArray lastObject];
        [self.bufferArray addObject:path];
        [self.pathArray removeLastObject];
        self.image = nil;
        [self setNeedsDisplay];
    }
}

- (BOOL)canRedo
{
    return self.bufferArray.count > 0;
}

- (void)redoLatestStep
{
    if ([self canRedo]) {
        UIColoredBezierPath *path = [self.bufferArray lastObject];
        [self.pathArray addObject:path];
        [self.bufferArray removeLastObject];
        self.image = nil;
        [self setNeedsDisplay];
    }
}

#if !ACE_HAS_ARC

- (void)dealloc
{
    self.pathArray = nil;
    self.bufferArray = nil;
    self.bezierPath = nil;
    self.image = nil;
    [super dealloc];
}

#endif

@end
