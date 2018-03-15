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
        self.path = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(path))] pointerValue];
        self.color = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(color))];
        self.alpha = [aDecoder decodeDoubleForKey:NSStringFromSelector(@selector(alpha))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSValue valueWithPointer:self.path] forKey:NSStringFromSelector(@selector(path))];
    [aCoder encodeObject:self.color forKey:NSStringFromSelector(@selector(color))];
    [aCoder encodeDouble:self.alpha forKey:NSStringFromSelector(@selector(alpha))];
    
    [super encodeWithCoder:aCoder];
}


#pragma mark Drawing View Methods

- (void)setInitialPoint:(CGPoint)firstPoint
{
    
}

- (CGRect)moveInAreaFromPoint:(CGPoint)startPoint toPoint:(CGPoint)middlePoint toPoint:(CGPoint)endPoint
{
    CGPoint mid1 = MID_POINT(middlePoint, startPoint);
    CGPoint mid2 = MID_POINT(endPoint, middlePoint);
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL, middlePoint.x, middlePoint.y, mid2.x, mid2.y);
    CGRect drawBox = CGPathGetBoundingBox(subpath);
    
    CGPathAddPath(self.path, NULL, subpath);
    CGPathRelease(subpath);
    
    // final adjustements
    drawBox.origin.x    -= self.lineWidth * 2.0;
    drawBox.origin.y    -= self.lineWidth * 2.0;
    drawBox.size.width  += self.lineWidth * 4.0;
    drawBox.size.height += self.lineWidth * 4.0;
    
    return drawBox;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, self.path);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetAlpha(context, self.alpha);
    CGContextStrokePath(context);
}

@end
