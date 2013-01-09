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
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) CGPoint previousPoint;
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

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (void)drawRect:(CGRect)rect
{
    for (UIColoredBezierPath *path in self.pathArray)
    {
        [path.lineColor setStroke];
        [path strokeWithBlendMode:kCGBlendModeNormal alpha:path.lineAlpha];
    }
}


#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // init the bezier path
    self.bezierPath = [UIColoredBezierPath new];
    self.bezierPath.lineCapStyle = kCGLineCapRound;
    self.bezierPath.lineWidth = self.lineWidth;
    self.bezierPath.lineColor = self.lineColor;
    self.bezierPath.lineAlpha = self.lineAlpha;
    [self.pathArray addObject:self.bezierPath];
    ACE_RELEASE(self.bezierPath);
    
    // add the first touch
    UITouch *touch = [touches anyObject];
    self.currentPoint = self.previousPoint = [touch locationInView:self];
    [self.bezierPath moveToPoint:self.currentPoint];
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:willBeginDrawFreeformAtPoint:)]) {
        [self.delegate drawingView:self willBeginDrawFreeformAtPoint:self.currentPoint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // save all the touches in the path
    UITouch *touch = [touches anyObject];
    
    // swith the point data
    self.previousPoint = self.currentPoint;
    self.currentPoint = [touch locationInView:self];
    
    // add the current point to the path
    [self.bezierPath addQuadCurveToPoint:midPoint(self.currentPoint, self.previousPoint) controlPoint:self.previousPoint];
    
    // update the view
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // clear the redo queue
    [self.bufferArray removeAllObjects];
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:didEndDrawFreeformAtPoint:)]) {
        [self.delegate drawingView:self didEndDrawFreeformAtPoint:self.currentPoint];
    }
}


#pragma mark - Actions

- (void)clear
{
    [self.bufferArray removeAllObjects];
    [self.pathArray removeAllObjects];
    [self setNeedsDisplay];
}

- (UIImage *)image
{
    // create a snapshot
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // return the image
    return image;
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
        [self setNeedsDisplay];
    }
}

#if !ACE_HAS_ARC

- (void)dealloc
{
    self.pathArray = nil;
    self.bufferArray = nil;
    self.bezierPath = nil;
    [super dealloc];
}

#endif

@end
