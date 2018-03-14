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

#import "ACEDrawingViewToolPen.h"

#define MID_POINT(p1, p2) CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5)

NSString * const kACEDrawingToolViewPen = @"kACEDrawingToolViewPen";

#pragma mark -

@interface ACEDrawingViewToolPen()
@property (nonatomic, assign) CGMutablePathRef path;
@end

#pragma mark -

@implementation ACEDrawingViewToolPen

+ (NSString *)identifier
{
    return kACEDrawingToolViewPen;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        // create a new path
        self.path = CGPathCreateMutable();
        
        // use round style
        self.lineCapStyle = kCGLineCapRound;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}


#pragma mark Drawing View Methods

- (void)setInitialPoint:(CGPoint)firstPoint
{
    
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    
}

- (CGRect)addPathPreviousPreviousPoint:(CGPoint)p2Point withPreviousPoint:(CGPoint)p1Point withCurrentPoint:(CGPoint)cpoint {
    
    CGPoint mid1 = MID_POINT(p1Point, p2Point);
    CGPoint mid2 = MID_POINT(cpoint, p1Point);
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL, p1Point.x, p1Point.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(subpath);
    
    CGPathAddPath(_path, NULL, subpath);
    CGPathRelease(subpath);
    
    return bounds;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, _path);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetAlpha(context, self.alpha);
    CGContextStrokePath(context);
}

@end
