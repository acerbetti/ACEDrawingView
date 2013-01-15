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

#import "ACEDrawingTools.h"

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

#pragma mark - ACEDrawingPenTool

@implementation ACEDrawingPenTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.lineCapStyle = kCGLineCapRound;
    }
    return self;
}

- (void)setInitialPoint:(CGPoint)firstPoint
{
    [self moveToPoint:firstPoint];
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    [self addQuadCurveToPoint:midPoint(endPoint, startPoint) controlPoint:startPoint];
}

- (void)draw
{
    [self.lineColor setStroke];
    [self strokeWithBlendMode:kCGBlendModeNormal alpha:self.lineAlpha];
}

#if !ACE_HAS_ARC

- (void)dealloc
{
    self.lineColor = nil;
    [super dealloc];
}

#endif

@end

#pragma mark - ACEDrawingLineTool

@interface ACEDrawingLineTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingLineTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the line properties
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the line
    CGContextMoveToPoint(context, self.firstPoint.x, self.firstPoint.y);
    CGContextAddLineToPoint(context, self.lastPoint.x, self.lastPoint.y);
    CGContextStrokePath(context);
}

#if !ACE_HAS_ARC

- (void)dealloc
{
    self.lineColor = nil;
    [super dealloc];
}

#endif

@end

#pragma mark - ACEDrawingRectangleTool

@interface ACEDrawingRectangleTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingRectangleTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the rectangle
    CGRect rectToFill = CGRectMake(self.firstPoint.x, self.firstPoint.y, self.lastPoint.x - self.firstPoint.x, self.lastPoint.y - self.firstPoint.y);    
    if (self.fill) {
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
        CGContextFillRect(UIGraphicsGetCurrentContext(), rectToFill);
        
    } else {
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextStrokeRect(UIGraphicsGetCurrentContext(), rectToFill);        
    }
}

#if !ACE_HAS_ARC

- (void)dealloc
{
    self.lineColor = nil;
    [super dealloc];
}

#endif

@end

#pragma mark - ACEDrawingEllipseTool

@interface ACEDrawingEllipseTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingEllipseTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the ellipse
    CGRect rectToFill = CGRectMake(self.firstPoint.x, self.firstPoint.y, self.lastPoint.x - self.firstPoint.x, self.lastPoint.y - self.firstPoint.y);
    if (self.fill) {
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
        CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
        
    } else {
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextStrokeEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
    }
}

#if !ACE_HAS_ARC

- (void)dealloc
{
    self.lineColor = nil;
    [super dealloc];
}

#endif

@end
