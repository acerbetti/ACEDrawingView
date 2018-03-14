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

#import "ACEDrawingViewToolArrow.h"

NSString * const kACEDrawingToolViewArrow = @"kACEDrawingToolViewArrow";

@implementation ACEDrawingViewToolArrow

+ (NSString *)identifier
{
    return kACEDrawingToolViewArrow;
}

- (void)draw
{
    CGFloat capHeight = self.lineWidth * 4.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the line properties
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetAlpha(context, self.alpha);
    
    // draw the line
    CGContextMoveToPoint(context, self.firstPoint.x, self.firstPoint.y);
    CGContextAddLineToPoint(context, self.lastPoint.x, self.lastPoint.y);
    
    // draw arrow cap
    CGFloat angle = [self angleWithFirstPoint:self.firstPoint secondPoint:self.lastPoint];
    CGPoint p1 = [self pointWithAngle:angle + 7.0f * M_PI / 8.0f distance:capHeight];
    CGPoint p2 = [self pointWithAngle:angle - 7.0f * M_PI / 8.0f distance:capHeight];
    CGPoint endPointOffset = [self pointWithAngle:angle distance:self.lineWidth];
    
    p1 = CGPointMake(self.lastPoint.x + p1.x, self.lastPoint.y + p1.y);
    p2 = CGPointMake(self.lastPoint.x + p2.x, self.lastPoint.y + p2.y);
    
    CGContextMoveToPoint(context, p1.x, p1.y);
    CGContextAddLineToPoint(context, self.lastPoint.x + endPointOffset.x, self.lastPoint.y + endPointOffset.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
    
    CGContextStrokePath(context);
}


#pragma mark Helpers

- (CGFloat)angleWithFirstPoint:(CGPoint)first secondPoint:(CGPoint)second
{
    CGFloat dx = second.x - first.x;
    CGFloat dy = second.y - first.y;
    CGFloat angle = atan2f(dy, dx);
    
    return angle;
}

- (CGPoint)pointWithAngle:(CGFloat)angle distance:(CGFloat)distance
{
    CGFloat x = distance * cosf(angle);
    CGFloat y = distance * sinf(angle);
    
    return CGPointMake(x, y);
}

@end
